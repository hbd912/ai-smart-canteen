"""生成菜品示意插画（本地程序绘制的示意图，非食堂实拍照片）。

说明：
- 项目未获得 12 道菜的实拍照片，因此按需求文档 20.4 规则使用统一风格的本地占位视觉。
- 输出 4:3 webp，文件名与 dish_code 一致，数据库 image_url 指向 /assets/images/dishes/Dxxx.webp。
- 右下角带"示意图片"水印，UI 详情页也会标注，不冒充食堂实物照片。
"""
import math
import os
import random

from PIL import Image, ImageDraw, ImageFilter, ImageFont

OUT_DIR = r"D:\AI\AI Contest\canteen\frontend\public\assets\images\dishes"
FONT_CANDIDATES = [
    r"C:\Windows\Fonts\msyh.ttc",
    r"C:\Windows\Fonts\msyhbd.ttc",
    r"C:\Windows\Fonts\simhei.ttf",
]

W, H = 800, 600

DISHES = [
    ("D001", "黑椒鸡排饭", (188, 126, 72), (150, 96, 56), (250, 248, 238), "rice_meat"),
    ("D002", "番茄牛腩饭", (198, 92, 66), (168, 70, 52), (250, 248, 238), "rice_stew"),
    ("D003", "香菇滑鸡饭", (206, 168, 108), (168, 132, 82), (250, 248, 238), "rice_meat"),
    ("D004", "宫保鸡丁饭", (204, 126, 74), (172, 86, 58), (250, 248, 238), "rice_diced"),
    ("D005", "鱼香肉丝饭", (190, 108, 76), (156, 82, 60), (250, 248, 238), "rice_shred"),
    ("D006", "清炒时蔬", (108, 150, 86), (78, 122, 68), (250, 248, 238), "greens"),
    ("D007", "香菇鸡丝面", (232, 206, 152), (196, 164, 108), (250, 246, 232), "noodle"),
    ("D008", "菌菇汤", (222, 200, 160), (188, 160, 118), (246, 240, 226), "soup"),
    ("D009", "红烧排骨", (162, 82, 58), (128, 62, 44), (250, 248, 238), "ribs"),
    ("D010", "蒜蓉西兰花", (94, 144, 80), (70, 118, 62), (250, 248, 238), "broccoli"),
    ("D011", "柠檬蜂蜜水", (240, 206, 118), (208, 226, 138), (255, 252, 244), "drink"),
    ("D012", "无糖豆浆", (238, 232, 214), (214, 204, 178), (255, 253, 248), "drink"),
]


def load_font(size: int):
    for path in FONT_CANDIDATES:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except OSError:
                continue
    return ImageFont.load_default()


def gradient_background(top, bottom):
    img = Image.new("RGB", (W, H), top)
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        color = tuple(int(top[i] + (bottom[i] - top[i]) * t) for i in range(3))
        draw.line([(0, y), (W, y)], fill=color)
    return img


def soft_light(img, cx, cy, radius, color, alpha=110):
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    d.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=color + (alpha,))
    layer = layer.filter(ImageFilter.GaussianBlur(radius * 0.6))
    img.alpha_composite(layer)


def blob(draw, cx, cy, rx, ry, color, angle=0.0, steps=28, wobble=0.10):
    pts = []
    for i in range(steps):
        a = 2 * math.pi * i / steps
        w = 1 + wobble * math.sin(a * 3 + angle) + 0.05 * math.sin(a * 5 - angle)
        x = rx * w * math.cos(a)
        y = ry * w * math.sin(a)
        pts.append((cx + x * math.cos(angle) - y * math.sin(angle),
                    cy + x * math.sin(angle) + y * math.cos(angle)))
    draw.polygon(pts, fill=color)


