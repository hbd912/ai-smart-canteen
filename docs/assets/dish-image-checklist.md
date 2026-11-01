# 菜品图片核对表

> 生成方式：`tools/generate_dish_images.py`（Pillow 程序绘制的统一风格示意插画）
>
> **重要声明**：项目未获得 12 道菜的独立实拍照片。依据需求文档 20.4 的规则，全部使用
> 统一风格的本地占位/示意视觉，并在图片右下角与详情页标注「示意图片」。
> 这些图片**不是食堂实物照片**，不得用于对外宣传。

| dish_code | dish_name | image_file | image_exists | image_source | is_illustrative | verified_by |
| --- | --- | --- | --- | --- | --- | --- |
| D001 | 黑椒鸡排饭 | /assets/images/dishes/D001.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D002 | 番茄牛腩饭 | /assets/images/dishes/D002.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D003 | 香菇滑鸡饭 | /assets/images/dishes/D003.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D004 | 宫保鸡丁饭 | /assets/images/dishes/D004.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D005 | 鱼香肉丝饭 | /assets/images/dishes/D005.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D006 | 清炒时蔬 | /assets/images/dishes/D006.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D007 | 香菇鸡丝面 | /assets/images/dishes/D007.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D008 | 菌菇汤 | /assets/images/dishes/D008.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D009 | 红烧排骨 | /assets/images/dishes/D009.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D010 | 蒜蓉西兰花 | /assets/images/dishes/D010.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D011 | 柠檬蜂蜜水 | /assets/images/dishes/D011.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| D012 | 无糖豆浆 | /assets/images/dishes/D012.webp | true | AI_ILLUSTRATION（程序绘制） | true | 本地生成，视觉核对通过 |
| — | 通用占位图 | /assets/images/dishes/dish-placeholder.webp | true | PLACEHOLDER | true | 新增菜品未上传图片时使用 |

## 替换为真实照片的操作步骤

1. 管理员登录后台 → 菜品管理 → 编辑对应菜品。
2. 在「菜品图片」处上传实拍照片（jpg/png/webp，≤5MB）。
3. 后端会把文件保存到 `backend/uploads/dishes/yyyyMM/` 并返回稳定 URL（`/uploads/...`）。
4. 保存后前台菜单与详情页立即读取新图片，历史订单仍使用下单时的 `image_url_snapshot`。
5. 也可以直接把实拍图命名为 `D001.webp` 覆盖 `frontend/public/assets/images/dishes/` 下的同名文件
   （保持 4:3 或 16:9、主体居中）。

## 尺寸与裁切规范

- 生成图尺寸：800 × 600（4:3）。
- 前端卡片按 16:10 裁切、详情页按容器比例 `object-fit: cover`，主体始终居中，不会被裁掉菜品主体。
