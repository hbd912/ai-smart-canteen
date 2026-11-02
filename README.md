# AI 智慧食堂 · Spring Boot 3 + Vue 3 沉浸式点餐系统

> 课程大作业项目：以六段动漫视频为连续叙事主线的「AI 智慧食堂」信息管理系统。
> 用户端是沉浸式视频点餐网页，管理端是完整的运营后台，两者共用同一套 Spring Boot 3 API 与 MySQL 数据库。

---

## 一、项目定位与技术栈

| 层 | 技术选型 | 版本 |
| --- | --- | --- |
| 前端 | Vue 3 + Vite + TypeScript | Vue 3.5 / Vite 6 / TS 5.7 |
| 前端状态 | Pinia | 2.3 |
| 前端路由 | Vue Router | 4.5 |
| 前端请求 | Axios（统一实例 + Token 注入 + 错误归一化） | 1.7 |
| 前端图表 | ECharts | 5.6 |
| 后端 | Spring Boot 3 | **3.5.16**（不是 Spring Boot 2） |
| 后端安全 | Spring Security + JWT（jjwt 0.12.6）+ BCrypt | — |
| 数据访问 | MyBatis-Plus | 3.5.12 |
| 数据库 | MySQL | 8.0.43（8.x） |
| 数据库迁移 | Flyway | 随 Boot 版本 |
| 接口文档 | springdoc-openapi (Swagger UI) | 2.8.13 |
| JDK | Java | 17 编译目标（本机运行于 23） |
| 构建 | Maven | 3.9.9 |

**说明**：项目未使用 Element Plus 的默认视觉（依赖已安装但用户端与后台均使用自研设计系统，
以保证动漫场景的沉浸感与视觉统一）。ECharts 仅用于管理后台统计图表。

---

## 二、目录结构

```
canteen/
├── Animation/                     原始视频素材（未修改，HEVC/H.264 混合）
├── picture/                       原始图1~图7参考图
├── backend/                       Spring Boot 3 后端
│   ├── src/main/java/com/canteen/
│   │   ├── common/                统一响应、错误码、异常、常量、权限点、标签
│   │   ├── config/                安全、CORS、OpenAPI、MyBatis-Plus、演示数据初始化
│   │   ├── controller/            REST 控制器（前台 7 个 + 后台 8 个）
│   │   ├── dto/                   请求参数对象（带 Bean Validation）
│   │   ├── entity/                数据库实体
│   │   ├── mapper/                MyBatis-Plus Mapper
│   │   ├── security/              JWT 签发/解析、过滤器、当前用户工具
│   │   ├── service/               业务实现
│   │   └── vo/                    响应视图对象
│   ├── src/main/resources/
│   │   ├── application.yml        主配置（全部支持环境变量覆盖）
│   │   ├── application-example.yml 环境变量示例
│   │   └── db/migration/          Flyway 脚本 V1~V4
│   └── pom.xml
├── frontend/                      Vue 3 前端
│   ├── public/assets/media/       六段已转码视频 + frames/ 首末帧
│   ├── public/assets/images/      reference/ 图1~7、dishes/ D001~D012
│   ├── src/api/                   Axios 封装与接口模块
│   ├── src/components/            公共组件、场景、首页、菜单、订单、后台
│   ├── src/config/media.ts        媒体资源唯一配置来源
│   ├── src/layouts/               管理后台布局
│   ├── src/router/                路由与守卫
│   ├── src/scene/                 视频控制器与场景背景
│   ├── src/state/                 场景状态机（reducer）
│   ├── src/stores/                Pinia（场景、认证、购物车、收藏、提示）
│   ├── src/styles/                设计令牌、全局样式、动效
│   ├── src/types/                 TypeScript 类型
│   ├── src/utils/                 格式化工具
│   └── src/views/                 customer/ 与 admin/ 页面
├── docs/
│   ├── assets/                    media-manifest.csv、image-manifest.csv、
│   │                              dish-image-checklist.md、missing-assets-report.md
│   └── database/                  erd.mmd、erd.puml、data-dictionary.md、seed-data-summary.md
├── tools/
│   ├── generate_dish_images.py    菜品示意插画生成脚本
│   └── e2e/                       端到端验收脚本（Puppeteer + 真实 Chrome）
└── README.md
```

