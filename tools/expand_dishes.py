"""
扩充菜品：从参考项目复用菜名 + 真实图片，补充到本项目。

参考项目 dish.id 与图片编号一一对应（1~52.jpg），本脚本按分类挑选，
跳过与现有 12 道菜重名的，生成幂等 SQL 与图片文件。

输出：
- frontend/public/assets/images/dishes/D013.webp ~ D0xx.webp
- db/seed-more-dishes.sql
"""
import io
import os

from PIL import Image

REF_IMG_DIR = r"D:\AI\AI Contest\canteen-feedback-system\canteen-frontend\public\dishes"
OUT_IMG_DIR = r"D:\AI\AI Contest\canteen\frontend\public\assets\images\dishes"
OUT_SQL = r"D:\AI\AI Contest\canteen\db\seed-more-dishes.sql"

# 当前已有菜品名（避免重复）
EXISTING = {
    "黑椒鸡排饭", "番茄牛腩饭", "香菇滑鸡饭", "宫保鸡丁饭", "鱼香肉丝饭",
    "清炒时蔬", "香菇鸡丝面", "菌菇汤", "红烧排骨", "蒜蓉西兰花",
    "柠檬蜂蜜水", "无糖豆浆",
}

# 本项目分类 code
CAT_MAIN = "MAIN_MEAL"
CAT_MEAT = "MEAT"
CAT_VEG = "VEGETABLE"
CAT_NOODLE = "NOODLE"
CAT_SOUP = "SOUP"
CAT_DRINK = "DRINK"
CAT_OTHER = "OTHER"

# 参考项目：img_no, 菜名, 价格, 本项目分类, 描述, 是否招牌
# 说明：优先挑与现有菜不重名、图片语义明确的；价格保持 5~30 元学生区间
NEW_DISHES = [
    # ---- 主食套餐（米饭类，补 7 道）----
    (6, "蜜汁叉烧饭", 15.00, CAT_MAIN, "半肥瘦叉烧，配青菜卤蛋", True),
    (8, "烧鸭饭", 16.00, CAT_MAIN, "广式烧鸭，皮脆肉嫩", True),
    (9, "豉汁排骨饭", 13.00, CAT_MAIN, "豉汁蒸排骨，配米饭", False),
    (10, "卤水双拼饭", 17.00, CAT_MAIN, "卤水双拼，可选两样", False),
    (37, "腊味煲仔饭", 18.00, CAT_MAIN, "腊肠腊肉，锅巴香脆", True),
    (40, "窝蛋牛肉煲仔饭", 16.00, CAT_MAIN, "窝蛋牛肉，镬气十足", False),
    (49, "黑椒牛柳铁板饭", 20.00, CAT_MAIN, "黑椒牛柳，铁板现打", True),
    (50, "香辣鸡腿铁板饭", 18.00, CAT_MAIN, "香辣鸡腿，铁板滋滋响", False),

    # ---- 荤菜（补 6 道）----
    (3, "水煮肉片", 16.00, CAT_MEAT, "里脊肉片，红油现泼", True),
    (16, "麻辣香锅小份", 20.00, CAT_MEAT, "三十余种食材自选，称重计费", True),
    (22, "新疆大盘鸡", 22.00, CAT_MEAT, "大盘鸡，配皮带面", False),
    (23, "牛肉小炒", 16.00, CAT_MEAT, "鲜切牛肉，猛火爆炒", False),
    (47, "红烧肉", 10.00, CAT_MEAT, "肥瘦相间，浓油赤酱", True),
    (31, "豉汁蒸凤爪", 12.00, CAT_MEAT, "豉汁凤爪，软糯脱骨", False),

    # ---- 素菜（补 5 道）----
    (2, "麻婆豆腐", 8.00, CAT_VEG, "嫩豆腐配牛肉末，麻辣鲜香", False),
    (5, "干煸豆角", 9.00, CAT_VEG, "四季豆干煸，配肉末", False),
    (18, "素菜香锅", 15.00, CAT_VEG, "十余种素菜自选，称重计费", False),
    (43, "韭菜鸡蛋水饺", 11.00, CAT_VEG, "韭菜鸡蛋馅，素馅清爽", False),
    (48, "番茄炒蛋", 6.00, CAT_VEG, "家常番茄炒蛋，酸甜下饭", True),

    # ---- 面食（补 5 道）----
    (11, "牛肉拉面", 12.00, CAT_NOODLE, "一清二白三红四绿", True),
    (12, "番茄鸡蛋面", 10.00, CAT_NOODLE, "酸甜开胃，手工细面", False),
    (13, "老北京炸酱面", 11.00, CAT_NOODLE, "手擀面配六必居酱", False),
    (14, "山西刀削面", 12.00, CAT_NOODLE, "刀削面，面片筋道", True),
    (30, "豉汁蒸肠粉", 10.00, CAT_NOODLE, "现蒸肠粉，滑嫩爽口", False),

    # ---- 汤品（补 3 道）----
    (20, "羊肉泡馍", 18.00, CAT_SOUP, "羊汤配馍，自己掰更香", True),
    (45, "两荤一素套餐", 14.00, CAT_SOUP, "自选两荤一素，配例汤", False),
    (46, "一荤两素套餐", 12.00, CAT_SOUP, "自选一荤两素，配例汤", False),

    # ---- 饮品 / 甜品（补 5 道）----
    (33, "杨枝甘露", 12.00, CAT_DRINK, "芒果西柚西米，港式经典", True),
    (34, "顺德双皮奶", 8.00, CAT_DRINK, "顺德双皮奶，奶味浓郁", True),
    (35, "黑糖珍珠奶茶", 7.00, CAT_DRINK, "黑糖珍珠，现煮弹牙", False),
    (36, "芋泥啵啵奶茶", 9.00, CAT_DRINK, "芋泥啵啵，口感绵密", False),

    # ---- 小吃 / 其他（补 4 道）----
    (21, "烤羊肉串", 5.00, CAT_OTHER, "现烤羊肉串，孜然味足", False),
    (28, "水晶虾饺皇", 18.00, CAT_OTHER, "水晶皮透亮，整只虾仁", True),
    (29, "爆浆流沙包", 12.00, CAT_OTHER, "咸蛋黄流沙，爆浆留心", False),
    (32, "糯米鸡", 10.00, CAT_OTHER, "荷叶糯米鸡，料足实在", False),
]

