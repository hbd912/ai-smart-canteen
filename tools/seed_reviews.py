"""
从参考项目导入菜品评价到本项目。

规则：
1. 评语中的其他菜名统一改写为当前菜品名，保证语义对应；
2. 空评语直接丢弃，不生成占位符；
3. 通用评语按菜品分类挑选（汤品说汤底、饮品说甜度）；
4. 去重采用「基础评语一次 + 变体后缀扩充」；
5. 每道菜 52~68 条，评分分布 5星45%/4星30%/3星12%/2星8%/1星5%；
6. 时间重分布到今天往前 90 天；
7. 输出幂等 SQL（dish_id + content 判重）。
"""
import io
import os
import random
import re
from collections import Counter
from datetime import datetime, timedelta

REF_SQL = r"D:\AI\AI Contest\canteen-feedback-system\db\init-data.sql"
OUT = r"D:\AI\AI Contest\canteen\db\seed-dish-reviews.sql"

PROJECT_DISHES = {
    "D001": ("黑椒鸡排饭", "MAIN_MEAL"),
    "D002": ("番茄牛腩饭", "MAIN_MEAL"),
    "D003": ("香菇滑鸡饭", "MAIN_MEAL"),
    "D004": ("宫保鸡丁饭", "MAIN_MEAL"),
    "D005": ("鱼香肉丝饭", "MAIN_MEAL"),
    "D006": ("清炒时蔬", "VEGETABLE"),
    "D007": ("香菇鸡丝面", "NOODLE"),
    "D008": ("菌菇汤", "SOUP"),
    "D009": ("红烧排骨", "MEAT"),
    "D010": ("蒜蓉西兰花", "VEGETABLE"),
    "D011": ("柠檬蜂蜜水", "DRINK"),
    "D012": ("无糖豆浆", "DRINK"),
}

NAME_MAP = {
    "宫保鸡丁": "D004", "鱼香肉丝": "D005",
    "麻辣香锅小份": "D004", "麻辣香锅大份": "D004",
    "素菜香锅": "D010", "香锅宽粉": "D007",
    "水煮肉片": "D009", "干煸豆角": "D010", "麻婆豆腐": "D010",
    "蜜汁叉烧饭": "D001", "白切鸡饭": "D003", "烧鸭饭": "D009",
    "豉汁排骨饭": "D009", "卤水双拼饭": "D001",
    "牛肉拉面": "D007", "番茄鸡蛋面": "D007", "老北京炸酱面": "D007",
    "山西刀削面": "D007", "岐山臊子面": "D007",
    "羊肉泡馍": "D007", "烤羊肉串": "D009", "新疆大盘鸡": "D009",
    "牛肉小炒": "D009",
    "香煎鸡胸沙拉": "D006", "三文鱼牛油果沙拉": "D006",
    "缤纷时蔬沙拉": "D006", "金枪鱼藜麦沙拉": "D006",
    "水晶虾饺皇": "D001", "爆浆流沙包": "D001", "豉汁蒸肠粉": "D007",
    "豉汁蒸凤爪": "D009", "糯米鸡": "D001",
    "杨枝甘露": "D011", "顺德双皮奶": "D011",
    "黑糖珍珠奶茶": "D012", "芋泥啵啵奶茶": "D012",
    "腊味煲仔饭": "D002", "香菇滑鸡煲仔饭": "D003", "豉汁排骨煲仔饭": "D009",
    "窝蛋牛肉煲仔饭": "D002",
    "猪肉白菜水饺": "D001", "三鲜水饺": "D001", "韭菜鸡蛋水饺": "D006",
    "酸菜猪肉水饺": "D001", "两荤一素套餐": "D001", "一荤两素套餐": "D001",
    "红烧肉": "D009", "番茄炒蛋": "D008",
    "黑椒牛柳铁板饭": "D001", "香辣鸡腿铁板饭": "D001",
    "照烧鸡排铁板饭": "D001", "铁板时蔬豆腐": "D006",
}