---

## 三、环境要求

| 组件 | 要求 | 本机实测 |
| --- | --- | --- |
| JDK | 17 或更高（编译目标 17） | 23.0.1 |
| Maven | 3.6+ | 3.9.9 |
| Node.js | 18+ | 25.9.0 |
| npm | 9+ | 11.12.1 |
| MySQL | 8.0+ | 8.0.43 |
| 浏览器 | 支持 H.264 的现代浏览器 | Chrome / Edge |

---

## 四、启动步骤（按顺序执行）

### 1. 创建数据库

```sql
CREATE DATABASE IF NOT EXISTS canteen_system
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
```

命令行方式：

```bash
mysql -uroot -p -e "CREATE DATABASE IF NOT EXISTS canteen_system DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
```

### 2. 配置数据库连接（不要提交真实密码）

后端配置全部支持环境变量覆盖，默认值仅用于本地课堂演示：

```bash
# Windows PowerShell
$env:DB_HOST="localhost"
$env:DB_PORT="3306"
$env:DB_NAME="canteen_system"
$env:DB_USERNAME="root"
$env:DB_PASSWORD="你的密码"
```

也可以复制 `backend/src/main/resources/application-example.yml` 为
`application-local.yml` 并修改其中的连接信息（该文件不应提交到仓库）。

### 3. 启动后端（Flyway 自动建表 + 种子数据）

```bash
cd backend
mvn spring-boot:run
```

首次启动会自动：
1. 执行 Flyway 迁移 `V1`~`V4`（建表、7 个分类、12 道菜、6 条首页推荐）。
2. 由 `DemoAccountInitializer` 用 BCrypt 创建演示账号（`student`、`demo_user_02`、`admin`）。
3. 由 `DemoOrderInitializer` 生成 36 笔演示订单（`DEMO-` 前缀）与库存流水。

启动成功后：
- API 根路径：http://localhost:8080
- Swagger UI：http://localhost:8080/swagger-ui.html
- OpenAPI JSON：http://localhost:8080/v3/api-docs

### 4. 启动前端

```bash
cd frontend
npm install
npm run dev
```

- 用户端：http://localhost:5173/
- 管理后台登录：http://localhost:5173/admin/login

Vite 已配置代理，`/api` 与 `/uploads` 会转发到 `http://localhost:8080`（可用 `VITE_PROXY_TARGET` 修改）。

### 5. 验证初始化是否成功

```sql
USE canteen_system;
SELECT COUNT(*) FROM dish_category;                          -- 7
SELECT COUNT(*) FROM dish WHERE deleted = 0;                 -- 12
SELECT COUNT(*) FROM orders WHERE order_no LIKE 'DEMO-%';    -- 36
SELECT COUNT(*) FROM order_item;                             -- ≥ 30
SELECT COUNT(*) FROM sys_admin;                              -- ≥ 1
SELECT COUNT(*) FROM sys_user;                               -- ≥ 1
SELECT COUNT(*) FROM inventory_log;                          -- ≥ 5
```

---

## 五、演示账号

> 以下账号仅用于本地课堂演示。密码在数据库中为 **BCrypt 哈希**，SQL 脚本中不出现任何明文或哈希。

| 类型 | 账号 | 密码 | 说明 |
| --- | --- | --- | --- |
| 普通用户 | `student` | `123456` | 演示用户，已有演示订单，可体验完整流程 |
| 普通用户 | `demo_user_02` | `123456` | 第二演示用户 |
| 管理员 | `admin` | `Admin@123456` | 超级管理员，全部权限点 |

可通过环境变量覆盖演示密码：

```bash
$env:DEMO_USER_PASSWORD="自定义密码"
$env:DEMO_ADMIN_PASSWORD="自定义密码"
```

---

## 六、AI 大模型配置与降级

### 6.1 配置真实大模型

API Key **只能放在后端环境变量**，绝不写入前端、数据库或 Git 仓库：