# 营养估算：按分类给合理区间（kcal, 蛋白, 脂肪, 碳水, 纤维, 钠）
NUTRITION = {
    CAT_MAIN: (420, 520, 18, 26, 12, 20, 45, 65, 2, 5, 550, 900),
    CAT_MEAT: (380, 560, 22, 34, 20, 32, 30, 55, 0.5, 2, 600, 1000),
    CAT_VEG: (90, 220, 3, 9, 3, 12, 8, 22, 3, 7, 200, 600),
    CAT_NOODLE: (350, 500, 12, 22, 8, 18, 50, 70, 2, 4, 500, 900),
    CAT_SOUP: (120, 320, 8, 20, 5, 15, 15, 40, 1, 3, 400, 800),
    CAT_DRINK: (70, 260, 0, 5, 0, 8, 10, 45, 0, 1, 5, 80),
    CAT_OTHER: (150, 400, 4, 16, 5, 16, 15, 45, 1, 3, 200, 700),
}

TAGS = {
    CAT_MAIN: ["主食", "经典"],
    CAT_MEAT: ["荤菜", "经典"],
    CAT_VEG: ["素菜", "清淡"],
    CAT_NOODLE: ["面食", "经典"],
    CAT_SOUP: ["汤品", "暖胃"],
    CAT_DRINK: ["饮品", "无添加糖"],
    CAT_OTHER: ["小吃", "经典"],
}


def process_image(img_no, code):
    src = os.path.join(REF_IMG_DIR, f"{img_no}.jpg")
    if not os.path.exists(src):
        return None
    im = Image.open(src).convert("RGB")
    w, h = im.size
    # 裁掉底部水印
    keep = int(h * 0.89)
    im = im.crop((0, 0, w, keep))
    w2, h2 = im.size
    side = min(w2, h2)
    left = (w2 - side) // 2
    top = (h2 - side) // 2
    im = im.crop((left, top, left + side, top + side))
    im = im.resize((800, 800), Image.LANCZOS)
    out = os.path.join(OUT_IMG_DIR, f"{code}.webp")
    im.save(out, "WEBP", quality=88, method=6)
    return os.path.getsize(out) / 1024


