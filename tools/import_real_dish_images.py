"""
把参考项目的真实菜品照片接入本项目。

来源（只读）：D:\\AI\\AI Contest\\canteen-feedback-system\\canteen-frontend\\public\\dishes\\*.jpg
目标：D:\\AI\\AI Contest\\canteen\\frontend\\public\\assets\\images\\dishes\\Dxxx.webp

处理要点：
1. 参考图 768x768，右下角有「AI生成 WORKBUDDY」水印，裁掉底部 9% 去掉水印；
2. 裁完再居中切成正方形，统一输出 800x800 webp（质量 88），体积可控且清晰；
3. 文件名沿用本项目 dish_code（D001~D012），数据库 image_url 无需改动。
"""
import io
import os

from PIL import Image

SRC_DIR = r"D:\AI\AI Contest\canteen-feedback-system\canteen-frontend\public\dishes"
OUT_DIR = r"D:\AI\AI Contest\canteen\frontend\public\assets\images\dishes"

# 当前菜品 -> 参考项目图片编号
MAPPING = [
    ("D001", "黑椒鸡排饭", "49", "黑椒牛柳铁板饭"),
    ("D002", "番茄牛腩饭", "38", "香菇滑鸡煲仔饭"),
    ("D003", "香菇滑鸡饭", "38", "香菇滑鸡煲仔饭"),
    ("D004", "宫保鸡丁饭", "1", "宫保鸡丁"),
    ("D005", "鱼香肉丝饭", "4", "鱼香肉丝"),
    ("D006", "清炒时蔬", "26", "缤纷时蔬沙拉"),
    ("D007", "香菇鸡丝面", "13", "老北京炸酱面"),
    ("D008", "菌菇汤", "48", "番茄炒蛋"),
    ("D009", "红烧排骨", "47", "红烧肉"),
    ("D010", "蒜蓉西兰花", "18", "素菜香锅"),
    ("D011", "柠檬蜂蜜水", "33", "杨枝甘露"),
    ("D012", "无糖豆浆", "35", "黑糖珍珠奶茶"),
]

# 底部裁切比例：去掉右下角水印
CROP_BOTTOM_RATIO = 0.11
OUT_SIZE = 800
QUALITY = 88

report = []

for code, name, ref_no, ref_name in MAPPING:
    src = os.path.join(SRC_DIR, f"{ref_no}.jpg")
    if not os.path.exists(src):
        report.append(f"缺失 {src}")
        continue

    im = Image.open(src).convert("RGB")
    w, h = im.size

    # 1) 裁掉底部（去水印）
    keep_h = int(h * (1 - CROP_BOTTOM_RATIO))
    im = im.crop((0, 0, w, keep_h))
    w2, h2 = im.size

    # 2) 居中切成正方形
    side = min(w2, h2)
    left = (w2 - side) // 2
    top = (h2 - side) // 2
    im = im.crop((left, top, left + side, top + side))

    # 3) 统一缩放到 800x800
    im = im.resize((OUT_SIZE, OUT_SIZE), Image.LANCZOS)

    out = os.path.join(OUT_DIR, f"{code}.webp")
    im.save(out, "WEBP", quality=QUALITY, method=6)
    size_kb = os.path.getsize(out) / 1024
    report.append(f"{code} {name:8s} <- {ref_no}.jpg({ref_name})  {size_kb:.1f} KB")

with io.open(r"D:\AI\AI Contest\canteen\.tmp_dish_img_report.txt", "w", encoding="utf-8") as f:
    f.write("\n".join(report))

print("\n".join(report))