```bash
$env:AI_ENABLED="true"
$env:AI_BASE_URL="https://api.deepseek.com/v1"   # 兼容 OpenAI Chat Completions 的服务均可
$env:AI_API_KEY="你的密钥"
$env:AI_MODEL="deepseek-chat"
$env:AI_TIMEOUT_SECONDS="20"
$env:AI_TEMPERATURE="0.3"
```

设置后重启后端，`GET /api/v1/ai/status` 会返回 `configured: true`、`mode: LLM`。

### 6.2 无 Key 时的规则降级模式

不设置 `AI_API_KEY`（或调用失败）时，后端自动降级为**规则推荐演示模式**：

- 候选集来自数据库真实在售菜品（已上架 + 供应中 + 有库存）。
- 按预算、热量、分类、关键词（减脂/增肌/清淡/素食/汤/面/饮品/饱腹/便宜）打分排序。
- 返回推荐理由与组合金额校验（预算 20 元时不会推荐 23 元的组合）。
- 界面与接口都会明确标注 `RULE_DEMO / 规则推荐演示模式`，**不谎称为大模型生成**。

### 6.3 模型输出校验

大模型返回的菜品 ID 必须通过后端二次校验（存在、已上架、供应中、有库存），
编造的 ID 或已下架菜品会被直接丢弃；若全部无效则降级为规则推荐。

---

## 七、核心状态机

### 7.1 状态定义

| sceneState | 视频 | 说明 |
| --- | --- | --- |
| `INTRO_PLAYING` | 001-1（单次） | 男主走向食堂门口 |
| `LOGIN_REQUIRED` | 静止帧 | 停在门口，显示登录卡片 |
| `ENTERING` | 002-1（单次） | 登录成功后开门进入 |
| `SEATING` | 003-1（单次） | 走向空位并坐下 |
| `HOME_IDLE` | **007-1（循环）** | 已落座、未点餐、空桌；男主待机动画 |
| `MENU_TRANSITION` | 004-1（单次） | 侧面转俯视；点餐面板此期间隐藏 |
| `MENU_OPEN` | 004-1 末帧 | 俯视点餐页；面板淡入 |
| `MENU_EXITING` | **004-1-reverse（单次）** | 俯视回退到侧面落座视角（预生成反向视频） |
| `CHECKOUT_OPEN` | 004-1 末帧 | 结算确认弹窗 |
| `DELIVERY` | 005-1（单次） | 服务员送餐 |
| `DELIVERY_HOLD` | 005-1 末帧 | 餐已送达，停在最后一帧，等用户点击导航 |
| `EATING_TRANSITION` | 006-1（单次） | 俯视转侧面用餐过渡 |
| `EATING` | **008-1（循环）** | 用餐中；男主持续用餐动画 |

> **循环策略**：只有 `HOME_IDLE`（007-1）与 `EATING`（008-1）开启 `loop`；
> 001-1 ~ 006-1 与 004-1-reverse 均为叙事过渡，只播放一次。
> 播放/停止/切换全部由 `SceneVideoController` 统一管理，组件不直接操作 video 实例。

### 7.2 状态转移图

```
INTRO_PLAYING --001-1 ended--> LOGIN_REQUIRED
LOGIN_REQUIRED --登录成功--> ENTERING
ENTERING --002-1 ended--> SEATING
SEATING --003-1 ended--> HOME_IDLE (循环 007-1)

HOME_IDLE --点击"点餐"--> MENU_TRANSITION (007 停止, 004-1 播放, 菜单隐藏)
MENU_TRANSITION --004-1 ended--> MENU_OPEN (菜单淡入)

MENU_OPEN --点击首页/订单/收藏/营养--> MENU_EXITING (004-1-reverse 倒放, 菜单隐藏)
MENU_EXITING --004-1-reverse ended--> HOME_IDLE (循环 007-1, 渲染目标面板)
MENU_OPEN --点击"点餐"--> MENU_OPEN               ← 不重播 004-1
MENU_OPEN --点击"去结算"--> CHECKOUT_OPEN
CHECKOUT_OPEN --取消/关闭--> MENU_OPEN            ← 购物车保留
CHECKOUT_OPEN --确认下单 + 后端创建订单成功--> DELIVERY

DELIVERY --005-1 ended--> DELIVERY_HOLD          ← 停在最后一帧，不自动播 008
DELIVERY_HOLD --用户点击任意导航--> EATING_TRANSITION
EATING_TRANSITION --006-1 ended--> EATING (循环 008-1)

EATING --点击首页/订单/收藏/营养--> EATING         ← 仅切面板，背景固定为 008 循环
EATING --点击"点餐"--> EATING + 提示               ← 不切视频、不开菜单
```