def sql_str(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    import random
    rng = random.Random(20261102)

    rows = []
    made = 0
    start_no = 13
    for img_no, name, price, cat, desc, featured in NEW_DISHES:
        if name in EXISTING:
            continue
        code = f"D{start_no + made:03d}"
        kb = process_image(img_no, code)
        if kb is None:
            print(f"跳过 {name}：缺少 {img_no}.jpg")
            continue

        rng_c = NUTRITION[cat]
        cal = rng.randint(rng_c[0], rng_c[1])
        pro = round(rng.uniform(rng_c[2], rng_c[3]), 1)
        fat = round(rng.uniform(rng_c[4], rng_c[5]), 1)
        carb = rng.randint(rng_c[6], rng_c[7])
        fib = round(rng.uniform(rng_c[8], rng_c[9]), 1)
        na = rng.randint(rng_c[10], rng_c[11])
        stock = rng.randint(20, 60)
        tags = TAGS[cat]
        rows.append({
            "code": code, "name": name, "price": price, "cat": cat,
            "desc": desc, "featured": featured, "img_kb": kb,
            "cal": cal, "pro": pro, "fat": fat, "carb": carb, "fib": fib, "na": na,
            "stock": stock, "tags": tags,
        })
        made += 1

    lines = []
    lines.append("-- =============================================================")
    lines.append("-- seed-more-dishes.sql")
    lines.append("-- 扩充菜品：从参考项目复用菜名与真实图片")
    lines.append("-- 生成脚本：tools/expand_dishes.py（幂等，按 dish_code 判重）")
    lines.append("--")
    lines.append(f"-- 新增 {len(rows)} 道菜（D013 起），图片已同步到 assets/images/dishes/")
    lines.append("-- =============================================================")
    lines.append("")
    lines.append("SET NAMES utf8mb4;")
    lines.append("")

    for r in rows:
        tags_json = "JSON_ARRAY(" + ", ".join(sql_str(t) for t in r["tags"]) + ")"
        lines.append("-- " + r["name"])
        lines.append("INSERT INTO dish (category_id, dish_code, name, description, ingredients_json, allergens_json, image_url,")
        lines.append("  price, calories, protein_g, fat_g, carbohydrate_g, fiber_g, sodium_mg,")
        lines.append("  nutrition_source, nutrition_note, stock, sold_count, supply_status, publish_status,")
        lines.append("  recommend_flag, recommend_rank, tags_json, sort_order, created_at, updated_at, deleted)")
        lines.append("SELECT c.id, %s, %s, %s, JSON_ARRAY(), JSON_ARRAY('配方待食堂核实'), %s,"
                     % (sql_str(r["code"]), sql_str(r["name"]), sql_str(r["desc"]),
                        sql_str(f"/assets/images/dishes/{r['code']}.webp")))
        lines.append("  %.2f, %d, %.1f, %.1f, %d, %.1f, %d, 'ESTIMATED', '课堂演示估算值，非实验室检测数据',"
                     % (r["price"], r["cal"], r["pro"], r["fat"], r["carb"], r["fib"], r["na"]))
        lines.append("  %d, 0, 'AVAILABLE', 'PUBLISHED', %d, 0, %s, 200, NOW(), NOW(), 0"
                     % (r["stock"], 1 if r["featured"] else 0, tags_json))
        lines.append("FROM dish_category c WHERE c.code = %s" % sql_str(r["cat"]))
        lines.append("ON DUPLICATE KEY UPDATE name=VALUES(name), price=VALUES(price), "
                     "description=VALUES(description), image_url=VALUES(image_url), updated_at=NOW();")
        lines.append("")

    lines.append("-- 核验")
    lines.append("SELECT c.code AS category, COUNT(d.id) AS cnt")
    lines.append("FROM dish_category c LEFT JOIN dish d ON d.category_id = c.id AND d.deleted = 0")
    lines.append("GROUP BY c.id ORDER BY c.sort_order;")
    lines.append("")
    lines.append("SELECT COUNT(*) AS total_dishes FROM dish WHERE deleted = 0;")
    lines.append("")

    os.makedirs(os.path.dirname(OUT_SQL), exist_ok=True)
    with io.open(OUT_SQL, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print(f"新增 {len(rows)} 道菜 -> {OUT_SQL}")
    from collections import Counter
    print("分类分布:", dict(Counter(r["cat"] for r in rows)))
    print("图片体积范围: %.1f ~ %.1f KB" % (min(r["img_kb"] for r in rows), max(r["img_kb"] for r in rows)))


if __name__ == "__main__":
    main()
