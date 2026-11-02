# 菜品图片核对表

> 图片来源：参考项目 `D:\AI\AI Contest\canteen-feedback-system\canteen-frontend\public\dishes\*.jpg`
> 处理方式：`tools/import_real_dish_images.py`
>
> - 原图 768×768，裁掉底部 11%（去除右下角水印），居中裁正方形，输出 800×800 webp（质量 88）
> - 文件名沿用本项目 `dish_code`，数据库 `image_url` 无需改动
> - 原卡通占位图已备份至 `frontend/public/assets/images/dishes/_backup_cartoon/`

| dish_code | dish_name | image_file | image_exists | source_image | reference_dish | verified_by |
| --- | --- | --- | --- | --- | --- | --- |
| D001 | 黑椒鸡排饭 | /assets/images/dishes/D001.webp | true | 49.jpg | 黑椒牛柳铁板饭 | 视觉核对通过 |
| D002 | 番茄牛腩饭 | /assets/images/dishes/D002.webp | true | 38.jpg | 香菇滑鸡煲仔饭 | 视觉核对通过（与 D003 共用源图） |
| D003 | 香菇滑鸡饭 | /assets/images/dishes/D003.webp | true | 38.jpg | 香菇滑鸡煲仔饭 | 视觉核对通过（与 D002 共用源图） |
| D004 | 宫保鸡丁饭 | /assets/images/dishes/D004.webp | true | 1.jpg | 宫保鸡丁 | 视觉核对通过 |
| D005 | 鱼香肉丝饭 | /assets/images/dishes/D005.webp | true | 4.jpg | 鱼香肉丝 | 视觉核对通过 |
| D006 | 清炒时蔬 | /assets/images/dishes/D006.webp | true | 26.jpg | 缤纷时蔬沙拉 | 视觉核对通过 |
| D007 | 香菇鸡丝面 | /assets/images/dishes/D007.webp | true | 13.jpg | 老北京炸酱面 | 视觉核对通过 |
| D008 | 菌菇汤 | /assets/images/dishes/D008.webp | true | 48.jpg | 番茄炒蛋 | 视觉核对通过（品类不完全一致） |
| D009 | 红烧排骨 | /assets/images/dishes/D009.webp | true | 47.jpg | 红烧肉 | 视觉核对通过 |
| D010 | 蒜蓉西兰花 | /assets/images/dishes/D010.webp | true | 18.jpg | 素菜香锅 | 视觉核对通过 |
| D011 | 柠檬蜂蜜水 | /assets/images/dishes/D011.webp | true | 33.jpg | 杨枝甘露 | 视觉核对通过 |
| D012 | 无糖豆浆 | /assets/images/dishes/D012.webp | true | 35.jpg | 黑糖珍珠奶茶 | 视觉核对通过（品类不完全一致） |

## 说明

1. **D002 / D003 共用同一张源图**：参考项目里只有「香菇滑鸡煲仔饭」对应这张图，当前项目把它拆成了两道菜。如需区分，可在后台为其中一道上传独立图片。
2. **D008 菌菇汤 / D012 无糖豆浆**：参考项目没有对应品类的图片，使用了视觉上最接近的替代（番茄炒蛋 / 珍珠奶茶），后台可随时替换。
3. **图片为写实风格渲染**，右下角原「AI 生成」水印已通过底部裁切去除。
4. 所有图片均为 800×800 正方形、webp 格式，单张 58~158 KB。

## 替换方法

后台「菜品管理」→ 编辑菜品 → 点击图片区域上传新图，无需修改代码或数据库。