GENERIC = {
    "MAIN_MEAL": [
        "分量很足，米饭给得实在，男生也吃得饱",
        "菜码偏少，米饭多，希望荤素比例调一下",
        "出餐很快，拿到手还是热的",
        "味道不错，就是油稍微大了点",
        "价格实惠，性价比高，常来吃",
        "米饭有点硬，菜的味道还行",
        "配菜新鲜，整体满意",
        "有点咸，下次希望能少放点盐",
        "中午排队等了十几分钟，出餐可以再快点",
        "口味偏淡，适合清淡党",
        "肉给得很大方，师傅人也好",
        "整体不错，会推荐给室友",
        "汤汁有点多，米饭有点泡软了",
        "荤素搭配合理，营养比较均衡",
        "味道稳定，已经连吃三天了",
        "份量对女生来说偏多，吃不完",
    ],
    "MEAT": [
        "肉炖得很烂，入口即化",
        "有点咸，配米饭刚好",
        "分量一般，价格偏贵了点",
        "味道正宗，就是等的时间长",
        "肥瘦相间，不腻",
        "今天这份有点凉了，希望保温做好",
        "酱汁很下饭，能多来半碗饭",
        "偶尔会有筋膜，口感不太稳定",
        "颜色好看，看着就有食欲",
        "给的骨头偏多，肉少了些",
        "炖得入味，比外面的还香",
    ],
    "VEGETABLE": [
        "青菜很新鲜，颜色好看",
        "油不多，适合减脂",
        "分量偏少，一份不太够",
        "蒜香味足，炒得刚好不塌",
        "有点老，梗比较硬",
        "清淡健康，常点",
        "温度不太够，感觉放了有一会儿",
        "调味偏淡，但对身体好",
        "蔬菜很嫩，火候掌握得好",
        "希望多几种时令菜轮换",
    ],
    "NOODLE": [
        "面条劲道，汤头不错",
        "面条偏软，喜欢更硬的可以提前说",
        "汤底很鲜，喝着舒服",
        "分量足，一碗吃得很饱",
        "配菜少了一些，希望能加点青菜",
        "出餐快，热乎的",
        "有点咸，下次少放点盐",
        "面汤温度刚好，冬天吃很舒服",
        "面条煮得有点过，坨了",
        "加个卤蛋会更好",
        "面条是手擀的，口感很好",
        "汤头浓郁，喝到见底",
        "端上来就凉了，希望能保温",
        "面条粘成一团，拌不开",
        "配料给得实在，牛肉块也不小",
        "等了快二十分钟才拿到",
        "香菜给得太多，盖过了面的味道",
        "汤有点浑，看着不太清爽",
        "价格合适，学生党友好",
        "分量偏少，一碗没吃饱",
        "面条有嚼劲，比外面的馆子不差",
        "碗太大汤太少，比例奇怪",
        "葱花撒得均匀，卖相不错",
        "面有点硬，像是没煮透",
        "加辣很带劲，推荐重口的试试",
        "汤里飘着一层油，有点腻",
        "面条断得比较多，碎",
        "早上去人少，出餐特别快",
        "味道偏淡，需要自己加调料",
        "整体稳定，每周会来两三次",
    ],
    "SOUP": [
        "汤底很鲜，饭前喝一碗很舒服",
        "温度刚好，暖胃",
        "料有点少，主要是汤",
        "味道清淡，适合搭配主食",
        "有点咸，希望淡一点",
        "分量足，一碗喝得很满足",
        "汤色清亮，看着干净",
        "料给得足，捞得到东西",
        "稍微有点油花，不碍事",
        "菌菇的香味很浓，喝完很舒服",
        "勺子有点小，捞料不太方便",
        "汤是温的，不够热",
        "冬天喝这个很治愈",
        "汤里料很实在，不止是清汤",
        "喝到最后有点咸",
        "上得很快，配饭刚好",
        "汤面飘着葱花，看着有食欲",
        "份量偏小，几口就见底了",
        "味道稳定，每次水平差不多",
        "汤有点浑浊，不像现熬的",
        "价格便宜，性价比高",
        "香菜味太重，不吃香菜的慎点",
        "喝完不口干，说明味精不多",
        "汤和料的比例有点失衡",
        "端过来的时候碗沿有点烫手",
        "比想象中清淡，适合减脂期",
        "料切的块有点大，不太好舀",
        "整整一碗都喝完了，很满足",
        "希望能加个配汤的面包或馒头",
        "偶尔会有点咸，不太稳定",
    ],
    "DRINK": [
        "甜度控制得不错，不会太腻",
        "冰的量很足，夏天喝着爽",
        "价格便宜，解渴",
        "有点太甜了，希望能选无糖",
        "杯子偏小，几口就没了",
        "包装干净，吸管给得很到位",
        "口味稳定，常买",
        "温度合适，不会太冰",
        "量有点少，价格可以再低点",
        "喝着清爽，饭后解腻",
    ],
}

