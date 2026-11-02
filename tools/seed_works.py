"""
生成「精选」作品流种子数据。

规则：
1. 作品关联真实的 dish_id，图片直接用该菜品的实拍图；
2. 作者用现有 sys_user；
3. 点赞数有梯度，形成「热门」排序效果；
4. 每个作品 0~5 条中文评论；
5. 幂等：按 (user_id, dish_id, title) 判重。
"""
import io
import os
import random
import subprocess
from datetime import datetime, timedelta

MYSQL = r"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
OUT = r"D:\AI\AI Contest\canteen\db\seed-works.sql"

# 作品模板：(菜品名, 标题, 正文, 基础点赞数)
WORK_TEMPLATES = [
    ("黑椒鸡排饭", "今天的午饭", "黑椒鸡排还是稳定的好吃，鸡排外酥里嫩，配的米饭量也足。就是中午排队有点久，建议错峰来。", 128),
    ("宫保鸡丁饭", "宫保鸡丁永远的神", "花生米很脆，鸡丁给得很大方，辣度刚好不呛。这道是我食堂必点，性价比很高。", 96),
    ("红烧排骨", "红烧排骨也太香了", "排骨炖得很烂，轻轻一抿就脱骨。酱汁拌饭绝了，我每次都多要一点汤汁。", 214),
    ("番茄牛腩饭", "番茄牛腩饭测评", "牛腩炖得软烂，番茄味很浓，汤汁泡饭非常好吃。唯一缺点是稍微咸了一点点。", 67),
    ("香菇滑鸡饭", "香菇滑鸡煲仔饭", "锅巴很香，香菇和鸡块的搭配很经典。等的时间有点长，大概15分钟，但值得。", 45),
    ("柠檬蜂蜜水", "夏天必点饮品", "柠檬蜂蜜水很清爽，甜度刚好不腻。吃完重口味的菜来一杯很解腻，价格也便宜。", 158),
    ("无糖豆浆", "无糖豆浆好评", "真的没加糖，喝起来是纯粹的豆香。配早饭很合适，比外面那些甜豆浆健康多了。", 82),
    ("清炒时蔬", "减脂期的救星", "油很少，青菜很新鲜，颜色也很好看。减脂期间我几乎每天都点这个，热量很低。", 173),
    ("水煮肉片", "水煮肉片够辣", "红油很香，肉片很嫩，底下还有豆芽和白菜。辣度对我来说有点顶，但真的好吃。", 119),
    ("麻婆豆腐", "麻婆豆腐测评", "豆腐很嫩，麻辣味很足，配米饭能吃两碗。价格只要8块，性价比无敌。", 201),
    ("牛肉拉面", "面条劲道", "面条是现拉的，很筋道。汤底清亮，牛肉片给得也不少。就是有点咸，下次让少放盐。", 76),
    ("杨枝甘露", "港式杨枝甘露", "芒果给得很实在，西米也够多。奶味浓郁，甜度适中。比外面奶茶店便宜一半还多。", 145),
    ("水晶虾饺皇", "虾饺真的很透亮", "皮薄得能看到里面的虾仁，一笼三个。虾仁很新鲜，吃起来有弹性。价格小贵但值得。", 89),
    ("蒜蓉西兰花", "清淡好吃", "蒜香味很足，西兰花炒得刚好，不塌也不生。很适合配重口味的菜一起吃。", 54),
    ("番茄炒蛋", "最家常的番茄炒蛋", "酸甜口，鸡蛋炒得很嫩，番茄给得也足。只要6块钱，是我吃土期的首选。", 167),
    ("香辣鸡腿铁板饭", "铁板滋滋响", "端上来的时候还在响，很香。鸡腿肉很嫩，配菜有青椒和洋葱。铁板很烫不要碰。", 133),
    ("新疆大盘鸡", "大盘鸡分量足", "两个人吃一份刚好，土豆很入味，鸡肉也不柴。配皮带面吸满汤汁，很绝。", 98),
    ("蜜汁叉烧饭", "叉烧饭甜咸适中", "叉烧切得很厚，蜜汁味很浓，配上卤蛋和青菜。酱汁泡饭很好吃，就是有点甜。", 111),
]

# 评论池：有褒有贬，提到具体维度
COMMENT_POOL = [
    "看着就好吃，明天也去点一份",
    "这家我也常吃，确实不错",
    "份量看着挺足的，价格也合适",
    "求问是哪个窗口的？",
    "我也是减脂党，学到了",
    "这个组合不错，下次试试",
    "照片拍得真好看",
    "同意，就是中午排队太久",
    "我吃过，味道确实稳定",
    "这种分享多来点，很有参考价值",
    "看起来比图片上的还香",
    "刚刚去吃了，确实没让我失望",
    "有点小贵，不过偶尔吃一次可以",
    "我也是每天必点这个",
    "收藏了，下次照着点",
    "这家的汤汁拌饭真的绝",
    "我室友也说好吃",
    "感觉分量比上学期少了点",
    "坐窗边吃这个心情会变好",
    "感谢分享，正愁不知道吃啥",
]


