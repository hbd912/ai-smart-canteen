"""
扩充菜品标签：现有标签只有 2 个维度，补充为 3~4 个。

标签体系（参考项目「评分 + 分类 + 招牌」的思路，扩展为多维度）：
1. 品类：主食 / 荤菜 / 素菜 / 面食 / 汤品 / 饮品 / 小吃
2. 口感：清淡 / 微辣 / 重口 / 酸甜 / 鲜香
3. 营养：高蛋白 / 低脂 / 高纤维 / 低热量 / 无添加糖
4. 人气：今日推荐 / 人气王 / 招牌

规则：按菜品分类 + 营养数据 + 推荐标记自动生成，保证语义合理。
"""
import io
import os
import subprocess

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
OUT = r"D:\AI\AI Contest\canteen\db\seed-dish-tags.sql"

CAT_LABEL = {
    "MAIN_MEAL": "主食",
    "MEAT": "荤菜",
    "VEGETABLE": "素菜",
    "NOODLE": "面食",
    "SOUP": "汤品",
    "DRINK": "饮品",
    "OTHER": "小吃",
}

# 按分类给固定的口感标签
TASTE_BY_CAT = {
    "MAIN_MEAL": ["鲜香"],
    "MEAT": ["鲜香"],
    "VEGETABLE": ["清淡"],
    "NOODLE": ["鲜香"],
    "SOUP": ["清淡"],
    "DRINK": ["清甜"],
    "OTHER": ["香脆"],
}

# 按菜名关键词给口感
SPICY_KEYWORDS = ["麻辣", "水煮", "香锅", "香辣", "辣", "干煸"]
SOUR_KEYWORDS = ["番茄", "酸甜", "糖醋"]
LIGHT_KEYWORDS = ["清炒", "时蔬", "沙拉", "西兰花", "清淡", "白切"]


def load_dishes():
    sql = ("SELECT d.dish_code, d.name, c.code, d.calories, d.protein_g, d.fat_g, "
           "d.fiber_g, d.sodium_mg, d.recommend_flag, d.sold_count "
           "FROM canteen_system.dish d "
           "JOIN canteen_system.dish_category c ON c.id = d.category_id "
           "WHERE d.deleted = 0 ORDER BY d.dish_code;")
    r = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                        "-N", "-B", "-e", sql],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    rows = []
    for line in r.stdout.strip().split("\n"):
        if not line.strip():
            continue
        p = line.split("\t")
        if len(p) >= 10:
            rows.append({
                "code": p[0].strip(), "name": p[1].strip(), "cat": p[2].strip(),
                "cal": float(p[3] or 0), "pro": float(p[4] or 0), "fat": float(p[5] or 0),
                "fib": float(p[6] or 0), "na": float(p[7] or 0),
                "rec": p[8].strip() == "1", "sold": int(p[9] or 0),
            })
    return rows


def build_tags(d):
    tags = []
    # 1) 品类
    cat_label = CAT_LABEL.get(d["cat"], "其他")

    # 2) 口感
    taste = list(TASTE_BY_CAT.get(d["cat"], ["鲜香"]))
    name = d["name"]
    if any(k in name for k in SPICY_KEYWORDS):
        taste = ["微辣"]
    elif any(k in name for k in SOUR_KEYWORDS):
        taste = ["酸甜"]
    elif any(k in name for k in LIGHT_KEYWORDS):
        taste = ["清淡"]

    # 3) 营养
    nutrition = []
    if d["pro"] >= 20:
        nutrition.append("高蛋白")
    if d["fat"] <= 12 and d["cat"] not in ("DRINK",):
        nutrition.append("低脂")
    if d["cal"] <= 200:
        nutrition.append("低热量")
    if d["fib"] >= 4:
        nutrition.append("高纤维")
    if d["cat"] == "DRINK" and d["cal"] <= 120:
        nutrition.append("无添加糖")

    # 4) 人气
    popularity = []
    if d["rec"]:
        popularity.append("今日推荐")
    if d["sold"] >= 40:
        popularity.append("人气王")

    # 组装：品类 + 口感 + 营养(最多2) + 人气(最多1)，控制在 3~4 个
    tags.append(cat_label)
    tags.extend(taste[:1])
    tags.extend(nutrition[:2])
    if popularity:
        tags.append(popularity[0])

    # 去重保序
    seen = set()
    out = []
    for t in tags:
        if t not in seen:
            seen.add(t)
            out.append(t)
    return out[:4]


def main():
    dishes = load_dishes()
    print("读取 %d 道菜" % len(dishes))

    lines = ["-- =============================================================",
             "-- seed-dish-tags.sql",
             "-- 扩充菜品标签为多维度（品类 + 口感 + 营养 + 人气）",
             "-- 生成脚本：tools/seed_tags.py（幂等，按 dish_code 更新）",
             "-- =============================================================",
             "", "SET NAMES utf8mb4;", ""]

    for d in dishes:
        tags = build_tags(d)
        arr = "JSON_ARRAY(" + ", ".join("'" + t.replace("'", "''") + "'" for t in tags) + ")"
        lines.append("-- %s %s" % (d["code"], d["name"]))
        lines.append("UPDATE dish SET tags_json = %s, updated_at = NOW() WHERE dish_code = '%s';"
                     % (arr, d["code"]))

    lines.append("")
    lines.append("SELECT dish_code, name, tags_json FROM dish WHERE deleted = 0 ORDER BY dish_code;")
    lines.append("")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    from collections import Counter
    all_tags = Counter()
    for d in dishes:
        for t in build_tags(d):
            all_tags[t] += 1
    print("标签种类 %d 个" % len(all_tags))
    for t, c in all_tags.most_common():
        print("  %-8s %d" % (t, c))


if __name__ == "__main__":
    main()