def draw_plate(draw, cx, cy, r):
    draw.ellipse([cx - r - 8, cy - r + 14, cx + r + 8, cy + r + 30], fill=(126, 114, 92, 40))
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 253, 247, 252))
    draw.ellipse([cx - r + 7, cy - r + 7, cx + r - 7, cy + r - 7], fill=(248, 244, 234, 255))
    inner = int(r * 0.82)
    draw.ellipse([cx - inner, cy - inner, cx + inner, cy + inner], fill=(255, 253, 248, 255))
    draw.ellipse([cx - inner, cy - inner, cx + inner, cy + inner],
                 outline=(228, 219, 201, 255), width=3)


def scatter_rice(draw, cx, cy, rx, ry, rng, count=280):
    for _ in range(count):
        a = rng.uniform(0, 2 * math.pi)
        rr = math.sqrt(rng.uniform(0, 1))
        px = cx + rx * rr * math.cos(a)
        py = cy + ry * rr * math.sin(a)
        s = rng.uniform(2.2, 4.0)
        shade = rng.randint(232, 250)
        draw.ellipse([px, py, px + s, py + s * 0.86],
                     fill=(shade, shade - 6, shade - 24, 245))


def food_shadow(draw, cx, cy, rx, ry, alpha=54):
    draw.ellipse([cx - rx, cy - ry + 10, cx + rx, cy + ry + 16], fill=(140, 124, 98, alpha))


def draw_garnish(draw, cx, cy, r, rng, count=5):
    for _ in range(count):
        a = rng.uniform(0, 2 * math.pi)
        rr = rng.uniform(r * 0.46, r * 0.68)
        px = cx + rr * math.cos(a)
        py = cy + rr * math.sin(a)
        draw.ellipse([px - 13, py - 13, px + 13, py + 13], fill=(104, 144, 82, 255))
        draw.ellipse([px - 7, py - 7, px + 7, py + 7], fill=(130, 170, 100, 255))
        draw.ellipse([px - 3, py - 3, px + 3, py + 3], fill=(158, 194, 124, 255))


