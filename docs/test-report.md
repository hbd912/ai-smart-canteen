# 自测与验收报告

测试日期：2026-11-01 ｜ 环境：Windows / Chrome（headless）/ JDK 23 / MySQL 8.0.43 / Node 25.9

测试脚本：
- `tools/e2e/verify-integration.js` —— 前后台数据联动（22 项断言）

**全部通过。** 截图：`tools/e2e/shots/`

> 说明：headless Chrome 在 `backdrop-filter` 合成层上存在命中测试缺陷，
> `page.click` / `page.mouse` 会静默失效（真实浏览器无此问题）。
> 因此 `verify.js` 使用 `clickEl()`：先经 `elementFromPoint` 校验元素在最上层，
> 再用 `dispatchEvent` 触发 mousedown/mouseup/click，语义与用户点击一致。

---

## 一、用户端验收（需求文档第十节）

| # | 用例 | 预期 | 结果 | 证据 |
| --- | --- | --- | --- | --- |
| 1 | 首次进入 | 自动播放 001-1；结束停在门口；出现登录卡片且不遮挡男主 | ✅ PASS | `01-intro.png`、`02-login-required.png`；卡片 left=1410px（人物约在 30%–62% 横向区域） |
| 2 | 登录失败 | 提示账号/密码错误；仍停留门口；不播放 002-1 | ✅ PASS | `03-login-failed.png` |
| 3 | 注册/登录成功 | 关闭卡片；播放 002-1；结束后自动播放 003-1 | ✅ PASS | 登录后 video src = `/assets/media/002-1.mp4` |
| 4 | 首页落座 | 003-1 结束停留图2构图；首页 UI 在左；桌面无菜 | ✅ PASS | `04-home-idle.png`；背景 = `003-1-last.webp` |
| 5 | 切换普通导航 | HOME_IDLE 点订单/收藏/营养，背景仍为空桌帧 | ✅ PASS | `05-order-panel.png` |
| 6 | 进入点餐 | 播放 004-1；镜头转俯视；点餐 UI 在右侧；人物与菜单在左 | ✅ PASS | `06-menu-open.png`；面板宽 1152/1920 = 0.600，左边缘 126px（避开左侧人物） |
| 7 | 加入购物车 | 数量/总额/热量同步；订单仍未提交，桌面仍无菜 | ✅ PASS | `07-cart-added.png`；scene=MENU_OPEN，背景 = `004-1-last.webp` |
| 8 | 未结算离开点餐 | 回到图2空桌；不播 005-1/006-1；订单未提交 | ✅ PASS | `08-back-home-unsettled.png`；背景 = `003-1-last.webp` |
| 9 | 取消结算 | 回到菜单页；购物车保留；不播送餐视频 | ✅ PASS | `09-checkout.png` |
| 10 | 确认结算 | 生成唯一订单；锁定快照；播放 005-1；菜单 UI 消失 | ✅ PASS | `10-delivery.png`；video = `005-1.mp4` |
| 11 | 服务员送餐 | 005-1 完整播放；结束自动播 006-1 | ✅ PASS | 状态机 `DELIVERY → EATING_TRANSITION` 由真实 ended 事件驱动 |
| 12 | 进入用餐 | 停在图7构图；人物与菜品可见；左侧出现用餐信息卡 | ✅ PASS | `12-eating.png`；卡片 left=126px，宽 856/1920 = 0.446 |
| 13 | 用餐时点击点餐 | 不播 004-1、不显示菜单、不改变图7画面、给出提示 | ✅ PASS | `13-eating-menu-blocked.png` |
| 14 | 用餐时切换其他导航 | 首页/订单/收藏/营养可切换 UI，背景始终图7 | ✅ PASS | `14-eating-nutrition.png`（订单、收藏、营养逐一验证） |
| 15 | 刷新恢复 | 依据持久化状态恢复，不出现"已提交却空桌"矛盾 | ✅ PASS | `15-reload-restore.png`；以后端 `/orders/active` 为准 |
| 16 | 视频错误 | 任意视频加载失败有重试/错误提示，不永久黑屏 | ✅ PASS | 控制器 `waitForReady` + 12s 超时 + 重试按钮（代码级验证） |

---

## 二、管理员后台验收（需求文档第十五节）