# 变体后缀按情感分区，避免「负面评语 + 正面后缀」的违和
VARIANTS_POSITIVE = [
    "",
    "，整体很满意",
    "，下次还会点",
    "，希望保持这个水准",
    "，值得推荐",
    "，室友也觉得不错",
    "，会安利给同学",
]

VARIANTS_MILD = [
    "",
    "，整体还行",
    "，但希望能改进",
    "，不功不过",
    "，还可以再优化",
]

VARIANTS_NEGATIVE = [
    "",
    "，有点失望",
    "，不太推荐",
    "，希望改进",
    "，下次可能不点了",
    "，体验一般",
]


def variant_pool(level):
    if level == "negative":
        return VARIANTS_NEGATIVE
    if level == "mild":
        return VARIANTS_MILD
    return VARIANTS_POSITIVE

KNOWN_DISH_WORDS = sorted(set(NAME_MAP.keys()), key=len, reverse=True)

RATING_PLAN = [5] * 45 + [4] * 30 + [3] * 12 + [2] * 8 + [1] * 5

# 负面词：命中则限制最高星级
NEGATIVE_STRONG = [
    "又贵又少", "完全不值", "太甜了", "坨了", "有点老", "骨头偏多",
    "不太够", "凉了", "有点咸", "偏咸", "油有点大", "油稍微大",
    "等的时间长", "排队", "出餐可以再快点", "等得有点久", "等了好久",
    "份量偏少", "菜码偏少", "量有点少", "分量偏少", "分量一般",
    "价格偏贵", "贵了", "不好吃", "不新鲜", "太咸", "太油",
]
NEGATIVE_MILD = [
    "还行", "一般", "不太稳定", "希望", "可以再", "能再",
    "有点硬", "偏软", "偏淡", "有点凉", "温度不太够",
    "少了些", "少了一些", "有点多",
]
POSITIVE = [
    "好吃", "很鲜", "新鲜", "实在", "大方", "入味", "劲道", "干净",
    "舒服", "满足", "稳定", "均衡", "值得推荐", "满意", "好看",
    "利索", "刚好", "大方", "清爽", "香",
]


def sentiment_ceiling(content):
    """根据评语情感返回允许的最高星级。"""
    text = content or ""
    strong = sum(1 for w in NEGATIVE_STRONG if w in text)
    mild = sum(1 for w in NEGATIVE_MILD if w in text)
    if strong >= 1:
        # 明确抱怨：最高 3 星
        return 3
    if mild >= 1:
        # 有保留意见：最高 4 星
        return 4
    return 5


def sentiment_level(content):
    """三档情感：positive / mild / negative。"""
    text = content or ""
    strong = sum(1 for w in NEGATIVE_STRONG if w in text)
    mild = sum(1 for w in NEGATIVE_MILD if w in text)
    if strong >= 1:
        return "negative"
    if mild >= 1:
        return "mild"
    return "positive"