def draw_food(draw, kind, cx, cy, r, primary, secondary, rice, rng):
    if kind in ("rice_meat", "rice_stew", "rice_diced", "rice_shred"):
        # 米饭：左下方一大团
        rcx, rcy = cx - int(r * 0.32), cy + int(r * 0.16)
        food_shadow(draw, rcx, rcy, int(r * 0.48), int(r * 0.36))
        blob(draw, rcx, rcy, int(r * 0.48), int(r * 0.37), (252, 250, 242, 255), 0.4)
        blob(draw, rcx, rcy - int(r * 0.04), int(r * 0.44), int(r * 0.32), rice + (255,), 0.7)
        scatter_rice(draw, rcx, rcy, int(r * 0.42), int(r * 0.30), rng)

        # 主菜：右上方一大团
        mcx, mcy = cx + int(r * 0.30), cy - int(r * 0.14)
        food_shadow(draw, mcx, mcy, int(r * 0.50), int(r * 0.38))
        blob(draw, mcx, mcy, int(r * 0.52), int(r * 0.41), primary + (255,), 0.9)
        blob(draw, mcx - int(r * 0.12), mcy + int(r * 0.12), int(r * 0.34), int(r * 0.25),
             secondary + (245,), 1.6)
        blob(draw, mcx + int(r * 0.14), mcy - int(r * 0.10), int(r * 0.26), int(r * 0.19),
             secondary + (170,), 2.4)

        if kind == "rice_diced":
            for _ in range(26):
                a = rng.uniform(0, 2 * math.pi)
                rr = math.sqrt(rng.uniform(0, 1))
                px = mcx + int(r * 0.44) * rr * math.cos(a)
                py = mcy + int(r * 0.34) * rr * math.sin(a)
                s = rng.uniform(10, 16)
                draw.rounded_rectangle([px, py, px + s, py + s], radius=3, fill=primary + (255,))
                draw.rounded_rectangle([px + 2, py + 2, px + s - 3, py + s * 0.6], radius=2,
                                       fill=secondary + (200,))
                if rng.random() > 0.55:
                    draw.ellipse([px + 4, py + 4, px + 9, py + 9], fill=(236, 214, 176, 255))
        elif kind == "rice_shred":
            for _ in range(30):
                x0 = mcx + rng.randint(-int(r * 0.40), int(r * 0.34))
                y0 = mcy + rng.randint(-int(r * 0.30), int(r * 0.30))
                dx = rng.randint(18, 40)
                dy = rng.randint(-8, 8)
                draw.line([x0, y0, x0 + dx, y0 + dy], fill=primary + (255,), width=6)
                draw.line([x0 + 4, y0 + 7, x0 + dx - 2, y0 + 7 + dy], fill=secondary + (215,), width=4)
        else:
            # 肉块/鸡排纹理
            for _ in range(16):
                a = rng.uniform(0, 2 * math.pi)
                rr = math.sqrt(rng.uniform(0, 1))
                px = mcx + int(r * 0.40) * rr * math.cos(a)
                py = mcy + int(r * 0.30) * rr * math.sin(a)
                w = rng.randint(16, 30)
                h = rng.randint(10, 18)
                draw.ellipse([px, py, px + w, py + h], fill=secondary + (190,))
                draw.arc([px, py, px + w, py + h], 200, 340, fill=(255, 244, 226, 150), width=2)
        draw_garnish(draw, cx, cy, r, rng, 4)

    elif kind == "greens":
        food_shadow(draw, cx, cy, int(r * 0.58), int(r * 0.46), 44)
        for i in range(22):
            a = rng.uniform(0, 2 * math.pi)
            rr = math.sqrt(rng.uniform(0, 1)) * r * 0.58
            px = cx + rr * math.cos(a)
            py = cy + rr * math.sin(a)
            g = rng.randint(136, 174)
            blob(draw, int(px), int(py), rng.randint(34, 52), rng.randint(20, 32),
                 (rng.randint(86, 116), g, rng.randint(70, 96), 255), rng.uniform(0, 3), 26, 0.15)
            draw.line([px, py, px + rng.randint(-20, 20), py + rng.randint(12, 30)],
                      fill=(206, 228, 176, 210), width=4)
        for _ in range(14):
            a = rng.uniform(0, 2 * math.pi)
            rr = rng.uniform(0, r * 0.48)
            px = cx + rr * math.cos(a)
            py = cy + rr * math.sin(a)
            draw.ellipse([px - 7, py - 6, px + 7, py + 6], fill=(250, 248, 234, 235))

    elif kind == "broccoli":
        for i in range(9):
            a = 2 * math.pi * i / 9
            rr = r * 0.40
            px = cx + rr * math.cos(a)
            py = cy + rr * math.sin(a) * 0.92
            for _ in range(7):
                aa = rng.uniform(0, 2 * math.pi)
                bx = px + 17 * math.cos(aa)
                by = py + 17 * math.sin(aa)
                draw.ellipse([bx - 16, by - 16, bx + 16, by + 16], fill=(82, 128, 70, 255))
            draw.ellipse([px - 14, py - 14, px + 14, py + 14], fill=(108, 156, 90, 255))
            draw.ellipse([px - 7, py - 7, px + 7, py + 7], fill=(136, 178, 110, 255))
        draw.ellipse([cx - 10, cy - 10, cx + 10, cy + 10], fill=(148, 186, 118, 255))

    elif kind == "noodle":
        blob(draw, cx, cy, int(r * 0.70), int(r * 0.60), (248, 238, 210, 255), 0.5)
        for i in range(26):
            y = cy - int(r * 0.38) + i * int(r * 0.030)
            pts = [(cx + x, y + 7 * math.sin(x / 24.0 + i * 0.8))
                   for x in range(-int(r * 0.54), int(r * 0.54), 7)]
            draw.line(pts, fill=(226, 198, 142, 255), width=4)
        for _ in range(7):
            px = cx + rng.randint(-int(r * 0.40), int(r * 0.40))
            py = cy + rng.randint(-int(r * 0.28), int(r * 0.28))
            draw.ellipse([px - 18, py - 12, px + 18, py + 12], fill=(172, 136, 88, 255))
            draw.ellipse([px - 10, py - 6, px + 10, py + 6], fill=(206, 172, 122, 255))
        for _ in range(6):
            px = cx + rng.randint(-int(r * 0.42), int(r * 0.42))
            py = cy + rng.randint(-int(r * 0.32), int(r * 0.32))
            draw.ellipse([px - 14, py - 10, px + 14, py + 10], fill=(110, 150, 86, 255))

    elif kind == "soup":
        blob(draw, cx, cy, int(r * 0.74), int(r * 0.64), (236, 222, 192, 255), 0.2)
        blob(draw, cx, cy, int(r * 0.64), int(r * 0.54), (220, 200, 162, 255), 1.1)
        for _ in range(12):
            a = rng.uniform(0, 2 * math.pi)
            rr = math.sqrt(rng.uniform(0, 1)) * r * 0.44
            px = cx + rr * math.cos(a)
            py = cy + rr * math.sin(a)
            draw.ellipse([px - 20, py - 13, px + 20, py + 13], fill=(174, 144, 104, 255))
            draw.ellipse([px - 11, py - 7, px + 11, py + 7], fill=(200, 172, 132, 255))
        for _ in range(5):
            a = rng.uniform(0, 2 * math.pi)
            rr = rng.uniform(0, r * 0.40)
            px = cx + rr * math.cos(a)
            py = cy + rr * math.sin(a)
            draw.ellipse([px - 12, py - 8, px + 12, py + 8], fill=(118, 154, 94, 255))

    elif kind == "ribs":
        for i in range(5):
            ang = -0.55 + i * 0.40
            px = cx + int(r * 0.26 * math.cos(ang))
            py = cy + int(r * 0.30 * math.sin(ang)) - int(r * 0.08)
            blob(draw, px, py, int(r * 0.28), int(r * 0.12), primary + (255,), ang + 0.6, 24, 0.06)
            blob(draw, px, py - 4, int(r * 0.24), int(r * 0.08), secondary + (200,), ang + 0.6, 24, 0.06)
            draw.ellipse([px - 11, py - 8, px + 11, py + 8], fill=(240, 228, 208, 235))
        for _ in range(7):
            px = cx + rng.randint(-int(r * 0.46), int(r * 0.46))
            py = cy + rng.randint(-int(r * 0.32), int(r * 0.32))
            draw.ellipse([px - 13, py - 9, px + 13, py + 9], fill=(108, 148, 84, 255))

    elif kind == "drink":
        cup_w = int(r * 0.66)
        cup_h = int(r * 1.02)
        left = cx - cup_w // 2
        top = cy - cup_h // 2
        draw.rounded_rectangle([left + 4, top + 16, left + cup_w + 6, top + cup_h + 18], radius=20,
                               fill=(120, 108, 88, 40))
        draw.rounded_rectangle([left, top, left + cup_w, top + cup_h], radius=20,
                               fill=(255, 255, 255, 218), outline=(226, 218, 200, 255), width=3)
        inner_top = top + int(cup_h * 0.16)
        draw.rounded_rectangle([left + 10, inner_top, left + cup_w - 10, top + cup_h - 14], radius=15,
                               fill=primary + (255,))
        draw.rounded_rectangle([left + 10, inner_top, left + cup_w - 10, inner_top + int(cup_h * 0.26)],
                               radius=15, fill=secondary + (225,))
        # 高光
        draw.rounded_rectangle([left + 16, inner_top + 14, left + 26, top + cup_h - 40], radius=6,
                               fill=(255, 255, 255, 110))
        draw.line([cx + 20, top - 30, cx + 8, inner_top + 34], fill=(232, 218, 192, 255), width=9)
        draw.ellipse([left - 20, top + cup_h - 34, left + 22, top + cup_h + 8],
                     fill=(246, 226, 132, 255), outline=(224, 198, 94, 255), width=3)
        for k in range(4):
            a = 2 * math.pi * k / 4 + 0.4
            draw.line([left + 1, top + cup_h - 13,
                       left + 1 + 19 * math.cos(a), top + cup_h - 13 + 19 * math.sin(a)],
                      fill=(252, 244, 198, 255), width=3)