### 7.3 关键约束（已实现并由测试覆盖）

1. **未结算 = 空桌**：仅加入购物车、打开结算弹窗都不改变业务状态；只有后端返回订单创建成功才进入 `DELIVERY`。
2. **转场完成才显示 UI**：`MENU_TRANSITION` 期间点餐面板完全隐藏，`004-1` 播完进入 `MENU_OPEN` 后才淡入。
3. **倒放回退**：`MENU_OPEN` 点其他导航 → 播放**预生成反向视频** `004-1-reverse`，
   **不使用 `video.playbackRate = -1`**（兼容性不稳定）；结束后切回 `HOME_IDLE` 循环 007。
4. **005 停留**：`005-1` 播完停在最后一帧（`DELIVERY_HOLD`），**不自动播放** 008；
   必须由用户主动点击任意导航，才播 `006-1` 过渡并进入 `EATING` 循环 008。
5. **用餐中 UI 全部可用**：`EATING` 状态下首页、订单、收藏、营养管理面板均可正常打开切换。
6. **用餐中点餐被拦截**：不切视频、不开菜单，提示「正在用餐，请珍惜粮食，冷却 N 分钟后可再次点餐，请勿浪费食物」，
   并带 10 分钟前端演示冷却标记（`DINING_COOLDOWN_MINUTES = 10`）。
7. **ended 事件防误触发**：`SceneVideoController` 使用 generation 计数，旧视频事件被丢弃；
   回调里还会二次校验 `currentVideoId === eventVideoId`；循环视频的 `ended` 不会触发状态转移。
8. **幂等**：同一状态重复点击不会重复启动同一段视频；转场期间拦截重复导航。
9. **双 video 交叉淡化**：A/B 两个 video 层，新视频首帧就绪后才淡入，消除黑屏闪烁。
10. **刷新恢复**：以后端 `GET /api/v1/orders/active` 为准，绝不只依赖 localStorage 布尔值。
11. **声音开关**：右上角常驻，首次点击后解除静音，状态持久化到 localStorage。

---
## 八、API 一览（统一前缀 `/api/v1`）