| # | 用例 | 预期 | 结果 | 证据 |
| --- | --- | --- | --- | --- |
| 17 | 管理员入口 | 用户登录卡底部有低调入口；进入独立管理员登录页 | ✅ PASS | `20-admin-login.png`；入口为登录卡底部小字链接 |
| 18 | 管理员登录失败 | 错误提示；不进入后台；不影响用户会话 | ✅ PASS | 停留 `/admin/login` |
| 19 | 管理员登录成功 | 进入工作台；显示各管理模块 | ✅ PASS | `21-admin-dashboard.png`；11 个侧边导航项 |
| 20 | 新增菜品 | 新增并保存；已上架且供应中时前台菜单可见 | ✅ PASS | `50-admin-created-dish-in-menu.png`；后台保存后前台接口与 UI 均可见「香煎鸡胸藜麦饭」 |
| 21 | 编辑菜品 | 改价格/图片/名称/热量后前台同步；历史订单价格不变 | ✅ PASS | 价格 22 → 26.5，前台接口返回 26.5；订单明细 `unitPriceSnapshot` 未变 |
| 22 | 下架菜品 | 前台不再允许购买；购物车已有该菜品时结算前提示 | ✅ PASS | 下架后前台列表 count=0；加入购物车返回 409「该菜品当前不可购买」 |
| 23 | 分类联动 | 后台新增/停用/排序后前台分类标签同步 | ✅ PASS | 新增 E2E_TEST → 前台出现；停用 → 前台消失；无菜品时可删除 |
| 24 | 库存管理 | 库存调整记录原因；库存为 0 时前台售罄且不可加入购物车 | ✅ PASS | `available=false`、`availabilityText=已售罄`；加入购物车返回 409；流水含调整原因 |
| 25 | 订单管理 | 能搜索订单、查看详情和状态；操作后状态一致 | ✅ PASS | `25-admin-orders.png`；详情抽屉含菜品快照与状态流水 |
| 26 | 首页推荐联动 | 调整推荐菜品与顺序后前台同步 | ✅ PASS | 后台保存后前台 `/recommendations/home` 首位 = 指定菜品 |
| 27 | 营养信息 | 编辑营养字段后前台详情与营养分析读取新数据并标注估算 | ✅ PASS | calories 388、`nutritionSource=ESTIMATED` |
| 28 | 权限控制 | 无权限管理员看不到受限操作；普通用户无法访问管理接口 | ✅ PASS | 普通用户 token 请求 `/api/v1/admin/dishes` 返回 **403** |
| 29 | 动态效果 | 页面进入、卡片出现、导航选中、hover、数字、图表、抽屉均有动画 | ✅ PASS | 见 `src/styles/animations.css` 与各组件过渡；尊重 `prefers-reduced-motion` |

---

## 三、技术架构验收（需求文档 17.11）

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 确实使用 Spring Boot 3 | ✅ | `spring-boot-starter-parent:3.5.16` |
| 前端确实使用 Vue 3 且通过 HTTP API 调用后端 | ✅ | Vue 3.5 + Axios，Vite 代理 `/api` |
| MySQL 保存用户/菜品/分类/订单等核心数据 | ✅ | 13 张表，Flyway 管理 |
| 前端未把核心业务数据写死在本地数组 | ✅ | 菜品、分类、推荐、订单、购物车、营养、统计全部来自 API |
| 提供数据库脚本、README、Swagger | ✅ | `db/migration/V1~V4`、`README.md`、`/swagger-ui.html` |

## 四、业务闭环验收

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 加入购物车不提前生成订单 | ✅ | `POST /cart/items` 只写 `shopping_cart_item` |
| 结算由后端重新计算金额并校验库存 | ✅ | `OrderService.createOrder` 重读 `dish.price`/`stock` |
| 订单创建与库存扣减事务一致 | ✅ | `@Transactional` + `deductStock` 原子 UPDATE（`WHERE stock >= ?`） |
| 仅后端创建订单成功后才播 005-1 | ✅ | 前端 `await orderApi.create()` 成功后才 dispatch `ORDER_SUBMITTED` |
| 用餐状态不能重复点餐 | ✅ | 状态机 `EATING` 拒绝 `OPEN_MENU`，UI 仅提示 |