def load_data():
    user_sql = "SELECT id, username, nickname FROM canteen_system.sys_user ORDER BY id;"
    r = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                        "-N", "-B", "-e", user_sql],
                       capture_output=True, text=True, encoding="utf-8", errors="replace")
    users = []
    for line in r.stdout.strip().split("\n"):
        if not line.strip():
            continue
        p = line.split("\t")
        if len(p) >= 3:
            users.append({"id": int(p[0]), "username": p[1], "nickname": p[2]})

    dish_sql = ("SELECT dish_code, name, image_url FROM canteen_system.dish "
                "WHERE deleted = 0 ORDER BY dish_code;")
    r2 = subprocess.run([MYSQL, "-uroot", "-p123456", "--default-character-set=utf8mb4",
                         "-N", "-B", "-e", dish_sql],
                        capture_output=True, text=True, encoding="utf-8", errors="replace")
    dishes = {}
    for line in r2.stdout.strip().split("\n"):
        if not line.strip():
            continue
        p = line.split("\t")
        if len(p) >= 3:
            dishes[p[1]] = {"code": p[0], "image": p[2]}
    return users, dishes


def q(s):
    return "'" + s.replace("'", "''") + "'"


def main():
    users, dishes = load_data()
    if not users:
        print("没有用户，无法生成作品")
        return

    rng = random.Random(20261103)
    now = datetime.now()

    lines = ["-- =============================================================",
             "-- seed-works.sql",
             "-- 「精选」作品流种子数据",
             "-- 生成脚本：tools/seed_works.py（幂等）",
             "--",
             "-- 作品关联真实菜品，图片使用菜品实拍图；点赞数与评论数一并生成",
             "-- =============================================================",
             "", "SET NAMES utf8mb4;", ""]

    created = 0
    for idx, (dish_name, title, content, likes) in enumerate(WORK_TEMPLATES):
        dish = dishes.get(dish_name)
        if not dish:
            print("跳过（菜品不存在）：%s" % dish_name)
            continue

        author = users[idx % len(users)]
        days_ago = idx % 20
        ts = (now - timedelta(days=days_ago)).strftime("%Y-%m-%d %H:%M:%S")

        lines.append("-- 作品：%s" % title)
        lines.append(
            "INSERT INTO work (user_id, dish_id, title, content, images_json, like_count, comment_count, status, created_at, updated_at)"
        )
        lines.append(
            "SELECT %d, d.id, %s, %s, JSON_ARRAY(%s), %d, 0, 'APPROVED', %s, %s"
            % (author["id"], q(title), q(content), q(dish["image"]), likes, q(ts), q(ts))
        )
        lines.append("FROM dish d WHERE d.dish_code = %s" % q(dish["code"]))
        lines.append("AND NOT EXISTS (SELECT 1 FROM work w WHERE w.user_id = %d AND w.title = %s);"
                     % (author["id"], q(title)))
        lines.append("")

        # 评论
        n_comments = rng.randint(0, 5)
        for k in range(n_comments):
            cmt = COMMENT_POOL[(idx * 3 + k) % len(COMMENT_POOL)]
            cu = users[(idx + k + 1) % len(users)]
            cts = (now - timedelta(days=days_ago, hours=rng.randint(1, 20))).strftime("%Y-%m-%d %H:%M:%S")
            lines.append(
                "INSERT INTO work_comment (work_id, user_id, content, status, created_at)"
            )
            lines.append(
                "SELECT w.id, %d, %s, 'APPROVED', %s FROM work w WHERE w.title = %s"
                % (cu["id"], q(cmt), q(cts), q(title))
            )
            lines.append("AND NOT EXISTS (SELECT 1 FROM work_comment c WHERE c.work_id = w.id AND c.content = %s);"
                         % q(cmt))
        created += 1

    lines.append("")
    lines.append("-- 回填评论数与点赞数")
    lines.append("UPDATE work w SET")
    lines.append("  comment_count = (SELECT COUNT(*) FROM work_comment c WHERE c.work_id = w.id AND c.status='APPROVED'),")
    lines.append("  like_count = GREATEST(w.like_count, (SELECT COUNT(*) FROM work_like l WHERE l.work_id = w.id));")
    lines.append("")
    lines.append("SELECT w.id, w.title, d.name AS dish, w.like_count, w.comment_count")
    lines.append("FROM work w JOIN dish d ON d.id = w.dish_id ORDER BY w.like_count DESC;")
    lines.append("")

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with io.open(OUT, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))

    print("生成 %d 个作品 -> %s" % (created, OUT))


if __name__ == "__main__":
    main()