### 8.1 前台（用户端）

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/auth/register` | 用户注册 |
| POST | `/auth/login` | 用户登录 |
| POST | `/auth/logout` | 退出（无状态 JWT，前端清理凭证） |
| GET | `/users/me` | 当前用户信息 |
| PUT | `/users/me` | 修改个人资料 |
| GET | `/dishes` | 菜品列表（分类/关键词/价格/热量/排序/分页） |
| GET | `/dishes/{id}` | 菜品详情 |
| GET | `/categories` | 启用分类 |
| GET | `/recommendations/home` | 首页推荐 |
| GET | `/home/content` | 首页聚合内容 |
| GET | `/cart` | 读取购物车 |
| POST | `/cart/items` | 加入购物车 |
| PUT | `/cart/items/{id}` | 修改数量（0 移除） |
| DELETE | `/cart/items/{id}` | 移除商品 |
| DELETE | `/cart` | 清空购物车 |
| POST | `/orders` | 结算下单（后端重新计价 + 校验库存 + 事务扣减） |
| GET | `/orders` | 我的订单分页 |
| GET | `/orders/{id}` | 订单详情 |
| GET | `/orders/active` | 当前进行中订单（刷新恢复用） |
| PATCH | `/orders/{id}/scene-status` | 前端场景推进订单状态 |
| GET | `/favorites` | 收藏列表 |
| POST | `/favorites/{dishId}/toggle` | 切换收藏 |
| GET | `/nutrition/summary` | 营养汇总（日均 + 达成率） |
| GET | `/nutrition/trends` | 营养趋势 |
| GET | `/ai/status` | AI 服务状态（不含密钥） |
| POST | `/ai/recommend` | AI 智能推荐 |

### 8.2 后台（需 ADMIN 角色）

| 方法 | 路径 | 说明 |
| --- | --- | --- |
| POST | `/admin/auth/login` | 管理员登录 |
| GET | `/admin/auth/me` | 管理员身份与权限 |
| GET/POST | `/admin/dishes` | 菜品分页 / 新增 |
| GET/PUT/DELETE | `/admin/dishes/{id}` | 详情 / 编辑 / 逻辑删除 |
| PATCH | `/admin/dishes/{id}/status` | 上架/下架 |
| PATCH | `/admin/dishes/{id}/supply-status` | 供应状态 |
| POST | `/admin/dishes/{id}/copy` | 复制为草稿 |
| GET/POST | `/admin/categories` | 分类列表 / 新增 |
| PUT/DELETE | `/admin/categories/{id}` | 编辑 / 删除（有菜品时拒绝） |
| PATCH | `/admin/categories/{id}/status` | 启用/停用 |
| PATCH | `/admin/categories/sort` | 排序 |
| GET | `/admin/inventory` | 库存列表 |
| POST | `/admin/inventory/adjust` | 库存调整（记录流水） |
| GET | `/admin/inventory/logs` | 库存流水 |
| GET | `/admin/orders` | 订单查询 |
| GET | `/admin/orders/{id}` | 订单详情 |
| PATCH | `/admin/orders/{id}/status` | 更新订单状态（取消时回补库存） |
| GET | `/admin/users` | 用户列表 |
| PATCH | `/admin/users/{id}/status` | 禁用/启用用户 |
| GET/PUT | `/admin/recommendations` | 首页推荐配置 |
| GET | `/admin/nutrition/dishes` | 营养缺失菜品 |
| GET | `/admin/nutrition/dish-list` | 营养管理列表 |
| GET | `/admin/admins` | 管理员列表 |
| POST | `/admin/media/dishes` | 上传菜品图片（校验类型/大小/真实解码） |
| GET | `/admin/statistics/overview` | 核心指标 |
| GET | `/admin/statistics/orders-trend` | 订单/销售额趋势 |
| GET | `/admin/statistics/dish-ranking` | 销量排行 |
| GET | `/admin/statistics/category-sales` | 分类销售占比 |
| GET | `/admin/statistics/hourly-distribution` | 时段分布 |
| GET | `/admin/statistics/user-growth` | 用户增长 |

统一响应：

```json
{ "code": 0, "message": "success", "data": {}, "timestamp": 1767000000000 }
```

分页返回：`{ "records": [], "total": 0, "page": 1, "pageSize": 10 }`

错误码：`40000` 参数错误、`40100` 未登录、`40101` 账号密码错误、`40300` 无权限、
`40400` 不存在、`40900` 冲突、`40910` 库存不足、`40911` 菜品不可售、`50000` 服务器错误。

---

## 九、素材映射

### 9.1 视频素材（保持原始分辨率，H.264 + AAC）

| 素材 | 项目路径 | 时长 | 分辨率 | 编码 | 播放方式 |
| --- | --- | --- | --- | --- | --- |
| 001-1 | `frontend/public/assets/media/001-1.mp4` | 3.111s | 2554×1440 | h264 / 30fps | 单次 |
| 002-1 | `frontend/public/assets/media/002-1.mp4` | 1.811s | 2554×1440 | h264 / 30fps | 单次 |
| 003-1 | `frontend/public/assets/media/003-1.mp4` | 5.042s | 1284×724 | h264 / 24fps | 单次 |
| 004-1 | `frontend/public/assets/media/004-1.mp4` | 5.042s | 1284×724 | h264 / 24fps | 单次 |
| 004-1-reverse | `frontend/public/assets/media/004-1-reverse.mp4` | 5.042s | 1284×724 | h264 / 24fps | 单次（预生成反向） |
| 005-1 | `frontend/public/assets/media/005-1.mp4` | 5.042s | 1284×724 | h264 / 24fps | 单次，停在末帧 |
| 006-1 | `frontend/public/assets/media/006-1.mp4` | 5.042s | 1284×724 | h264 / 24fps | 单次 |
| **007-1** | `frontend/public/assets/media/007-1.mp4` | 5.042s | 1280×720 | h264 / 24fps | **循环（HOME_IDLE）** |
| **008-1** | `frontend/public/assets/media/008-1.mp4` | 5.042s | 1280×720 | h264 / 24fps | **循环（EATING）** |

> **画质策略（重要）**：网页素材保持**原始分辨率与码率**，不做二次压缩。
> 原本就是 H.264 的 003~008 直接 `-c copy` 流复制（完全无损）；
> HEVC 的 001/002 必须转 H.264 才能被浏览器播放，使用 `-crf 16 -preset slow`（近似视觉无损），
> 且**保持原始 2554×1440**，不做降分辨率。
> 前端 `object-fit: contain` 按原始比例完整铺满，不放大裁切，无强制合成层、无滤镜。

原始文件（HEVC/H.264 混合）保留在 `Animation/`，未做任何修改。
`004-1-reverse.mp4` 同样由 `reverse` 预生成，保留备用。
首末帧海报位于 `frontend/public/assets/media/frames/`，用于静止帧与防黑屏垫底。

详细清单见 `docs/assets/media-manifest.csv`。

### 9.2 图片

| 素材 | 项目路径 |
| --- | --- |
| 图1 ~ 图7 | `frontend/public/assets/images/reference/figure-01.png` ~ `figure-07.png` |
| D001 ~ D012 菜品示意 | `frontend/public/assets/images/dishes/D001.webp` ~ `D012.webp` |
| 通用占位图 | `frontend/public/assets/images/dishes/dish-placeholder.webp` |

详细清单见 `docs/assets/image-manifest.csv`、`docs/assets/dish-image-checklist.md`。

---

## 十、哪些是真实实现、哪些是 mock

| 能力 | 状态 |
| --- | --- |
| 用户注册/登录/退出 | ✅ 真实：后端 BCrypt + JWT，数据库持久化 |
| 管理员登录与权限 | ✅ 真实：独立登录接口，`hasRole('ADMIN')` 保护全部管理接口 |
| 菜品/分类/库存/订单/用户/推荐 CRUD | ✅ 真实：MySQL 持久化，前后台共用同一份数据 |
| 购物车 | ✅ 真实：后端持久化，每次读取重新取价与库存状态 |
| 结算下单 | ✅ 真实：后端重算金额、校验库存、事务扣减、快照写入、幂等键 |
| 订单状态流水 | ✅ 真实：`order_status_log` 记录每次变更 |
| 营养分析 | ⚠️ 真实聚合 + **估算数据**：基于订单快照与菜品营养字段计算，标注为估算值 |
| 统计图表 | ✅ 真实 SQL 聚合（ECharts 渲染），数据为**初始化演示订单** |
| AI 推荐 | ✅ 真实调用大模型（配置 Key 时）/ ⚠️ 规则降级（未配置 Key 时，界面明确标注） |
| 视频叙事状态机 | ✅ 真实：九段视频 + 真实 `ended` 事件驱动 |
| 天气数据 | ⚠️ mock：顶栏显示静态演示数据，标注「演示」 |
| 支付 | ⚠️ mock：`DEMO_CONFIRMED`，界面明确说明「课堂演示订单，未发生真实支付」 |
| 菜品图片 | ✅ 真实写实照片（源自参考项目 canteen-feedback-system，768×768 转 800×800 webp） |
| 菜品营养数值 | ⚠️ 演示估算：`nutrition_source = ESTIMATED` |
| 图片上传 | ✅ 真实：本地 `backend/uploads` 目录，校验 MIME/扩展名/大小/真实解码 |
| 用餐冷却 | ⚠️ 前端演示：`DINING_COOLDOWN_MINUTES = 10`，仅前端计时，不做后端强制 |
| 通知抽屉 | ⚠️ mock：5 条静态演示通知，标注「演示数据」 |

**没有任何功能被包装成"已接入真实服务"而实际是假的。**

---

## 十一、数据库脚本与重置

### 11.1 迁移脚本

| 文件 | 内容 |
| --- | --- |
| `backend/src/main/resources/db/migration/V1__create_core_tables.sql` | 13 张表、主键、外键、索引 |
| `V2__seed_categories.sql` | 7 个固定分类（code 幂等） |
| `V3__seed_dishes.sql` | 12 道演示菜品 |
| `V4__seed_recommendations.sql` | 6 条首页推荐 |

演示账号与演示订单由 Java 初始化器生成（BCrypt 密码不能写死在 SQL 里）。

### 11.2 清空并重新初始化（⚠️ 破坏性操作，请先备份）

```sql
-- 1. 备份（可选但强烈建议）
--    mysqldump -uroot -p canteen_system > backup_$(date +%Y%m%d).sql

