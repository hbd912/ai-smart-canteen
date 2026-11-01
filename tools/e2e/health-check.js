/**
 * 环境健康冒烟检查：不依赖浏览器，直接走核心 API 链路。
 * 用于确认演示环境随时可用。
 */
const API = process.env.API_BASE || 'http://127.0.0.1:8080'
const FE = process.env.FE_BASE || 'http://127.0.0.1:5173'

const results = []
function record(name, ok, detail) {
  results.push({ name, ok })
  console.log(`${ok ? 'PASS' : 'FAIL'} | ${name}${detail ? ' | ' + detail : ''}`)
}

async function api(method, url, token, body) {
  const res = await fetch(API + url, {
    method,
    headers: {
      'Content-Type': 'application/json; charset=utf-8',
      ...(token ? { Authorization: 'Bearer ' + token } : {})
    },
    body: body ? JSON.stringify(body) : undefined
  })
  const txt = await res.text()
  let parsed
  try {
    parsed = JSON.parse(txt)
  } catch {
    parsed = { raw: txt }
  }
  return { status: res.status, body: parsed }
}

;(async () => {
  try {
    // 1. 公开接口
    const cats = await api('GET', '/api/v1/categories')
    record('分类接口', cats.status === 200 && cats.body.data.length === 7, `count=${cats.body.data?.length}`)

    const dishes = await api('GET', '/api/v1/dishes?pageSize=100')
    record('菜品接口', dishes.status === 200 && dishes.body.data.total === 12, `total=${dishes.body.data?.total}`)

    const home = await api('GET', '/api/v1/recommendations/home')
    record('首页推荐', home.status === 200 && home.body.data.length === 6, `count=${home.body.data?.length}`)

    const ai = await api('GET', '/api/v1/ai/status')
    record('AI 状态接口', ai.status === 200 && !!ai.body.data.mode, `mode=${ai.body.data?.mode}`)

    // 2. 用户登录
    const login = await api('POST', '/api/v1/auth/login', null, { username: 'student', password: '123456' })
    record('演示用户登录 student/123456', login.status === 200 && login.body.code === 0,
      `nickname=${login.body.data?.user?.nickname}`)
    const token = login.body.data.token

    const badLogin = await api('POST', '/api/v1/auth/login', null, { username: 'student_demo', password: 'Demo@123456' })
    record('旧账号 student_demo 已失效', badLogin.status === 401, `status=${badLogin.status}`)

    // 3. 购物车
    await api('DELETE', '/api/v1/cart', token)
    const cart0 = await api('GET', '/api/v1/cart', token)
    record('购物车初始为空', cart0.status === 200 && cart0.body.data.totalQuantity === 0,
      `qty=${cart0.body.data?.totalQuantity}`)

    const firstDishId = dishes.body.data.records[0].id
    const add = await api('POST', '/api/v1/cart/items', token, { dishId: firstDishId, quantity: 1 })
    record('加入购物车', add.status === 200 && add.body.data.totalQuantity === 1,
      `qty=${add.body.data?.totalQuantity}`)

    // 4. 活跃订单（应为空，保证演示从空桌开始）
    const active = await api('GET', '/api/v1/orders/active', token)
    record('当前无进行中订单（演示从空桌开始）', active.status === 200 && !active.body.data)

    // 5. 营养
    const nut = await api('GET', '/api/v1/nutrition/summary?days=7', token)
    record('营养汇总接口', nut.status === 200 && typeof nut.body.data.calorieRate === 'number',
      `dailyCal=${nut.body.data?.dailyCalories}`)

    // 6. AI 推荐
    const rec = await api('POST', '/api/v1/ai/recommend', token, {
      message: '想吃清淡一点，预算 20 元以内，要有蔬菜'
    })
    record('AI 推荐（规则降级模式）', rec.status === 200 && rec.body.data.dishes.length > 0,
      `mode=${rec.body.data?.mode} dishes=${rec.body.data?.dishes?.map((d) => d.name).join('/')}`)

    // 7. 管理员
    const alogin = await api('POST', '/api/v1/admin/auth/login', null, { username: 'admin', password: 'Admin@123456' })
    record('管理员登录 admin/Admin@123456', alogin.status === 200, `role=${alogin.body.data?.admin?.roleCode}`)
    const adminToken = alogin.body.data.token

    const overview = await api('GET', '/api/v1/admin/statistics/overview', adminToken)
    record('统计总览', overview.status === 200 && typeof overview.body.data.todayOrders === 'number',
      `todayOrders=${overview.body.data?.todayOrders}`)

    const ranking = await api('GET', '/api/v1/admin/statistics/dish-ranking?limit=5', adminToken)
    record('销量排行', ranking.status === 200 && ranking.body.data.items.length > 0,
      `top=${ranking.body.data?.items?.[0]?.name}`)

    // 8. 越权
    const forbidden = await api('GET', '/api/v1/admin/dishes?page=1&pageSize=1', token)
    record('普通用户访问管理接口返回 403', forbidden.status === 403, `status=${forbidden.status}`)

    // 9. 前端可访问
    const fe = await fetch(FE + '/')
    record('前端服务可访问', fe.status === 200, `status=${fe.status}`)

    const videos = ['001-1', '002-1', '003-1', '004-1', '004-1-reverse', '005-1', '006-1', '007-1', '008-1']
    let missing = []
    for (const v of videos) {
      const r = await fetch(`${FE}/assets/media/${v}.mp4`, { method: 'HEAD' })
      if (r.status !== 200) {
        missing.push(v)
      }
    }
    record('9 段视频素材均可访问', missing.length === 0, missing.length ? `missing=${missing.join(',')}` : 'ok')

    // 清理购物车，恢复干净演示状态
    await api('DELETE', '/api/v1/cart', token)
  } catch (e) {
    record('冒烟脚本执行异常', false, String(e).slice(0, 300))
  } finally {
    const passed = results.filter((r) => r.ok).length
    console.log(`\n===== 环境健康检查：${passed}/${results.length} 通过 =====`)
    process.exit(passed === results.length ? 0 : 1)
  }
})()