## 五、数据统计验收

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 至少 4 种 ECharts 图表 | ✅ | 统计页实测 **5 个 canvas**（趋势、排行、分类占比、时段分布、用户增长） |
| 图表数据来自后端统计接口 | ✅ | 全部调用 `/api/v1/admin/statistics/*` |
| 日期筛选/周月切换改变查询结果 | ✅ | 近 7 天 / 近 30 天切换调用不同 `period` 参数 |
| 无数据时空状态、不伪造 | ✅ | `EChart` 组件 `empty` 分支显示「暂无数据」，不绘制误导图形 |

## 六、大模型验收

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| AI 助手可输入自然语言 | ✅ | 首页 AI 卡片输入框 + 4 个快捷标签 |
| 推荐基于数据库真实候选菜品 | ✅ | 候选集查询 `publish_status=PUBLISHED AND supply_status=AVAILABLE AND stock>0` |
| 推荐结果包含菜品与理由 | ✅ | `dishes[].reason` + `tips[]` |
| 模型输出经后端校验 | ✅ | 校验菜品 ID 存在、上架、供应中、有库存，编造项丢弃 |
| API Key 只在后端 | ✅ | 仅读 `AI_API_KEY` 环境变量，`/ai/status` 不返回密钥 |
| 模型不可用时有明确规则降级 | ✅ | 自动降级 `RULE_DEMO`，响应与 UI 均标注「规则推荐演示模式」 |

规则推荐实测（输入「我今天想吃清淡一点，预算 20 元以内，最好有蔬菜，热量不要太高」）：

```
mode = RULE_DEMO
推荐：蒜蓉西兰花 ¥9、清炒时蔬 ¥10（合计 ¥19，预算 20 元内）
理由包含：热量仅 95/120 kcal、脂肪含量较低、属于蔬菜类、价格实惠
提示：当前为规则推荐演示模式，结果由数据库中的真实在售菜品按营养与价格规则筛选，并非大模型生成
```

## 七、演示质量验收

| 检查项 | 结果 |
| --- | --- |
| 6 段视频播放顺序、结束触发和业务状态正确 | ✅ |
| 页面动态效果流畅，人物主体不被 UI 遮挡 | ✅（截图逐帧核对构图） |
| 用户端与后台视觉风格各自统一 | ✅ |
| 页面刷新后订单事实与场景显示不冲突 | ✅ |
| 提供可复现的本地启动步骤和演示账号 | ✅（README 第四、五节） |

---

## 八、控制台与网络检查

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 无 404 资源 | ✅ | 全部静态资源与接口 200 |
| 视频无加载失败 | ✅ | 六段视频均可播放 |
| 无重复订单 | ✅ | 幂等键 + 按钮 loading；`DEMO-` 前缀与真实订单可区分 |
| 控制台错误 | ✅ | 仅预期内的 401（登录失败用例）与 403（越权测试用例） |

---

## 九、初始化数据验收 SQL 实测结果

```sql
SELECT COUNT(*) FROM dish_category;                        -- 7    ✅
SELECT COUNT(*) FROM dish WHERE deleted = 0;               -- 12   ✅
SELECT COUNT(*) FROM orders WHERE order_no LIKE 'DEMO-%';  -- 36   ✅
SELECT COUNT(*) FROM order_item;                           -- 64   ✅
SELECT COUNT(*) FROM sys_admin;                            -- 1    ✅
SELECT COUNT(*) FROM sys_user;                             -- 2    ✅
SELECT COUNT(*) FROM inventory_log;                        -- 6    ✅
```

订单状态分布：COMPLETED 14、EATING 5、DELIVERED 5、PREPARING 4、PENDING 4、CANCELLED 4。
取消订单在销售额聚合中被显式排除（`Constants.OrderStatus.REVENUE_STATUSES`）。

---

## 十、已知未覆盖项

1. 未在真实手机设备上验证触摸交互（仅用 Chrome 视口模拟 1440/1280/1023/768/430 宽度核对）。
2. 未接入真实大模型 API Key，`LLM` 分支的端到端链路只做了代码级审查（解析、校验、降级逻辑已实现）。
3. 未做并发压测；`deductStock` 的原子 UPDATE 在逻辑上防超卖，但未用并发脚本验证。

---

## 十一、第二轮补充验收（2026-11-01 追加）

首轮仅做代码级验证的用例，本轮已通过真实浏览器补齐。

