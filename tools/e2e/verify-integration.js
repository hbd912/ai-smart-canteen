/**
 * 前后台数据联动验收：需求文档第十五节用例 20-27。
 * 通过真实 API 与后台 UI 操作，再到用户端验证同步效果。
 */
const puppeteer = require('puppeteer-core')
const fs = require('fs')
const path = require('path')

const CHROME = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe'
const BASE = process.env.E2E_BASE || 'http://127.0.0.1:5173'
const API = process.env.API_BASE || 'http://127.0.0.1:8080'
const OUT = path.join(__dirname, 'shots')
fs.mkdirSync(OUT, { recursive: true })

const results = []
function record(name, ok, detail) {
  results.push({ name, ok, detail })
  console.log(`${ok ? 'PASS' : 'FAIL'} | ${name}${detail ? ' | ' + detail : ''}`)
}
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

const NEW_DISH_NAME = '香煎鸡胸藜麦饭'

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

async function clickEl(page, selector) {
  const r = await page.evaluate((sel) => {
    const el = document.querySelector(sel)
    if (!el) {
      return { found: false }
    }
    el.scrollIntoView({ block: 'center' })
    for (const type of ['mousedown', 'mouseup', 'click']) {
      el.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true }))
    }
    return { found: true }
  }, selector)
  if (!r.found) {
    throw new Error(`元素不存在: ${selector}`)
  }
}

async function clickByText(page, selector, txt) {
  const r = await page.evaluate((sel, t) => {
    const el = Array.from(document.querySelectorAll(sel)).find((n) => (n.textContent || '').includes(t))
    if (!el) {
      return { found: false }
    }
    for (const type of ['mousedown', 'mouseup', 'click']) {
      el.dispatchEvent(new MouseEvent(type, { bubbles: true, cancelable: true }))
    }
    return { found: true }
  }, selector, txt)
  if (!r.found) {
    throw new Error(`未找到包含「${txt}」的元素: ${selector}`)
  }
}

async function typeInto(page, selector, value) {
  await page.focus(selector)
  await page.evaluate((sel) => {
    const el = document.querySelector(sel)
    el.value = ''
    el.dispatchEvent(new Event('input', { bubbles: true }))
  }, selector)
  await page.type(selector, String(value), { delay: 8 })
}

