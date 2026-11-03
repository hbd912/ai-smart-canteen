package com.canteen.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.canteen.common.Constants;
import com.canteen.common.JsonUtils;
import com.canteen.config.CanteenProperties;
import com.canteen.dto.AiRecommendRequest;
import com.canteen.entity.AiConversation;
import com.canteen.entity.AiMessage;
import com.canteen.entity.Dish;
import com.canteen.entity.DishCategory;
import com.canteen.entity.Order;
import com.canteen.entity.OrderItem;
import com.canteen.mapper.AiConversationMapper;
import com.canteen.mapper.AiMessageMapper;
import com.canteen.mapper.DishCategoryMapper;
import com.canteen.mapper.DishMapper;
import com.canteen.mapper.OrderItemMapper;
import com.canteen.mapper.OrderMapper;
import com.canteen.vo.AiRecommendVo;
import com.canteen.vo.AiStatusVo;
import com.canteen.vo.NutritionSummaryVo;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicReference;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

/**
 * AI 智能点餐助手。
 * <p>
 * 设计要点：
 * 1. 大模型调用完全封装在本服务中，Controller 不拼接第三方请求。
 * 2. 候选菜品来自数据库真实在售菜品，Prompt 中给出结构化候选与菜品 ID。
 * 3. 模型返回的菜品 ID 必须二次校验（存在、已上架、供应中、有库存），编造的菜品一律丢弃。
 * 4. 未配置 API Key 或调用失败时，自动降级为「规则演示模式」，并在响应中明确标注模式，
 *    绝不把规则推荐谎称为大模型生成。
 * 5. API Key 只从后端配置/环境变量读取，不写入日志、不返回前端。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AiRecommendationService {

    private static final Pattern JSON_BLOCK = Pattern.compile("\\{[\\s\\S]*}");
    private static final AtomicReference<String> LAST_ERROR = new AtomicReference<>(null);
    /** 用户用餐上下文的统计周期（天） */
    private static final int CONTEXT_DAYS = 7;

    private final DishMapper dishMapper;
    private final DishCategoryMapper categoryMapper;
    private final OrderMapper orderMapper;
    private final OrderItemMapper orderItemMapper;
    private final NutritionService nutritionService;
    private final AiConversationMapper conversationMapper;
    private final AiMessageMapper messageMapper;
    private final CanteenProperties properties;
    private final ObjectMapper objectMapper;

    // ---------------------------------------------------------------
    // 状态
    // ---------------------------------------------------------------

    public AiStatusVo status() {
        CanteenProperties.Ai ai = properties.getAi();
        AiStatusVo vo = new AiStatusVo();
        boolean configured = ai.isEnabled() && StringUtils.hasText(ai.getApiKey());
        vo.setConfigured(configured);
        vo.setAvailable(configured);
        vo.setModel(ai.getModel());
        vo.setMode(configured ? Constants.AiMode.LLM : Constants.AiMode.RULE_DEMO);
        vo.setModeLabel(configured ? "大模型模式" : "规则推荐演示模式");
        vo.setLastError(LAST_ERROR.get());
        vo.setMessage(configured
                ? "已配置大模型服务，推荐结果由模型基于数据库菜品生成并经后端校验。"
                : "未配置 AI_API_KEY，当前使用基于数据库菜品的规则推荐（演示降级模式）。");
        return vo;
    }

    // ---------------------------------------------------------------
    // 推荐入口
    // ---------------------------------------------------------------

    @Transactional
    public AiRecommendVo recommend(Long userId, AiRecommendRequest request) {
        long start = System.currentTimeMillis();
        List<Dish> candidates = loadCandidates();
        AiRecommendVo vo;
        if (candidates.isEmpty()) {
            vo = new AiRecommendVo();
            vo.setMode(Constants.AiMode.RULE_DEMO);
            vo.setModeLabel("规则推荐演示模式");
            vo.setReply("当前没有可推荐的在售菜品，请稍后再试或联系食堂工作人员。");
            vo.setDishes(List.of());
            vo.setTips(List.of("可以稍后刷新菜单，或直接浏览今日菜单手动选择。"));
            vo.setElapsedMs(System.currentTimeMillis() - start);
            return vo;
        }
        if (isLlmConfigured()) {
            try {
                vo = callLlm(userId, request, candidates);
            } catch (Exception ex) {
                LAST_ERROR.set(ex.getClass().getSimpleName() + ": " + safeMessage(ex));
                log.warn("大模型调用失败，降级为规则推荐：{}", safeMessage(ex));
                vo = ruleBased(request, candidates);
                vo.getTips().add("大模型服务当前不可用，以上结果由规则引擎生成（演示降级模式）。");
            }
        } else {
            vo = ruleBased(request, candidates);
        }
        vo.setElapsedMs(System.currentTimeMillis() - start);
        vo.setConversationId(persist(userId, request, vo));
        return vo;
    }

    private boolean isLlmConfigured() {
        CanteenProperties.Ai ai = properties.getAi();
        return ai.isEnabled() && StringUtils.hasText(ai.getApiKey());
    }

    /**
     * 候选集：已上架 + 供应中 + 有库存。管理员下架/售罄的菜品自动从候选中消失。
     */
    private List<Dish> loadCandidates() {
        return dishMapper.selectList(new LambdaQueryWrapper<Dish>()
                        .eq(Dish::getPublishStatus, Constants.PublishStatus.PUBLISHED)
                        .eq(Dish::getSupplyStatus, Constants.SupplyStatus.AVAILABLE)
                        .gt(Dish::getStock, 0)
                        .orderByAsc(Dish::getSortOrder))
                .stream()
                .sorted(Comparator.comparing((Dish d) -> d.getRecommendRank() == null ? 99 : d.getRecommendRank()))
                .toList();
    }

    // ---------------------------------------------------------------
    // 大模型调用
    // ---------------------------------------------------------------

    private AiRecommendVo callLlm(Long userId, AiRecommendRequest request, List<Dish> candidates) throws Exception {
        CanteenProperties.Ai ai = properties.getAi();
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, Function.identity(), (a, b) -> a));

        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        Duration timeout = Duration.ofSeconds(Math.max(ai.getTimeoutSeconds(), 5));
        factory.setConnectTimeout((int) timeout.toMillis());
        factory.setReadTimeout((int) timeout.toMillis());
        RestClient client = RestClient.builder()
                .baseUrl(ai.getBaseUrl())
                .requestFactory(factory)
                .defaultHeader(HttpHeaders.AUTHORIZATION, "Bearer " + ai.getApiKey())
                .defaultHeader(HttpHeaders.CONTENT_TYPE, MediaType.APPLICATION_JSON_VALUE)
                .build();

        String prompt = buildPrompt(userId, request, candidates, categories);
        Map<String, Object> payload = new LinkedHashMap<>();
        payload.put("model", ai.getModel());
        payload.put("temperature", ai.getTemperature());
        // GLM 系列模型默认思考时间较长，可配置 low/high/max 控制耗时
        if (StringUtils.hasText(ai.getReasoningEffort())) {
            payload.put("reasoning_effort", ai.getReasoningEffort());
        }
        // 多轮对话：带上同一会话最近几条消息，让「再便宜点」这类追问能接上上下文
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role", "system", "content", SYSTEM_PROMPT));
        messages.addAll(loadHistory(userId, request.getConversationId()));
        messages.add(Map.of("role", "user", "content", prompt));
        payload.put("messages", messages);
        payload.put("response_format", Map.of("type", "json_object"));

        String raw = client.post()
                .uri("/chat/completions")
                .body(payload)
                .retrieve()
                .body(String.class);
        if (!StringUtils.hasText(raw)) {
            throw new IllegalStateException("大模型返回为空");
        }
        JsonNode root = objectMapper.readTree(raw);
        JsonNode content = root.path("choices").path(0).path("message").path("content");
        if (content.isMissingNode() || !StringUtils.hasText(content.asText())) {
            throw new IllegalStateException("大模型响应缺少内容");
        }
        return parseLlmContent(content.asText(), candidates, categories);
    }

    /**
     * 读取同一会话最近 6 条消息作为多轮上下文。
     * 会话必须属于当前用户；历史 assistant 消息里的「| dishes=」内部标记会被剥离。
     */
    private List<Map<String, String>> loadHistory(Long userId, Long conversationId) {
        if (conversationId == null) {
            return List.of();
        }
        try {
            AiConversation conversation = conversationMapper.selectById(conversationId);
            if (conversation == null || !userIdsEqual(conversation.getUserId(), userId)) {
                return List.of();
            }
            List<AiMessage> history = messageMapper.selectList(new LambdaQueryWrapper<AiMessage>()
                    .eq(AiMessage::getConversationId, conversationId)
                    .in(AiMessage::getRole, "USER", "ASSISTANT")
                    .orderByDesc(AiMessage::getId)
                    .last("LIMIT 6"));
            Collections.reverse(history);
            List<Map<String, String>> out = new ArrayList<>();
            for (AiMessage m : history) {
                String content = stripDishMarkers(m.getContent());
                if (!StringUtils.hasText(content)) {
                    continue;
                }
                out.add(Map.of(
                        "role", "USER".equalsIgnoreCase(m.getRole()) ? "user" : "assistant",
                        "content", content.length() > 300 ? content.substring(0, 300) : content));
            }
            return out;
        } catch (Exception ex) {
            return List.of();
        }
    }

    private boolean userIdsEqual(Long a, Long b) {
        return a != null && a.equals(b);
    }

    private String stripDishMarkers(String content) {
        if (content == null) {
            return "";
        }
        int index = content.indexOf(" | dishes=");
        return (index >= 0 ? content.substring(0, index) : content).trim();
    }

    private static final String SYSTEM_PROMPT = """
            你是"智慧食堂"的点餐助手。请严格根据用户提供的候选菜品列表（包含真实 ID、价格、热量、营养、分类、标签）
            给出 2-3 道推荐，并说明理由。
            规则：
            1. 只能从候选菜品中选择，绝不能编造菜名、价格或营养数值；reply/tips 里提到的菜名也必须来自候选列表。
            2. 用户近期用餐数据是系统统计的真实值，只能引用给出的数字；未提供的信息（如疾病、过敏、身高体重）
               一律视为未知，不要假设或编造，必要时提醒用户补充。
            3. 必须输出 JSON 对象，不要输出 markdown 代码块或多余解释。
            4. JSON 结构：{"reply": "给用户的自然语言回复", "recommendations": [{"dishId": 数字, "reason": "推荐理由"}], "tips": ["搭配或注意事项"]}
            5. 若用户有预算/热量/口味限制，请在 reason 中体现如何满足；回答要结合用户近期用餐数据给出具体建议。
            """;

    private String buildPrompt(Long userId, AiRecommendRequest request, List<Dish> candidates,
                               Map<Long, DishCategory> categories) {
        StringBuilder sb = new StringBuilder();
        sb.append(buildUserContext(userId, request));
        sb.append("\n用户本次需求：").append(request.getMessage()).append('\n');
        if (request.getBudgetMax() != null) {
            sb.append("预算上限（元）：").append(request.getBudgetMax().toPlainString()).append('\n');
        }
        sb.append("\n候选菜品（只能从这里选择）：\n");
        for (Dish dish : candidates) {
            DishCategory category = categories.get(dish.getCategoryId());
            sb.append("- id=").append(dish.getId())
                    .append(" | 名称=").append(dish.getName())
                    .append(" | 分类=").append(category == null ? "未分类" : category.getName())
                    .append(" | 价格=").append(dish.getPrice() == null ? "未知" : dish.getPrice().toPlainString()).append("元")
                    .append(" | 热量=").append(dish.getCalories() == null ? "未知" : dish.getCalories().toPlainString()).append("kcal")
                    .append(" | 蛋白质=").append(dish.getProteinG() == null ? "未知" : dish.getProteinG().toPlainString()).append('g')
                    .append(" | 脂肪=").append(dish.getFatG() == null ? "未知" : dish.getFatG().toPlainString()).append('g')
                    .append(" | 碳水=").append(dish.getCarbohydrateG() == null ? "未知" : dish.getCarbohydrateG().toPlainString()).append('g')
                    .append(" | 标签=").append(String.join("/", JsonUtils.toList(dish.getTagsJson())))
                    .append(" | 库存=").append(dish.getStock())
                    .append('\n');
        }
        sb.append("\n请以 JSON 返回推荐结果。");
        return sb.toString();
    }

    /**
     * 用户自身情况：最近 N 天的真实消费统计与常点菜品。
     * 数据只来自订单表，读取失败时明确告知模型「未知」，避免它编造用户画像。
     */
    private String buildUserContext(Long userId, AiRecommendRequest request) {
        StringBuilder sb = new StringBuilder("用户近期用餐数据（系统统计，真实值）：\n");
        try {
            NutritionSummaryVo summary = nutritionService.summary(userId, CONTEXT_DAYS);
            sb.append("- 统计周期：").append(summary.getPeriod()).append('\n');
            sb.append("- 有效订单数：").append(summary.getOrderCount())
                    .append("，菜品份数：").append(summary.getDishCount()).append('\n');
            sb.append("- 日均热量：").append(summary.getDailyCalories().toPlainString())
                    .append(" kcal（参考目标 ").append(summary.getTargetCalories().toPlainString()).append("）\n");
            sb.append("- 日均蛋白质：").append(summary.getDailyProtein().toPlainString())
                    .append(" g（参考目标 ").append(summary.getTargetProtein().toPlainString()).append("）\n");
            sb.append("- 同期累计：脂肪 ").append(summary.getTotalFat().toPlainString())
                    .append(" g，碳水 ").append(summary.getTotalCarbohydrate().toPlainString())
                    .append(" g，膳食纤维 ").append(summary.getTotalFiber().toPlainString()).append(" g（估算）\n");
            if (summary.getOrderCount() == 0) {
                sb.append("- 说明：该用户最近没有用餐记录，不要编造历史偏好或忌口。\n");
            }
        } catch (Exception ex) {
            sb.append("- 用户用餐数据读取失败，请仅基于本次提问与候选菜品回答，不要编造历史数据。\n");
            log.warn("读取用户用餐上下文失败：{}", safeMessage(ex));
        }
        List<String> recent = recentDishNames(userId);
        sb.append("- 最近点过：").append(recent.isEmpty() ? "暂无记录" : String.join("、", recent)).append('\n');
        if (request.getBudgetMax() != null) {
            sb.append("- 本次预算上限：").append(request.getBudgetMax().toPlainString()).append(" 元\n");
        }
        return sb.toString();
    }

    private List<String> recentDishNames(Long userId) {
        try {
            LocalDateTime since = LocalDateTime.now().minusDays(CONTEXT_DAYS);
            List<Order> orders = orderMapper.selectList(new LambdaQueryWrapper<Order>()
                    .eq(Order::getUserId, userId)
                    .in(Order::getOrderStatus, Constants.OrderStatus.REVENUE_STATUSES)
                    .ge(Order::getCreatedAt, since));
            List<Long> orderIds = orders.stream().map(Order::getId).toList();
            if (orderIds.isEmpty()) {
                return List.of();
            }
            List<OrderItem> items = orderItemMapper.selectList(new LambdaQueryWrapper<OrderItem>()
                    .in(OrderItem::getOrderId, orderIds));
            Map<String, Integer> counts = new LinkedHashMap<>();
            for (OrderItem item : items) {
                String name = item.getDishNameSnapshot();
                if (!StringUtils.hasText(name)) {
                    continue;
                }
                counts.merge(name, item.getQuantity() == null ? 1 : item.getQuantity(), Integer::sum);
            }
            return counts.entrySet().stream()
                    .sorted(Map.Entry.<String, Integer>comparingByValue().reversed())
                    .limit(5)
                    .map(e -> e.getKey() + "×" + e.getValue())
                    .toList();
        } catch (Exception ex) {
            return List.of();
        }
    }

    private AiRecommendVo parseLlmContent(String content, List<Dish> candidates,
                                          Map<Long, DishCategory> categories) {
        Matcher matcher = JSON_BLOCK.matcher(content);
        if (!matcher.find()) {
            throw new IllegalStateException("大模型输出不是合法 JSON");
        }
        String json = matcher.group();
        try {
            JsonNode root = objectMapper.readTree(json);
            Map<Long, Dish> candidateMap = candidates.stream()
                    .collect(Collectors.toMap(Dish::getId, Function.identity(), (a, b) -> a));
            List<AiRecommendVo.AiDishSuggestionVo> suggestions = new ArrayList<>();
            Set<Long> used = new java.util.HashSet<>();
            for (JsonNode node : root.path("recommendations")) {
                long dishId = node.path("dishId").asLong(-1);
                Dish dish = candidateMap.get(dishId);
                // 关键校验：模型编造的 ID 或已下架/售罄菜品一律丢弃
                if (dish == null || !used.add(dishId)) {
                    continue;
                }
                suggestions.add(toSuggestion(dish, categories.get(dish.getCategoryId()),
                        node.path("reason").asText("符合你的需求")));
            }
            if (suggestions.isEmpty()) {
                throw new IllegalStateException("大模型未返回有效候选菜品");
            }
            AiRecommendVo vo = new AiRecommendVo();
            vo.setMode(Constants.AiMode.LLM);
            vo.setModeLabel("大模型模式");
            vo.setReply(root.path("reply").asText("根据你的需求，推荐以下菜品："));
            vo.setDishes(suggestions.stream().limit(3).toList());
            List<String> tips = new ArrayList<>();
            root.path("tips").forEach(t -> {
                if (StringUtils.hasText(t.asText())) {
                    tips.add(t.asText());
                }
            });
            if (tips.isEmpty()) {
                tips.add("营养数据为课堂演示估算值，仅供参考。");
            }
            vo.setTips(tips);
            return vo;
        } catch (Exception ex) {
            throw new IllegalStateException("大模型输出解析失败：" + ex.getMessage(), ex);
        }
    }

    // ---------------------------------------------------------------
    // 规则降级推荐
    // ---------------------------------------------------------------

    private AiRecommendVo ruleBased(AiRecommendRequest request, List<Dish> candidates) {
        String text = (request.getMessage() == null ? "" : request.getMessage()).toLowerCase(Locale.ROOT);
        Map<Long, DishCategory> categories = categoryMapper.selectList(null).stream()
                .collect(Collectors.toMap(DishCategory::getId, Function.identity(), (a, b) -> a));

        boolean lowFat = containsAny(text, "减脂", "低脂", "瘦身", "清淡", "低热量", "低卡", "轻食");
        boolean highProtein = containsAny(text, "蛋白", "增肌", "健身", "运动", "力量");
        boolean vegetarian = containsAny(text, "素", "蔬菜", "青菜", "素食", "绿叶");
        boolean soup = containsAny(text, "汤", "喝点");
        boolean noodle = containsAny(text, "面", "面条");
        boolean drink = containsAny(text, "饮", "喝", "豆浆", "柠檬");
        boolean full = containsAny(text, "饱", "饿", "多", "量大", "管饱");
        boolean cheap = containsAny(text, "便宜", "省钱", "预算", "实惠", "学生");

        BigDecimal budget = request.getBudgetMax();
        if (budget == null) {
            BigDecimal parsed = parseBudget(text);
            if (parsed != null) {
                budget = parsed;
            }
        }

        final BigDecimal budgetLimit = budget;
        List<Dish> filtered = candidates.stream()
                .filter(d -> budgetLimit == null || d.getPrice() == null
                        || d.getPrice().compareTo(budgetLimit) <= 0)
                .toList();
        if (filtered.isEmpty()) {
            filtered = candidates;
        }

        List<ScoredDish> scored = new ArrayList<>();
        for (Dish dish : filtered) {
            double score = 0;
            List<String> reasons = new ArrayList<>();
            DishCategory category = categories.get(dish.getCategoryId());
            String categoryName = category == null ? "" : category.getName();
            String tags = String.join("/", JsonUtils.toList(dish.getTagsJson()));
            BigDecimal calories = dish.getCalories() == null ? BigDecimal.ZERO : dish.getCalories();
            BigDecimal protein = dish.getProteinG() == null ? BigDecimal.ZERO : dish.getProteinG();
            BigDecimal fat = dish.getFatG() == null ? BigDecimal.ZERO : dish.getFatG();

            if (lowFat) {
                if (calories.compareTo(BigDecimal.valueOf(300)) <= 0) {
                    score += 3;
                    reasons.add("热量仅 " + calories.stripTrailingZeros().toPlainString() + " kcal，符合清淡低脂需求");
                }
                if (fat.compareTo(BigDecimal.valueOf(8)) <= 0) {
                    score += 2;
                    reasons.add("脂肪含量较低");
                }
            }
            if (highProtein) {
                if (protein.compareTo(BigDecimal.valueOf(20)) >= 0) {
                    score += 3;
                    reasons.add("蛋白质 " + protein.stripTrailingZeros().toPlainString() + " g，适合补充蛋白");
                } else if (protein.compareTo(BigDecimal.valueOf(12)) >= 0) {
                    score += 1.5;
                    reasons.add("含有一定蛋白质");
                }
            }
            if (vegetarian) {
                if ("VEGETABLE".equals(category == null ? "" : category.getCode())
                        || tags.contains("素食")) {
                    score += 3;
                    reasons.add("属于蔬菜类，清爽解腻");
                }
            }
            if (soup && "SOUP".equals(category == null ? "" : category.getCode())) {
                score += 2.5;
                reasons.add("一碗热汤，饭前暖胃");
            }
            if (noodle && "NOODLE".equals(category == null ? "" : category.getCode())) {
                score += 2.5;
                reasons.add("面食主食，吃得满足");
            }
            if (drink && "DRINK".equals(category == null ? "" : category.getCode())) {
                score += 2;
                reasons.add("搭配饮品更舒服");
            }
            if (full) {
                if (calories.compareTo(BigDecimal.valueOf(450)) >= 0) {
                    score += 2.5;
                    reasons.add("分量足、热量够，能吃饱");
                }
                if ("MAIN_MEAL".equals(category == null ? "" : category.getCode())) {
                    score += 1.5;
                }
            }
            if (cheap) {
                if (dish.getPrice() != null && dish.getPrice().compareTo(BigDecimal.valueOf(12)) <= 0) {
                    score += 2;
                    reasons.add("价格实惠，仅 " + dish.getPrice().stripTrailingZeros().toPlainString() + " 元");
                }
            }
            if (budgetLimit != null && dish.getPrice() != null && !cheap) {
                score += 1;
                reasons.add("价格 " + dish.getPrice().stripTrailingZeros().toPlainString()
                        + " 元，在 " + budgetLimit.stripTrailingZeros().toPlainString() + " 元预算内");
            }
            if (dish.getRecommendFlag() != null && dish.getRecommendFlag() == 1) {
                score += 0.8;
            }
            if (dish.getSoldCount() != null && dish.getSoldCount() > 0) {
                score += Math.min(dish.getSoldCount() / 20.0, 1.0);
            }
            if (score == 0) {
                // 没有明显偏好时，用推荐位 + 热量适中的组合
                if (calories.compareTo(BigDecimal.valueOf(150)) > 0
                        && calories.compareTo(BigDecimal.valueOf(650)) < 0) {
                    score += 1;
                    reasons.add("热量适中，适合日常一餐");
                }
                if (dish.getRecommendFlag() != null && dish.getRecommendFlag() == 1) {
                    score += 0.5;
                }
            }
            if (reasons.isEmpty()) {
                reasons.add("食堂在售菜品，可搭配主食一起点");
            }
            scored.add(new ScoredDish(dish, score, String.join("；", reasons)));
        }

        scored.sort(Comparator.comparingDouble(ScoredDish::score).reversed()
                .thenComparing(s -> s.dish().getSortOrder() == null ? 99 : s.dish().getSortOrder()));

        List<ScoredDish> picked = pickWithinBudget(scored, budgetLimit, 3);
        List<AiRecommendVo.AiDishSuggestionVo> suggestions = picked.stream()
                .map(s -> toSuggestion(s.dish(), categories.get(s.dish().getCategoryId()), s.reason()))
                .toList();

        AiRecommendVo vo = new AiRecommendVo();
        vo.setMode(Constants.AiMode.RULE_DEMO);
        vo.setModeLabel("规则推荐演示模式");
        vo.setReply(buildRuleReply(request.getMessage(), suggestions, lowFat, highProtein, vegetarian, budget));
        vo.setDishes(suggestions);
        List<String> tips = new ArrayList<>();
        if (budget != null) {
            BigDecimal total = suggestions.stream().map(AiRecommendVo.AiDishSuggestionVo::getPrice)
                    .filter(java.util.Objects::nonNull).reduce(BigDecimal.ZERO, BigDecimal::add)
                    .setScale(2, java.math.RoundingMode.HALF_UP);
            tips.add("推荐组合合计约 " + total.toPlainString() + " 元（预算 "
                    + budget.stripTrailingZeros().toPlainString() + " 元）"
                    + (total.compareTo(budget) <= 0 ? "，预算内可以直接下单。" : "，略超预算，可减少份数。"));
        }
        if (lowFat) {
            tips.add("想要更清淡可以再搭配一份汤品，减少油炸类菜品。");
        }
        if (highProtein) {
            tips.add("蛋白质补充建议分散到三餐，不要一次吃太多。");
        }
        tips.add("当前为规则推荐演示模式：结果由数据库中的真实在售菜品按营养与价格规则筛选，并非大模型生成。");
        vo.setTips(tips);
        return vo;
    }

    private String buildRuleReply(String message, List<AiRecommendVo.AiDishSuggestionVo> suggestions,
                                  boolean lowFat, boolean highProtein, boolean vegetarian, BigDecimal budget) {
        StringBuilder sb = new StringBuilder();
        sb.append("根据你说的「").append(message == null ? "" : message.trim()).append("」，");
        List<String> prefs = new ArrayList<>();
        if (lowFat) {
            prefs.add("清淡低脂");
        }
        if (highProtein) {
            prefs.add("补充蛋白");
        }
        if (vegetarian) {
            prefs.add("多点蔬菜");
        }
        if (budget != null) {
            prefs.add("控制预算");
        }
        if (!prefs.isEmpty()) {
            sb.append("我优先考虑了").append(String.join("、", prefs)).append("，");
        }
        sb.append("从今天在售的菜品里挑了 ").append(suggestions.size()).append(" 道：");
        sb.append(String.join("、", suggestions.stream()
                .map(AiRecommendVo.AiDishSuggestionVo::getName).toList()));
        sb.append("。");
        return sb.toString();
    }

    /**
     * 在预算内挑选推荐组合：优先高分菜品，若累计金额会超出预算则尝试用更便宜的候选替换，
     * 保证"预算 X 元"这类需求得到的是真正可下单的组合。
     */
    private List<ScoredDish> pickWithinBudget(List<ScoredDish> scored, BigDecimal budget, int limit) {
        List<ScoredDish> picked = new ArrayList<>();
        if (scored.isEmpty()) {
            return picked;
        }
        if (budget == null) {
            return scored.stream().limit(limit).toList();
        }
        BigDecimal spent = BigDecimal.ZERO;
        for (ScoredDish candidate : scored) {
            if (picked.size() >= limit) {
                break;
            }
            BigDecimal price = candidate.dish().getPrice() == null ? BigDecimal.ZERO : candidate.dish().getPrice();
            if (spent.add(price).compareTo(budget) <= 0) {
                picked.add(candidate);
                spent = spent.add(price);
            }
        }
        // 一份都放不下时，至少给出预算内最便宜的一道，避免空推荐
        if (picked.isEmpty()) {
            scored.stream()
                    .filter(s -> s.dish().getPrice() != null && s.dish().getPrice().compareTo(budget) <= 0)
                    .findFirst()
                    .ifPresent(picked::add);
        }
        return picked;
    }

    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private BigDecimal parseBudget(String text) {
        Matcher matcher = Pattern.compile("(\\d+(?:\\.\\d+)?)\\s*(元|块|块钱|rmb)").matcher(text);
        if (matcher.find()) {
            try {
                return new BigDecimal(matcher.group(1));
            } catch (NumberFormatException ignored) {
                return null;
            }
        }
        return null;
    }

    private AiRecommendVo.AiDishSuggestionVo toSuggestion(Dish dish, DishCategory category, String reason) {
        AiRecommendVo.AiDishSuggestionVo vo = new AiRecommendVo.AiDishSuggestionVo();
        vo.setDishId(dish.getId());
        vo.setName(dish.getName());
        vo.setImageUrl(dish.getImageUrl());
        vo.setPrice(dish.getPrice());
        vo.setCalories(dish.getCalories());
        vo.setCategoryName(category == null ? null : category.getName());
        vo.setReason(reason);
        vo.setTags(JsonUtils.toList(dish.getTagsJson()));
        return vo;
    }

    private record ScoredDish(Dish dish, double score, String reason) {
    }

    // ---------------------------------------------------------------
    // 会话持久化
    // ---------------------------------------------------------------

    @Transactional
    public Long persist(Long userId, AiRecommendRequest request, AiRecommendVo vo) {
        try {
            AiConversation conversation = null;
            if (request.getConversationId() != null) {
                conversation = conversationMapper.selectById(request.getConversationId());
                if (conversation != null && !conversation.getUserId().equals(userId)) {
                    conversation = null;
                }
            }
            if (conversation == null) {
                conversation = new AiConversation();
                conversation.setUserId(userId);
                conversation.setTitle(truncate(request.getMessage(), 60));
                conversationMapper.insert(conversation);
            }
            AiMessage userMessage = new AiMessage();
            userMessage.setConversationId(conversation.getId());
            userMessage.setRole("USER");
            userMessage.setContent(request.getMessage());
            userMessage.setMode(vo.getMode());
            messageMapper.insert(userMessage);

            AiMessage assistantMessage = new AiMessage();
            assistantMessage.setConversationId(conversation.getId());
            assistantMessage.setRole("ASSISTANT");
            assistantMessage.setContent(vo.getReply() + " | dishes=" + vo.getDishes().stream()
                    .map(AiRecommendVo.AiDishSuggestionVo::getDishId).map(String::valueOf)
                    .collect(Collectors.joining(",")));
            assistantMessage.setMode(vo.getMode());
            messageMapper.insert(assistantMessage);
            return conversation.getId();
        } catch (Exception ex) {
            log.warn("AI 会话保存失败（不影响推荐结果）：{}", safeMessage(ex));
            return null;
        }
    }

    private String truncate(String text, int max) {
        if (text == null) {
            return "AI 点餐咨询";
        }
        return text.length() <= max ? text : text.substring(0, max);
    }

    private String safeMessage(Throwable ex) {
        String message = ex.getMessage();
        if (message == null) {
            return ex.getClass().getSimpleName();
        }
        // 避免把可能的密钥片段带进日志
        return message.length() > 200 ? message.substring(0, 200) : message;
    }
}
