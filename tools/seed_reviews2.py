"""生成全部菜品的评价数据（覆盖数据库全部菜品）。"""
import io
import os
import random
import re
import subprocess
from collections import Counter
from datetime import datetime, timedelta

REF_SQL = r"D:\AI\AI Contest\canteen-feedback-system\db\init-data.sql"
OUT = r"D:\AI\AI Contest\canteen\db\seed-dish-reviews.sql"
MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

CAT_MAP = {"主食": "MAIN_MEAL", "荤菜": "MEAT", "素菜": "VEGETABLE",
           "汤品": "SOUP", "小吃": "OTHER", "饮品": "DRINK", "甜品": "DRINK"}

GENERIC = {
 "MAIN_MEAL": ["分量很足，米饭给得实在，男生也吃得饱","菜码偏少，米饭多，希望荤素比例调一下","出餐很快，拿到手还是热的","味道不错，就是油稍微大了点","价格实惠，性价比高，常来吃","米饭有点硬，菜的味道还行","配菜新鲜，整体满意","有点咸，下次希望能少放点盐","中午排队等了十几分钟，出餐可以再快点","口味偏淡，适合清淡党","肉给得很大方，师傅人也好","汤汁有点多，米饭有点泡软了","荤素搭配合理，营养比较均衡","味道稳定，已经连吃三天了","份量对女生来说偏多，吃不完","锅巴很香，就是等的时间长","铁板很烫，端上来还在响"],
 "MEAT": ["肉炖得很烂，入口即化","有点咸，配米饭刚好","分量一般，价格偏贵了点","味道正宗，就是等的时间长","肥瘦相间，不腻","今天这份有点凉了，希望保温做好","酱汁很下饭，能多来半碗饭","偶尔会有筋膜，口感不太稳定","颜色好看，看着就有食欲","给的骨头偏多，肉少了些","炖得入味，比外面的还香","辣度可以选，这点很贴心"],
 "VEGETABLE": ["青菜很新鲜，颜色好看","油不多，适合减脂","分量偏少，一份不太够","蒜香味足，炒得刚好不塌","有点老，梗比较硬","清淡健康，常点","温度不太够，感觉放了有一会儿","调味偏淡，但对身体好","蔬菜很嫩，火候掌握得好","希望多几种时令菜轮换"],
 "NOODLE": ["面条劲道，汤头不错","面条偏软，喜欢更硬的可以提前说","汤底很鲜，喝着舒服","分量足，一碗吃得很饱","配菜少了一些，希望能加点青菜","出餐快，热乎的","有点咸，下次少放点盐","面汤温度刚好，冬天吃很舒服","面条煮得有点过，坨了","加个卤蛋会更好","面条是手擀的，口感很好","汤头浓郁，喝到见底","端上来就凉了，希望能保温","配料给得实在","等了快二十分钟才拿到"],
 "SOUP": ["汤底很鲜，饭前喝一碗很舒服","温度刚好，暖胃","料有点少，主要是汤","味道清淡，适合搭配主食","有点咸，希望淡一点","分量足，一碗喝得很满足","汤色清亮，看着干净","料给得足，捞得到东西","稍微有点油花，不碍事","冬天喝这个很治愈","汤里料很实在，不止是清汤","上得很快，配饭刚好","份量偏小，几口就见底了"],
 "DRINK": ["甜度控制得不错，不会太腻","冰的量很足，夏天喝着爽","价格便宜，解渴","有点太甜了，希望能选无糖","杯子偏小，几口就没了","包装干净，吸管给得很到位","口味稳定，常买","温度合适，不会太冰","量有点少，价格可以再低点","喝着清爽，饭后解腻","奶味很浓，甜度刚好","料给得实在，捞得到果肉"],
 "OTHER": ["现做的，拿到手还是烫的","个头不小，性价比可以","有点油炸味，希望换新油","当加餐刚好，不会太撑","味道不错，就是数量偏少","外皮酥脆，内里软嫩","冷了以后口感差挺多，建议趁热吃","价格对学生党友好"],
}