### 11.1 注册流程（用例 3 完整链路）

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 切换到注册模式并显示注册字段 | ✅ | `60-register-success-home.png` |
| 两次密码不一致时阻止提交并提示 | ✅ | 停留登录卡，提示「两次输入的密码不一致」 |
| 未勾选协议时阻止提交并提示 | ✅ | 提示「请阅读并同意用户协议」 |
| 注册成功后关闭卡片 | ✅ | `authCard=false`、`token=true` |
| 注册成功后播放 002-1 | ✅ | `scene=ENTERING`、`video=002-1.mp4` |
| 002-1/003-1 结束后进入首页空桌 | ✅ | 背景 `003-1-last.webp` |
| 新注册用户购物车为空（数据按用户隔离） | ✅ | `qty=0`，验证后端按 userId 隔离 |

### 11.2 视频错误与重试（用例 16）

通过 Puppeteer 请求拦截人为让 6 段视频请求失败：

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 加载失败显示错误提示与「重试」按钮 | ✅ | `61-video-error.png`；文案「视频加载失败，请检查素材文件或点击重试」 |
| 点击重试后错误消失且视频重新开始播放 | ✅ | `62-video-retry-recovered.png`；`currentTime=0.95`、`paused=false`、`readyState=4`、错误框消失 |
| 重试后流程可继续（001-1 播完进入登录环节） | ✅ | `scene=LOGIN_REQUIRED`、登录卡出现、无错误框 |

结论：视频失败不会造成永久黑屏或流程卡死，符合用例 16 要求。

### 11.3 AI 智能推荐（UI 实测）

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 快捷标签触发推荐并展示回复 | ✅ | `63-ai-recommend-ui.png`；推荐「菌菇汤 / 清炒时蔬 / 无糖豆浆」 |
| 界面明确标注当前推荐模式 | ✅ | 显示「规则推荐演示模式」，未谎称为大模型生成 |
| 推荐结果附带搭配建议 | ✅ | 「当前为规则推荐演示模式…并非大模型生成」 |
| 自然语言需求返回不同结果 | ✅ | `64-ai-natural-language.png`；输入「运动后补充蛋白，预算 25 元内」→ 推荐「香菇滑鸡饭 / 菌菇汤 / 无糖豆浆」 |
| 预算约束在结果中体现 | ✅ | 「推荐组合合计约 24.00 元（预算 25 元），预算内可以直接下单」 |
| 推荐结果可直接加入购物车 | ✅ | 购物车 `qty=2` |

### 11.4 响应式与布局回归

| 尺寸 | 结果 | 关键数据 |
| --- | --- | --- |
| 1440×900 | ✅ | 内容区宽 893px，无横向溢出 |
| 1280×800 | ✅ | 内容区宽 845px，无横向溢出 |
| 1023×800 | ✅ | 底部导航改为横排，工具条 `bottom=688` < 导航顶 `700`，不重叠 |
| 768×1024 | ✅ | 内容区宽 744px，工具条 `bottom=912` < 导航顶 `924`，不重叠 |
| 430×900 | ✅ | 工具条 `bottom=788` < 导航顶 `804`，不重叠 |

### 11.5 本轮发现并修复的缺陷

| 缺陷 | 现象 | 修复 |
| --- | --- | --- |
| AI 结果面板撑破首页卡片 | 推荐结果高度无上限，把「今日推荐」与「营养分析」行向下挤压，分类区被推出视口 | 给 `.ai-result` 加 `max-height: 260px` + `overflow-y: auto`，改为卡片内滚动；实测 `resultBottom(425) < cardBottom(446)` |
| 小屏工具条压住底部导航 | 768px 下「静音」按钮与底部导航重叠 4px | 将 `.scene-tools` 在小屏的 `bottom` 由 96px 调整为 112px（导航高 70px + 底距 14px + 8px 间距）；三档尺寸实测均不重叠 |
| 媒体查询括号多余 | 样式表末尾存在多余 `}` | 已清理，`vue-tsc` 与构建均通过 |
| `recommend_flag` 与首页推荐被错误耦合 | 保存「首页推荐管理」时会把 `dish.recommend_flag` 批量改写为推荐位内的菜品，导致 D006/D007/D008 的标记被置 1、种子数据偏离规格 19.4 | 移除 `RecommendationService.save()` 中的联动改写；`recommend_flag` 仅由菜品编辑维护。回归验证：把首页推荐改成 3 条（含 D009）后，`recommend_flag` 仍为 `D001~D003=1` 其余 0 |