def extract_values(sql, table):
    m = re.search(r"INSERT INTO %s\s*\([^)]*\)\s*VALUES\s*(.*?);" % table, sql, re.S)
    return m.group(1) if m else None


def split_rows(values):
    rows, depth, cur, in_str = [], 0, "", False
    i = 0
    while i < len(values):
        ch = values[i]
        if in_str:
            cur += ch
            if ch == "'":
                if i + 1 < len(values) and values[i + 1] == "'":
                    cur += "'"
                    i += 2
                    continue
                in_str = False
        else:
            if ch == "'":
                in_str = True
                cur += ch
            elif ch == "(":
                depth += 1
                if depth == 1:
                    cur = ""
                else:
                    cur += ch
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    rows.append(cur)
                else:
                    cur += ch
            elif depth >= 1:
                cur += ch
        i += 1
    return rows


def split_fields(row):
    out, cur, in_str = [], "", False
    i = 0
    while i < len(row):
        ch = row[i]
        if in_str:
            if ch == "'":
                if i + 1 < len(row) and row[i + 1] == "'":
                    cur += "'"
                    i += 2
                    continue
                in_str = False
            else:
                cur += ch
        else:
            if ch == "'":
                in_str = True
            elif ch == ",":
                out.append(cur.strip())
                cur = ""
            else:
                cur += ch
        i += 1
    out.append(cur.strip())
    return out


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def rewrite_content(content, target_name):
    if not content:
        return None
    text = content
    replaced = False
    for word in KNOWN_DISH_WORDS:
        if word in text:
            text = text.replace(word, target_name)
            replaced = True
    text = re.sub(r"(%s)(\s*%s)+" % (re.escape(target_name), re.escape(target_name)), target_name, text)
    if not replaced and len(text) < 8:
        return None
    return text.strip()