def make_dish(code, name, primary, secondary, rice, kind, seed):
    rng = random.Random(seed)
    img = gradient_background((252, 247, 236), (236, 228, 210)).convert("RGBA")
    soft_light(img, int(W * 0.22), int(H * 0.16), int(W * 0.36), (255, 224, 172), 118)
    soft_light(img, int(W * 0.84), int(H * 0.86), int(W * 0.30), (204, 226, 188), 86)

    texture = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    td = ImageDraw.Draw(texture)
    for i in range(6):
        y = int(H * (0.16 + i * 0.14))
        td.arc([-W * 0.2, y - 70, W * 1.2, y + 100], 200, 340,
               fill=(255, 255, 255, 30), width=24)
    img.alpha_composite(texture.filter(ImageFilter.GaussianBlur(10)))

    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx, cy, r = W // 2, int(H * 0.50), int(min(W, H) * 0.39)
    draw_plate(draw, cx, cy, r)
    draw_food(draw, kind, cx, cy, r, primary, secondary, rice, rng)

    hl = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hl)
    hd.ellipse([cx - r * 0.82, cy - r * 0.98, cx + r * 0.12, cy - r * 0.34],
               fill=(255, 255, 255, 56))
    layer.alpha_composite(hl.filter(ImageFilter.GaussianBlur(20)))
    img.alpha_composite(layer)

    # 角落水印，明确这是示意图
    wm = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    wd = ImageDraw.Draw(wm)
    font = load_font(20)
    text = "示意图 · 非实物照片"
    bbox = wd.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    wd.rounded_rectangle([W - tw - 44, H - 52, W - 16, H - 16], radius=18,
                         fill=(255, 253, 246, 200))
    wd.text((W - tw - 30, H - 47), text, font=font, fill=(158, 148, 130, 255))
    img.alpha_composite(wm)

    out = os.path.join(OUT_DIR, f"{code}.webp")
    img.convert("RGB").save(out, "WEBP", quality=88, method=6)
    return out