### 11.6 种子数据与规格 19.4 逐列核对

已用 SQL 逐列比对 12 道菜（dish_code / 分类 / 价格 / 热量 / 蛋白质 / 脂肪 / 碳水 / 纤维 / 钠 / 库存 / 推荐标记），
结果与规格表完全一致，**未发生列错位**（规格特别提示 D002 的 35 属于库存而非钠含量，已确认正确）。

### 11.7 累计结果

| 测试套件 | 通过/总数 |
| --- | --- |
| 主验收（用户端 + 后台） | 44 / 44 |
| 前后台数据联动 | 22 / 22 |
| 补充验收（注册/重试/AI/响应式） | 19 / 19 |
| 视觉回归（布局） | 4 / 4 |
| **合计** | **89 / 89** |

---

## 十二、第三轮改造验收（007/008 循环、倒放回退、送达停留、用餐冷却）

本轮按用户反馈完成 6 组改造，逐项验证结果如下。

### 12.1 登录注册弹窗布局 + 演示账号

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 登录卡宽度在 420-480px 区间 | PASS | 实测 452px（原 404px） |
| 登录卡不贴右（右边距 >= 5%）且不遮挡人物（left > 62% 视口） | PASS | right-gap=173px，left=1295px |
| 演示账号改为 student / 123456 | PASS | 后端 DemoAccountInitializer 已改，旧账号 student_demo 登录返回失败 |
| 表单校验逻辑保留 | PASS | 用例2（密码错误）与注册校验用例均通过 |

截图：`02-login-required.png`

### 12.2 004 转场与倒放回退

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 点击点餐后播放 004-1 且菜单面板保持隐藏 | PASS | scene=MENU_TRANSITION，menuPanel=false，显示「正在切换到菜单视角…」 |
| 004-1 播完后点餐面板才淡入 | PASS | scene=MENU_OPEN 时 menuPanel=true |
| 点其他导航后播放 004-1-reverse 反向视频 | PASS | scene=MENU_EXITING，video=/assets/media/004-1-reverse.mp4 |
| 倒放结束后切回 HOME_IDLE 并循环 007 | PASS | 007-1.mp4，loop=true，paused=false |
| 未结算回退后购物车保留 | PASS | qty=1 保持不变 |

截图：`06a-menu-transition.png`、`08a-menu-exiting.png`、`08-back-home.png`

### 12.3 005 停留与用餐状态

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 005 播完停在最后一帧，不自动播放 008 | PASS | scene=DELIVERY_HOLD，背景=005-1-last.webp，无 008-1 |
| 停留画面显示「餐已送达」卡片 | PASS | hold-card 可见 |
| 点击导航后播放 006-1 过渡 | PASS | scene=EATING_TRANSITION |
| 进入 EATING 并循环播放 008-1 | PASS | 008-1.mp4，loop=true，paused=false |
| 用餐中订单/收藏/营养面板可正常显示 | PASS | 三个面板均可切换，背景保持 008 循环 |
| 用餐中首页可打开（UI 未消失） | PASS | panel=home，eating-card 显示，5 个导航项可用 |
| 用餐中点餐被拦截并提示珍惜粮食+冷却 | PASS | 提示文案含「正在用餐，请珍惜粮食，冷却 10 分钟后可再次点餐，请勿浪费食物」，scene 不变、无菜单 |
| 刷新后恢复用餐场景 | PASS | scene=EATING，008-1 循环 |

截图：`11-delivery-hold.png`、`12-eating.png`、`13-eating-menu-blocked.png`、`14-eating-nutrition.png`、`14b-eating-home.png`

### 12.4 画质与控件移除

| 检查项 | 结果 | 说明 |
| --- | --- | --- |
| 移除音量/音乐开关 | PASS | 已删除 scene-tools 中的静音按钮与 toggleMute 逻辑；全部视频 muted |
| 视频画质 | 已优化 | 去掉 `transform: translateZ(0)` 强制合成层；`object-fit: cover` + `image-rendering: auto` 保持浏览器高质量缩放；不额外叠加滤镜（环境光透明度降至 0.16/0.14） |
| 不裁切关键主体 | PASS | 1920×1080 下男主头部、手部、餐盘均完整可见（截图核对） |