-- 2. 删除并重建数据库
DROP DATABASE IF EXISTS canteen_system;
CREATE DATABASE canteen_system
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

-- 3. 重新启动后端，Flyway 与 DataInitializer 会自动重新初始化
```

**注意**：`DROP DATABASE` 会永久删除所有真实用户、订单数据，仅在课堂演示环境使用。
应用启动时**不会**自动清空数据库。

---

## 十二、自测结果

完整验收脚本位于 `tools/e2e/`（Puppeteer + 真实 Chrome，1920×1080）：

```bash
cd tools/e2e
npm install
npm run verify:main          # 用户端完整视频叙事 + 管理后台
npm run verify:integration   # 前后台数据联动（22 项）
npm run verify:visual        # 画质/布局/声音开关回归
npm run verify:all           # 全部三套
```

> 说明：headless Chrome 在 `backdrop-filter` 合成层上存在命中测试缺陷，
> `page.click` 会静默失效（真实浏览器无此问题），因此脚本统一使用
> `clickEl()`（`elementFromPoint` 校验 + `dispatchEvent`），语义与用户点击一致。

最近一次执行：**全部通过**。逐项对应需求文档第十节与第十五节，详见
`docs/test-report.md`。截图保存在 `tools/e2e/shots/`。

---

## 十三、常见问题排查

| 现象 | 原因与解决 |
| --- | --- |
| 启动报 `Access denied for user` | 数据库账号密码错误。检查 `DB_USERNAME` / `DB_PASSWORD` 环境变量 |
| 启动报 `Unknown database 'canteen_system'` | 未创建数据库。执行第四节的 CREATE DATABASE |
| 端口 8080 被占用 | 改 `server.port`，同时修改前端 `VITE_PROXY_TARGET` |
| 端口 5173 被占用 | Vite 会自动切换端口，注意用终端输出的实际地址 |
| 前端接口 401 | Token 过期或未登录。重新登录；`JWT_EXPIRE_MINUTES` 默认 720 分钟 |
| 前端接口 403 | 普通用户 token 访问管理接口（预期行为）；或管理员角色不匹配 |
| 视频黑屏 | 检查 `frontend/public/assets/media/*.mp4` 是否存在；浏览器需支持 H.264 |
| 视频无法自动播放 | 浏览器策略要求静音。项目全站默认静音（无音量控件），正常无需干预 |
| 后台新增菜品报「服务器开小差」且日志有 Duplicate entry | 已在 `generateDishCode()` 修复（考虑软删除占用编码）；如仍出现请重启后端 |
| 菜品图片 404 | 检查 `frontend/public/assets/images/dishes/` 下是否有对应 `Dxxx.webp` |
| 上传的图片刷新后 404 | 后端 `uploads` 目录被清理。该目录需与项目一起拷贝/备份 |
| 统计图表全空 | 数据库中没有订单。确认 `DemoOrderInitializer` 已执行（日志有「演示订单初始化完成」） |
| AI 一直返回规则模式 | 未设置 `AI_API_KEY`，或 Key 无效（查看后端日志与 `/api/v1/ai/status`） |

---

## 十四、课堂演示建议流程

1. 启动 MySQL、后端（8080）、前端（5173），打开 http://localhost:5173/
2. 展示 001-1 门口视频 → 登录卡片出现 → 用 `student / 123456` 登录
3. 002-1 开门 → 003-1 落座 → **S0 浏览态**：右侧点餐面板，背景 007 正放↔倒放往返循环
4. 点击任意位置 → 声音开关自动解除静音（右上角 🔊/🔇 可随时切换，状态会记住）
5. 浏览菜品 → 加入购物车 → 点「去结算」→ 确认下单
6. **S1 下单瞬间**：立即播 005 送餐，点餐面板保持不消失，导航高亮仍是「点餐」（不跳首页、无「餐已准备好」页）
7. **S2 用餐态**：005 播完自动切 008 循环，点餐面板移到**左侧**（避开右侧人物）
8. S2 仍可浏览菜品、加购物车；点「结算」→ 提示「正在用餐，请珍惜粮食，冷却 10 分钟后可再次点餐」，不生成订单
9. S2 点「订单」→ 播 006 转场 → 切到订单页；切页后背景恢复 007 循环
10. 点「收藏」/「营养管理」→ 各自的独立面板正常展示
12. 打开 http://localhost:5173/admin/login → `admin / Admin@123456`
13. 菜品管理新增一道菜（已上架 + 有库存）→ 回到用户端验证同步；作品管理可审核/下架
14. 打开数据统计页，切换近 7 天 / 近 30 天，展示 5 张 ECharts 图表

---

## 十五、已知限制与后续建议

1. **视频素材**：001-1 / 002-1 原始为 HEVC（2554×1440），已转 H.264（crf16，保持原始分辨率）；
   003~008 原本就是 H.264，直接流复制**完全无损**。源素材自带平台水印。
2. **菜品图片**：12 道菜使用写实风格菜品照片（源自参考项目），统一 800×800 webp；可通过后台上传替换为实拍图。
3. **营养数据**：全部为课堂演示估算值，不是实验室检测结果，也未接入任何健康设备。
4. **支付**：无支付网关，订单标记为 `DEMO_CONFIRMED`，界面明确说明是课堂演示订单。
5. **图片存储**：使用本地 `backend/uploads` 目录，换机需一并拷贝；生产应改用对象存储。
6. **JWT 存储**：使用 `sessionStorage`（关闭标签页即失效），在 XSS 防护与易用性之间取平衡；
   生产建议改为 HttpOnly Cookie + CSRF 防护。
7. **用餐冷却**：`DINING_COOLDOWN_MINUTES = 10` 仅前端演示计时，刷新页面会按后端订单状态重新计算；
   生产应由后端强制校验。
8. **作品审核**：课堂演示环境发布即 `APPROVED`（便于立刻在广场看到），后台仍可改为 `REJECTED` 下架。
7. **权限**：演示版单一超级管理员角色，但 `Permissions` 常量与 `role_code` 已预留
   `OPERATOR` / `NUTRITION_ADMIN` 扩展能力。
8. **实时性**：前后台数据通过重新请求同步，未实现 WebSocket 推送。
9. **AI 会话**：已持久化到 `ai_conversation` / `ai_message`，但未实现多轮上下文回传（当前每轮独立）。

---

## 十六、相关文档

- 数据库关系图：`docs/database/erd.mmd`（Mermaid）、`docs/database/erd.puml`（PlantUML）
- 数据字典：`docs/database/data-dictionary.md`
- 种子数据汇总：`docs/database/seed-data-summary.md`
- 视频清单：`docs/assets/media-manifest.csv`
- 图片清单：`docs/assets/image-manifest.csv`
- 菜品图片核对表：`docs/assets/dish-image-checklist.md`
- 缺失素材报告：`docs/assets/missing-assets-report.md`
- 测试报告：`docs/test-report.md`