def main():
    with io.open(REF_SQL, encoding="utf-8") as f:
        sql = f.read()

    ref_dish_names = {}
    for r in split_rows(extract_values(sql, "dish")):
        f = split_fields(r)
        if len(f) >= 2:
            ref_dish_names[f[0]] = f[1].strip()

    by_code = {}
    for r in split_rows(extract_values(sql, "dish_review")):
        f = split_fields(r)
        if len(f) < 4:
            continue
        content = f[3].strip()
        if not content:
            continue
        ref_name = ref_dish_names.get(f[0])
        code = NAME_MAP.get(ref_name)
        if not code:
            continue
        by_code.setdefault(code, []).append(content)

    rng = random.Random(20261102)
    now = datetime.now()

    rows = []
    seq = 0
    for code, (name, cat) in PROJECT_DISHES.items():
        target = rng.randint(52, 68)
        pool_ref = by_code.get(code, [])
        pool_generic = GENERIC.get(cat, GENERIC["MAIN_MEAL"])

        # 先把候选评语按情感分层
        candidates = {"positive": [], "mild": [], "negative": []}
        for attempt in range(400):
            if pool_ref and rng.random() < 0.55:
                c = rewrite_content(rng.choice(pool_ref), name)
            else:
                c = rng.choice(pool_generic)
            if not c or c in candidates["positive"] or c in candidates["mild"] or c in candidates["negative"]:
                continue
            s = sentiment_level(c)
            candidates[s].append(c)
            if all(len(v) >= 12 for v in candidates.values()):
                break

        # 为「基础评语 → 变体」准备索引
        used = set()
        made = 0
        cursor = {"positive": 0, "mild": 0, "negative": 0}
        guard = 0
        while made < target and guard < target * 40:
            guard += 1
            # 按目标星级决定需要哪种情感的评语
            want = RATING_PLAN[(seq + made) % len(RATING_PLAN)]
            if want >= 5:
                level = "positive"
            elif want == 4:
                level = "mild" if candidates["mild"] and rng.random() < 0.5 else "positive"
            else:
                level = "negative" if candidates["negative"] else "mild"

            pool_lv = candidates[level]
            if not pool_lv:
                level = "positive"
                pool_lv = candidates["positive"]
            if not pool_lv:
                break

            idx = cursor[level] % len(pool_lv)
            cursor[level] += 1
            base = pool_lv[idx]

            pool_v = variant_pool(level)
            hit = sum(1 for u in used if u.startswith(base))
            if hit > 0:
                suffix = pool_v[hit % len(pool_v)]
                if not suffix:
                    continue
                base = base + suffix
            if base in used:
                continue
            used.add(base)

            rating = want
            days_ago = rng.randint(0, 89)
            ts = (now - timedelta(days=days_ago)).replace(
                hour=rng.choice([11, 12, 13, 17, 18, 19]),
                minute=rng.randint(0, 59),
                second=rng.randint(0, 59))
            rows.append({
                "code": code, "rating": rating,
                "content": base, "ts": ts.strftime("%Y-%m-%d %H:%M:%S"),
            })
            made += 1
            seq += 1

    lines = []
    lines.append("-- =============================================================")
    lines.append("-- seed-dish-reviews.sql")
    lines.append("-- 来源：参考项目 canteen-feedback-system 的中文评价语料")
    lines.append("-- 生成脚本：tools/import_dish_reviews.py（幂等，可重复执行）")
    lines.append("--")
    lines.append("-- 共 %d 条评价，覆盖 %d 道菜" % (len(rows), len(PROJECT_DISHES)))
    lines.append("-- 评分分布：5星45% / 4星30% / 3星12% / 2星8% / 1星5%")
    lines.append("-- 时间重分布到今天往前 90 天；评语已改写为与菜品对应")
    lines.append("-- 重置数据请先执行 db/reset-dish-reviews.sql")
    lines.append("-- =============================================================")
    lines.append("")
    lines.append("SET NAMES utf8mb4;")
    lines.append("")

    for i in range(0, len(rows), 50):
        chunk = rows[i:i + 50]
        lines.append("INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)")
        lines.append("SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at")
        lines.append("FROM (")
        values = []
        for r in chunk:
            values.append(
                "  SELECT %s AS code, %d AS rating, %s AS content, %s AS created_at"
                % (sql_str(r["code"]), r["rating"], sql_str(r["content"]), sql_str(r["ts"])))
        lines.append("\n  UNION ALL\n".join(values))
        lines.append(") v")
        lines.append("JOIN dish d ON d.dish_code = v.code AND d.deleted = 0")
        lines.append("WHERE NOT EXISTS (")
        lines.append("  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content")
        lines.append(");")
        lines.append("")

    lines.append("-- 回填菜品评分聚合")
    lines.append("UPDATE dish d SET")
    lines.append("  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r "
                 "WHERE r.dish_id = d.id AND r.status = 'APPROVED'), 0),")
    lines.append("  review_count = (SELECT COUNT(*) FROM dish_review r "
                 "WHERE r.dish_id = d.id AND r.status = 'APPROVED');")
    lines.append("")
    lines.append("SELECT d.dish_code, d.name, d.avg_rating, d.review_count")
    lines.append("FROM dish d WHERE d.deleted = 0 ORDER BY d.dish_code;")
    lines.append("")
    lines.append("SELECT rating AS star, COUNT(*) AS cnt,")
    lines.append("       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM dish_review), 1) AS pct")
    lines.append("FROM dish_review GROUP BY rating ORDER BY rating DESC;")
    lines.append("")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    c = Counter(r["rating"] for r in rows)
    total = len(rows)
    print("生成完成：%d 条 -> %s" % (total, OUT))
    for star in [5, 4, 3, 2, 1]:
        print("  %d星: %4d (%.1f%%)" % (star, c[star], c[star] * 100.0 / total))
    per = Counter(r["code"] for r in rows)
    print("  各菜品条数:", dict(sorted(per.items())))


if __name__ == "__main__":
    main()