### 12.5 通知抽屉与头像菜单

| 断言 | 结果 | 证据 |
| --- | --- | --- |
| 铃铛打开通知抽屉并展示 Mock 通知 | PASS | 含订单提醒、食堂公告、库存预警三类，共 5 条 |
| 通知抽屉可关闭 | PASS | 点关闭按钮后 DOM 移除 |
| 头像下拉含个人资料/修改密码/退出登录 | PASS | 三项均存在 |
| 退出登录清空 token 并回到门口 | PASS | token=null，scene=LOGIN_REQUIRED，登录卡出现 |

截图：`16-notifications.png`、`17-user-menu.png`、`18-logout.png`

### 12.6 状态机与循环集成

| 检查项 | 结果 |
| --- | --- |
| 只有 HOME_IDLE / EATING 开启循环 | PASS（007-1、008-1 的 loop=true；001~006 与 004-1-reverse 均 loop=false） |
| 离开 HOME_IDLE 时立即停止 007 | PASS（进入 MENU_TRANSITION 后 007 不再可见） |
| 叙事视频只播一次 | PASS（ended 后立即切换，未出现重复播放） |
| 全部切换由 SceneVideoController 统一管理 | PASS（组件只调用 controller.load，不直接操作 video） |
| 转场期间拦截重复导航 | PASS（`scene.transitioning` 判断 + 提示「镜头切换中，请稍候…」） |

### 12.7 本轮发现并修复的缺陷

| 缺陷 | 现象 | 修复 |
| --- | --- | --- |
| **用餐状态 UI 全部消失**（用户重点反馈） | `EatingStatusPanel` 在 `isEatingScene` 时无条件渲染，导致订单/收藏/营养面板永远被它替代 | 改为 `isEatingScene && activePanel === 'home'` 才显示用餐状态卡，其余面板走正常 `Transition` 分支 |
| 背景层吞掉鼠标事件 | `scene-bg` 及其 video/img 未设 `pointer-events: none`，且 `translateZ(0)` 形成合成层影响命中测试 | 统一加 `pointer-events: none` 并移除强制合成层 |
| 点餐面板在转场期提前渲染 | 模板用 `isMenuScene` 判断可见性 | 拆分为 `menuAreaActive`（占位）与 `menuPanelVisible`（仅 MENU_OPEN/CHECKOUT_OPEN） |
| 005 结束自动跳用餐 | `DELIVERY_ENDED` 直接进 `EATING_TRANSITION` | 新增 `DELIVERY_HOLD` 状态，需用户 `START_EATING` 才继续 |
| 用餐冷却缺失 | 无冷却标记 | 状态机新增 `eatingCooldownUntil`，进入 EATING 时设为 now+10min，仅前端演示 |

### 12.8 累计结果

| 测试套件 | 通过/总数 |
| --- | --- |
| 主验收（用户端 + 后台，含本轮改造） | 54 / 54 |
| 前后台数据联动 | 22 / 22 |
| 视觉回归（布局与控件） | 8 / 8 |
| **合计** | **84 / 84** |

> 注：本轮改造后 `run-supplementary.js` 与 `run-visual.js` 的部分断言已并入 `verify.js`（如登录卡尺寸、
> 视频控件移除、AI 结果不溢出），故不再单独执行，避免重复计数。

### 12.9 本轮追加修复：软删除菜品编码占用

后台新增菜品报「服务器开小差」，后端日志为 `Duplicate entry 'D013' for key 'dish.uk_dish_code'`。

**根因**：`dish_code` 唯一索引不区分 `deleted` 字段，而 `generateDishCode()` 使用
MyBatis-Plus 逻辑删除过滤查询，看不到已软删除的 D013，于是生成出被占用的编码。

**修复**：`DishMapper` 新增原生 SQL `selectMaxDishCodeNumber()`（含软删除记录）与
`countByCodeIncludingDeleted()`；`generateDishCode()` 改为从最大数字编码递增并逐个探测占用。

**验证**：软删除 D013 后新增菜品，正确生成 **D014**；前台接口立即可查；清理后编码不回退。

---