NEG_STRONG = ["又贵又少","完全不值","太甜了","坨了","有点老","骨头偏多","不太够","凉了","有点咸","偏咸","油有点大","油稍微大","等的时间长","排队","出餐可以再快点","等得有点久","等了好久","份量偏少","菜码偏少","量有点少","分量偏少","分量一般","价格偏贵","贵了","不好吃","不新鲜","太咸","太油","油炸味","希望保温","希望能换","数量偏少","口感差"]
NEG_MILD = ["还行","一般","不太稳定","希望","可以再","能再","有点硬","偏软","偏淡","有点凉","温度不太够","少了些","少了一些","有点多","就是"]

V_POS = ["", "，整体很满意", "，下次还会点", "，希望保持这个水准", "，值得推荐", "，会安利给同学"]
V_MILD = ["", "，整体还行", "，但希望能改进", "，不功不过", "，还可以再优化"]
V_NEG = ["", "，有点失望", "，不太推荐", "，希望改进", "，下次可能不点了"]


def vpool(level):
    return {"positive": V_POS, "mild": V_MILD, "negative": V_NEG}[level]


def sentiment(text):
    t = text or ""
    if any(w in t for w in NEG_STRONG):
        return "negative"
    if any(w in t for w in NEG_MILD):
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
                cur = "" if depth == 1 else cur + ch
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


def q(s):
    return "'" + s.replace("'", "''") + "'"


def load_dishes():
    sql = ("SELECT d.dish_code, d.name, c.code FROM canteen_system.dish d "
           "JOIN canteen_system.dish_category c ON c.id = d.category_id "
           "WHERE d.deleted = 0 ORDER BY d.dish_code;")
    r = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                        "-N", "-B", "-e", sql],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    out = []
    for line in r.stdout.strip().split("\n"):
        if not line.strip():
            continue
        p = line.split("\t")
        if len(p) >= 3:
            out.append((p[0].strip(), p[1].strip(), p[2].strip()))
    return out