def make_placeholder():
    img = gradient_background((250, 245, 235), (236, 228, 212)).convert("RGBA")
    soft_light(img, int(W * 0.3), int(H * 0.24), int(W * 0.32), (255, 228, 184), 108)
    layer = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    cx, cy, r = W // 2, int(H * 0.48), int(min(W, H) * 0.30)
    draw.ellipse([cx - r - 8, cy - r + 14, cx + r + 8, cy + r + 30], fill=(120, 108, 88, 36))
    draw.ellipse([cx - r, cy - r, cx + r, cy + r], fill=(255, 253, 246, 242))
    draw.ellipse([cx - r + 9, cy - r + 9, cx + r - 9, cy + r - 9],
                 outline=(214, 206, 190, 255), width=3)
    font = load_font(32)
    text = "图片待补充"
    bbox = draw.textbbox((0, 0), text, font=font)
    draw.text((cx - (bbox[2] - bbox[0]) / 2, cy - 22), text, font=font, fill=(172, 162, 144, 255))
    img.alpha_composite(layer)
    out = os.path.join(OUT_DIR, "dish-placeholder.webp")
    img.convert("RGB").save(out, "WEBP", quality=88, method=6)
    return out


if __name__ == "__main__":
    os.makedirs(OUT_DIR, exist_ok=True)
    for idx, (code, name, primary, secondary, rice, kind) in enumerate(DISHES):
        path = make_dish(code, name, primary, secondary, rice, kind, 20260101 + idx * 137)
        print("generated", os.path.basename(path))
    print("generated", os.path.basename(make_placeholder()))