;(async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME,
    headless: 'new',
    protocolTimeout: 180000,
    args: ['--window-size=1600,1000', '--autoplay-policy=no-user-gesture-required', '--mute-audio']
  })
  const adminPage = await browser.newPage()
  await adminPage.setViewport({ width: 1600, height: 1000 })

  try {
    // 管理员登录
    await adminPage.goto(BASE + '/admin/login', { waitUntil: 'domcontentloaded', timeout: 30000 })
    await sleep(1200)
    await typeInto(adminPage, '#admin-username', 'admin')
    await typeInto(adminPage, '#admin-password', 'Admin@123456')
    await clickEl(adminPage, 'button[type=submit]')
    await sleep(2500)
    const adminToken = await adminPage.evaluate(() => sessionStorage.getItem('canteen.admin.token'))
    record('管理员登录获取 token', !!adminToken)

    // 前置清理
    const leftover = await api('GET', '/api/v1/admin/dishes?page=1&pageSize=100&keyword=' + encodeURIComponent(NEW_DISH_NAME), adminToken)
    for (const d of leftover.body.data?.records ?? []) {
      await api('DELETE', `/api/v1/admin/dishes/${d.id}`, adminToken)
    }
    record('前置：清理残留测试菜品', true, `removed=${leftover.body.data?.records?.length ?? 0}`)

    // ---------- 用例 20：新增菜品 ----------
    await adminPage.goto(BASE + '/admin/dishes', { waitUntil: 'networkidle2' })
    await sleep(1200)
    await clickByText(adminPage, 'button', '新增菜品')
    await adminPage.waitForSelector('#dish-name', { timeout: 15000 })
    await adminPage.waitForFunction(
      () => {
        const el = document.querySelector('#dish-name')
        return el && el.getBoundingClientRect().width > 0
      },
      { timeout: 10000 }
    )
    await sleep(600)
    // 抽屉滚动到底部，确保后续字段已渲染
    await adminPage.evaluate(() => {
      const body = document.querySelector('.drawer__body')
      if (body) {
        body.scrollTop = body.scrollHeight
      }
    })
    await sleep(400)
    await adminPage.evaluate(() => {
      const body = document.querySelector('.drawer__body')
      if (body) {
        body.scrollTop = 0
      }
    })
    await sleep(300)
    await typeInto(adminPage, '#dish-name', NEW_DISH_NAME)
    await typeInto(adminPage, '#dish-desc', '低脂高蛋白，适合健身后的清淡一餐')
    await typeInto(adminPage, '#dish-price', '22')
    await typeInto(adminPage, '#dish-stock', '25')
    await typeInto(adminPage, '#dish-cal', '420')
    await typeInto(adminPage, '#dish-protein', '38')
    await typeInto(adminPage, '#dish-fat', '9')
    await typeInto(adminPage, '#dish-carb', '46')
    await typeInto(adminPage, '#dish-ing', '鸡胸肉、藜麦、西兰花')
    await typeInto(adminPage, '#dish-allergen', '以实际供餐配方核实')
    await typeInto(adminPage, '#dish-tags', '低脂、高蛋白')
    await adminPage.evaluate(() => {
      const cat = document.querySelector('#dish-category')
      cat.value = String(cat.options[1].value)
      cat.dispatchEvent(new Event('change', { bubbles: true }))
      const pub = document.querySelector('#dish-publish')
      pub.value = 'PUBLISHED'
      pub.dispatchEvent(new Event('change', { bubbles: true }))
      const sup = document.querySelector('#dish-supply')
      sup.value = 'AVAILABLE'
      sup.dispatchEvent(new Event('change', { bubbles: true }))
    })
    await sleep(300)
    await clickByText(adminPage, '.drawer__foot .btn', '保存菜品')
    await sleep(2200)
    const afterCreate = await adminPage.evaluate(() => document.body.innerText)
    record('用例20-a 后台新增菜品保存成功', afterCreate.includes(NEW_DISH_NAME) || /菜品已创建/.test(afterCreate))

    const pub = await api('GET', '/api/v1/dishes?pageSize=100&keyword=' + encodeURIComponent(NEW_DISH_NAME), null)
    record('用例20-b 前台菜品接口可查到新增菜品',
      pub.status === 200 && pub.body.data.records.length > 0,
      `count=${pub.body.data?.records?.length}`)
    const newDish = pub.body.data.records[0]

    // ---------- 用例 21：编辑价格 ----------
    const beforeOrders = await api('GET', '/api/v1/admin/orders?page=1&pageSize=50', adminToken)
    const oldPrices = beforeOrders.body.data.records
      .flatMap((o) => (o.items || []).map((i) => ({ name: i.dishName, price: i.unitPrice })))
      .filter((i) => i.name === NEW_DISH_NAME)

    await api('PUT', `/api/v1/admin/dishes/${newDish.id}`, adminToken, {
      name: NEW_DISH_NAME,
      categoryId: newDish.categoryId,
      dishCode: newDish.dishCode,
      description: newDish.description,
      imageUrl: newDish.imageUrl,
      price: 26.5,
      calories: newDish.calories,
      proteinG: newDish.proteinG,
      fatG: newDish.fatG,
      carbohydrateG: newDish.carbohydrateG,
      fiberG: newDish.fiberG,
      sodiumMg: newDish.sodiumMg,
      nutritionSource: 'ESTIMATED',
      nutritionNote: newDish.nutritionNote,
      stock: newDish.stock,
      dailyLimit: 0,
      publishStatus: 'PUBLISHED',
      supplyStatus: 'AVAILABLE',
      recommendFlag: false,
      recommendRank: 0,
      sortOrder: 0,
      homeRecommendation: false,
      ingredients: newDish.ingredients,
      allergens: newDish.allergens,
      tags: newDish.tags
    })
    const afterEdit = await api('GET', `/api/v1/dishes/${newDish.id}`, null)
    record('用例21-a 修改价格后前台接口返回新价格',
      Number(afterEdit.body.data.price) === 26.5, `price=${afterEdit.body.data?.price}`)

    const afterOrders = await api('GET', '/api/v1/admin/orders?page=1&pageSize=50', adminToken)
    const newPrices = afterOrders.body.data.records
      .flatMap((o) => (o.items || []).map((i) => ({ name: i.dishName, price: i.unitPrice })))
      .filter((i) => i.name === NEW_DISH_NAME)
    record('用例21-b 历史订单单价快照不受菜品改价影响',
      JSON.stringify(oldPrices) === JSON.stringify(newPrices),
      `old=${JSON.stringify(oldPrices)} new=${JSON.stringify(newPrices)}`)

    // ---------- 用例 22：下架 ----------
    await api('PATCH', `/api/v1/admin/dishes/${newDish.id}/status`, adminToken, { status: 'UNPUBLISHED' })
    const afterUnpublish = await api('GET', '/api/v1/dishes?pageSize=100&keyword=' + encodeURIComponent(NEW_DISH_NAME), null)
    record('用例22-a 下架后前台列表不再返回该菜品',
      afterUnpublish.body.data.records.length === 0,
      `count=${afterUnpublish.body.data?.records?.length}`)

    const userLogin = await api('POST', '/api/v1/auth/login', null, { username: 'student', password: '123456' })
    const userToken = userLogin.body.data.token
    const addToCart = await api('POST', '/api/v1/cart/items', userToken, { dishId: newDish.id, quantity: 1 })
    record('用例22-b 下架菜品无法加入购物车', addToCart.status === 409 || addToCart.status === 400,
      `status=${addToCart.status} msg=${addToCart.body?.message}`)

    // ---------- 用例 24：库存为 0 ----------
    await api('PATCH', `/api/v1/admin/dishes/${newDish.id}/status`, adminToken, { status: 'PUBLISHED' })
    await api('POST', '/api/v1/admin/inventory/adjust', adminToken, {
      dishId: newDish.id, targetStock: 0, reason: '端到端验收：测试售罄状态'
    })
    const soldOut = await api('GET', `/api/v1/dishes/${newDish.id}`, null)
    record('用例24-a 库存为 0 时前台显示售罄且不可购买',
      soldOut.body.data.available === false && /售罄/.test(soldOut.body.data.availabilityText || ''),
      `available=${soldOut.body.data?.available} text=${soldOut.body.data?.availabilityText}`)
    const addSoldOut = await api('POST', '/api/v1/cart/items', userToken, { dishId: newDish.id, quantity: 1 })
    record('用例24-b 售罄菜品无法加入购物车', addSoldOut.status === 409 || addSoldOut.status === 400,
      `status=${addSoldOut.status}`)

    const logs = await api('GET', `/api/v1/admin/inventory/logs?page=1&pageSize=5&dishId=${newDish.id}`, adminToken)
    record('用例24-c 库存调整写入流水并记录原因',
      logs.body.data.records.length > 0 && /端到端验收/.test(logs.body.data.records[0].reason),
      `logs=${logs.body.data?.records?.length}`)

    // ---------- 用例 23：分类联动 ----------
    const catCreate = await api('POST', '/api/v1/admin/categories', adminToken, {
      name: '验收测试分类', code: 'E2E_TEST', icon: 'leaf', sortOrder: 99, status: 'ACTIVE'
    })
    record('用例23-a 后台新增分类成功', catCreate.status === 200 && catCreate.body.code === 0)
    const catId = catCreate.body.data.id
    const frontCats = await api('GET', '/api/v1/categories', null)
    record('用例23-b 前台分类接口同步出现新分类', frontCats.body.data.some((c) => c.id === catId))
    await api('PATCH', `/api/v1/admin/categories/${catId}/status`, adminToken, { status: 'INACTIVE' })
    const frontCatsAfter = await api('GET', '/api/v1/categories', null)
    record('用例23-c 停用分类后前台不再返回', !frontCatsAfter.body.data.some((c) => c.id === catId))
    const catDelete = await api('DELETE', `/api/v1/admin/categories/${catId}`, adminToken)
    record('用例23-d 无菜品关联的分类可删除', catDelete.status === 200)

    // ---------- 用例 26：首页推荐联动 ----------
    const recList = await api('GET', '/api/v1/admin/recommendations', adminToken)
    const currentRecs = recList.body.data
    const newRecs = [
      { dishId: newDish.id, title: '验收推荐位', badgeText: '验收标签', sortOrder: 1, enabled: true },
      ...currentRecs
        .filter((r) => r.dishId !== newDish.id)
        .slice(0, 5)
        .map((r, i) => ({ dishId: r.dishId, title: r.title, badgeText: r.badgeText, sortOrder: i + 2, enabled: true }))
    ]
    const saveRec = await api('PUT', '/api/v1/admin/recommendations', adminToken, { items: newRecs })
    record('用例26-a 保存首页推荐配置', saveRec.status === 200 && saveRec.body.code === 0)
    const homeRecs = await api('GET', '/api/v1/recommendations/home', null)
    record('用例26-b 前台首页推荐首位同步为验收推荐位',
      homeRecs.body.data.length > 0 && homeRecs.body.data[0].dishId === newDish.id,
      `first=${homeRecs.body.data[0]?.dishId} expected=${newDish.id}`)

    // ---------- 用例 27：营养字段联动 ----------
    await api('PUT', `/api/v1/admin/dishes/${newDish.id}`, adminToken, {
      name: NEW_DISH_NAME,
      categoryId: newDish.categoryId,
      dishCode: newDish.dishCode,
      description: newDish.description,
      imageUrl: newDish.imageUrl,
      price: 26.5,
      calories: 388,
      proteinG: 42,
      fatG: 7.5,
      carbohydrateG: 40,
      fiberG: 6,
      sodiumMg: 520,
      nutritionSource: 'ESTIMATED',
      nutritionNote: '端到端验收更新后的估算值',
      stock: 25,
      dailyLimit: 0,
      publishStatus: 'PUBLISHED',
      supplyStatus: 'AVAILABLE',
      recommendFlag: true,
      recommendRank: 1,
      sortOrder: 0,
      homeRecommendation: true,
      recommendationBadge: '验收标签',
      ingredients: newDish.ingredients,
      allergens: newDish.allergens,
      tags: newDish.tags
    })
    const dishNut = await api('GET', `/api/v1/dishes/${newDish.id}`, null)
    record('用例27 后台编辑营养字段后前台详情同步且标注估算',
      Number(dishNut.body.data.calories) === 388 && dishNut.body.data.nutritionSource === 'ESTIMATED',
      `cal=${dishNut.body.data?.calories} source=${dishNut.body.data?.nutritionSource}`)

    // ---------- 用户端 UI 验证 ----------
    const userPage = await browser.newPage()
    await userPage.setViewport({ width: 1920, height: 1080 })
    await userPage.goto(BASE + '/', { waitUntil: 'networkidle2' })
    await userPage.waitForSelector('.auth-card', { timeout: 40000 })
    await sleep(800)
    await typeInto(userPage, '#login-username', 'student')
    await typeInto(userPage, '#login-password', '123456')
    await clickEl(userPage, '.auth-submit')
    await userPage.waitForFunction(() => document.querySelector('.topbar') !== null, { timeout: 50000 })
    await userPage.waitForFunction(
      () => document.querySelector('.scene-view')?.getAttribute('data-scene') === 'HOME_IDLE',
      { timeout: 45000 }
    )
    await sleep(1500)
    // 新状态机：登录落座后即为 S0 浏览态，点餐面板已默认展示
    await userPage.evaluate(() => {
      const el = Array.from(document.querySelectorAll('.sidenav__btn'))
        .find((b) => (b.getAttribute('aria-label') || '') === '点餐')
      if (el) {
        for (const t of ['mousedown', 'mouseup', 'click']) {
          el.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
        }
      }
    })
    await userPage.waitForFunction(
      () => document.querySelector('.scene-view')?.getAttribute('data-scene') === 'MENU_OPEN',
      { timeout: 40000 }
    )
    await sleep(2000)
    const menuText = await userPage.evaluate(() => document.body.innerText)
    record('用例20-c 用户端菜单 UI 显示后台新增的菜品', menuText.includes(NEW_DISH_NAME))
    await userPage.screenshot({ path: path.join(OUT, '50-admin-created-dish-in-menu.png') })
    await userPage.close()

    // ---------- 清理 ----------
    const delResult = await api('DELETE', `/api/v1/admin/dishes/${newDish.id}`, adminToken)
    record('清理：测试菜品逻辑删除成功', delResult.status === 200, `status=${delResult.status}`)
    const checkGone = await api('GET', '/api/v1/dishes?pageSize=100&keyword=' + encodeURIComponent(NEW_DISH_NAME), null)
    record('清理：删除后前台列表不再返回该菜品', checkGone.body.data.records.length === 0,
      `count=${checkGone.body.data?.records?.length}`)
    const restoreRecs = currentRecs.map((r, i) => ({
      dishId: r.dishId, title: r.title, badgeText: r.badgeText, sortOrder: i + 1, enabled: true
    }))
    const restoreResult = await api('PUT', '/api/v1/admin/recommendations', adminToken, { items: restoreRecs })
    record('清理：首页推荐配置已恢复', restoreResult.status === 200)
  } catch (e) {
    record('脚本执行异常', false, String(e).slice(0, 600))
  } finally {
    await browser.close()
    const passed = results.filter((r) => r.ok).length
    console.log(`\n===== 联动验收：${passed}/${results.length} 通过 =====`)
    fs.writeFileSync(path.join(OUT, 'results-integration.json'), JSON.stringify(results, null, 2), 'utf-8')
    process.exit(passed === results.length ? 0 : 1)
  }
})()