def main():
    with io.open(REF_SQL, encoding="utf-8") as f:
        sql_text = f.read()

    ref_dishes = {}
    for row in split_rows(extract_values(sql_text, "dish")):
        f = split_fields(row)
        if len(f) >= 4:
            ref_dishes[f[0]] = (f[1].strip(), CAT_MAP.get(f[3], "MAIN_MEAL"))

    ref_reviews = {}
    for row in split_rows(extract_values(sql_text, "dish_review")):
        f = split_fields(row)
        if len(f) < 4 or not f[3].strip():
            continue
        info = ref_dishes.get(f[0])
        if info:
            ref_reviews.setdefault(info[0], []).append(f[3].strip())

    ref_by_cat = {}
    for nm, (rcat) in ref_dishes.items():
        for c in ref_reviews.get(nm, []):
            ref_by_cat.setdefault(rcat, []).append(c)

    dishes = load_dishes()
    print("读取 %d 道菜" % len(dishes))

    rng = random.Random(20261102)
    now = datetime.now()
    rows = []
    seq = 0
    all_names = sorted(ref_dishes.keys(), key=len, reverse=True)

    for code, name, cat in dishes:
        target = rng.randint(28, 42)
        exact = ref_reviews.get(name, [])
        pool_cat = ref_by_cat.get(cat, [])
        cand = {"positive": [], "mild": [], "negative": []}
        seen = set()
        for _ in range(1500):
            if exact and rng.random() < 0.65:
                c = rng.choice(exact)
            elif pool_cat:
                c = rng.choice(pool_cat)
                for other in all_names:
                    if other in c and other != name:
                        c = c.replace(other, name)
            else:
                c = rng.choice(GENERIC.get(cat, GENERIC["MAIN_MEAL"]))
            c = c.strip()
            if not c or c in seen:
                continue
            seen.add(c)
            cand[sentiment(c)].append(c)
            if all(len(v) >= 10 for v in cand.values()):
                break

        for level in ("positive", "mild", "negative"):
            if len(cand[level]) < 8:
                for w in GENERIC.get(cat, GENERIC["MAIN_MEAL"]):
                    if sentiment(w) == level and w not in seen:
                        cand[level].append(w)
                        seen.add(w)

        used = set()
        made = 0
        cursor = {"positive": 0, "mild": 0, "negative": 0}
        plan = [5]*45 + [4]*30 + [3]*12 + [2]*8 + [1]*5
        guard = 0
        while made < target and guard < target * 60:
            guard += 1
            want = plan[(seq + made) % len(plan)]
            level = "positive" if want >= 5 else ("mild" if want == 4 else "negative")
            if not cand[level]:
                level = "positive"
            pool = cand[level]
            if not pool:
                break
            base = pool[cursor[level] % len(pool)]
            cursor[level] += 1
            vp = vpool(level)
            hit = sum(1 for u in used if u.startswith(base))
            if hit > 0:
                sfx = vp[hit % len(vp)]
                if not sfx:
                    continue
                base = base + sfx
            if base in used:
                continue
            used.add(base)
            ts = (now - timedelta(days=rng.randint(0, 89))).replace(
                hour=rng.choice([11, 12, 13, 17, 18, 19]),
                minute=rng.randint(0, 59), second=rng.randint(0, 59))
            rows.append({"code": code, "rating": want, "content": base,
                         "ts": ts.strftime("%Y-%m-%d %H:%M:%S")})
            made += 1
            seq += 1

    lines = ["-- =============================================================",
             "-- seed-dish-reviews.sql",
             "-- 来源：参考项目 canteen-feedback-system 的中文评价语料",
             "-- 生成脚本：tools/seed_reviews2.py（幂等，可重复执行）",
             "--",
             "-- 共 %d 条评价，覆盖 %d 道菜" % (len(rows), len(dishes)),
             "-- 评分分布：5星45%% / 4星30%% / 3星12%% / 2星8%% / 1星5%%",
             "-- 评语情感与星级匹配；时间重分布到今天往前 90 天",
             "-- 重置数据请先执行 db/reset-dish-reviews.sql",
             "-- =============================================================",
             "", "SET NAMES utf8mb4;", ""]

    for i in range(0, len(rows), 50):
        chunk = rows[i:i+50]
        lines.append("INSERT INTO dish_review (dish_id, user_id, order_id, rating, content, anonymous, status, created_at)")
        lines.append("SELECT d.id, NULL, NULL, v.rating, v.content, 0, 'APPROVED', v.created_at")
        lines.append("FROM (")
        vals = ["  SELECT %s AS code, %d AS rating, %s AS content, %s AS created_at"
                % (q(r["code"]), r["rating"], q(r["content"]), q(r["ts"])) for r in chunk]
        lines.append("\n  UNION ALL\n".join(vals))
        lines.append(") v")
        lines.append("JOIN dish d ON d.dish_code = v.code AND d.deleted = 0")
        lines.append("WHERE NOT EXISTS (")
        lines.append("  SELECT 1 FROM dish_review r WHERE r.dish_id = d.id AND r.content = v.content")
        lines.append(");")
        lines.append("")

    lines.append("UPDATE dish d SET")
    lines.append("  avg_rating = COALESCE((SELECT ROUND(AVG(r.rating), 1) FROM dish_review r "
                 "WHERE r.dish_id = d.id AND r.status = 'APPROVED'), 0),")
    lines.append("  review_count = (SELECT COUNT(*) FROM dish_review r "
                 "WHERE r.dish_id = d.id AND r.status = 'APPROVED');")
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
    print("生成 %d 条评价" % total)
    for s in [5,4,3,2,1]:
        print("  %d星: %4d (%.1f%%)" % (s, c[s], c[s]*100.0/total))


if __name__ == "__main__":
    main()
