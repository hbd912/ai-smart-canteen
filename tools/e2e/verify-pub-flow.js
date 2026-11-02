/**
 * 精选「发布作品」全流程 E2E：
 * 登录 -> 精选 -> 发布（2 张图 + 文字 + 历史订单）-> 卡片出现 ->
 * 打开作品详情（订单凭证 / 多图轮播）-> 查看订单 -> 跳转点餐并打开菜品详情。
 */
const puppeteer = require('puppeteer-core')
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const path = require('path')

const clickByText = (p, selector, text) =>
  p.evaluate(
    (sel, txt) => {
      const el = Array.from(document.querySelectorAll(sel)).find((x) => (x.textContent || '').includes(txt))
      if (!el) return false
      for (const t of ['mousedown', 'mouseup', 'click']) {
        el.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
      }
      return true
    },
    selector,
    text
  )

;(async () => {
  const b = await puppeteer.launch({
    executablePath: 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless: 'new',
    protocolTimeout: 180000,
    args: ['--window-size=1920,1080', '--autoplay-policy=no-user-gesture-required', '--mute-audio']
  })
  const p = await b.newPage()
  await p.setViewport({ width: 1920, height: 1080 })
  const errs = []
  p.on('pageerror', (e) => errs.push(String(e).slice(0, 300)))

  const title = 'E2E-作品-' + Date.now()
  const content = '自动化端到端测试：这是用户自己上传图片和文字发布的作品，并关联了一项历史订单。'

  try {
    await p.goto('http://127.0.0.1:5173/', { waitUntil: 'networkidle2' })
    await p.waitForSelector('.auth-card', { timeout: 45000 })
    await sleep(500)
    await p.click('#login-username')
    await p.type('#login-username', 'student')
    await p.click('#login-password')
    await p.type('#login-password', '123456')
    await p.evaluate(() => document.querySelector('.auth-submit').click())
    await p.waitForFunction(
      () => document.querySelector('.scene-view')?.getAttribute('data-scene') === 'HOME_IDLE',
      { timeout: 50000 }
    )
    await sleep(1500)

    // 进入精选
    await p.evaluate(() => {
      const el = Array.from(document.querySelectorAll('.sidenav__btn')).find(
        (x) => (x.getAttribute('aria-label') || '') === '精选'
      )
      for (const t of ['mousedown', 'mouseup', 'click']) {
        el.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
      }
    })
    await sleep(2500)
    const before = await p.evaluate(() => document.querySelectorAll('.work-card').length)

    // 打开发布弹窗
    const opened = await clickByText(p, 'button', '发布作品')
    if (!opened) throw new Error('找不到「发布作品」按钮')
    await p.waitForSelector('.pub', { timeout: 10000 })
    await sleep(1200)

    // 上传 2 张图片
    const img1 = path.resolve('D:/AI/AI Contest/canteen/frontend/public/assets/images/dishes/D001.webp')
    const img2 = path.resolve('D:/AI/AI Contest/canteen/frontend/public/assets/images/dishes/D004.webp')
    const fileInput = await p.$('.pub__img-add input[type=file]')
    await fileInput.uploadFile(img1, img2)
    await sleep(4000)
    const afterUpload = await p.evaluate(() => ({
      imgs: document.querySelectorAll('.pub__img').length,
      err: document.querySelector('.pub__error')?.textContent?.trim()
    }))
    console.log('上传后:', JSON.stringify(afterUpload))
    if (afterUpload.imgs !== 2) throw new Error('图片上传数量不对: ' + afterUpload.imgs)

    // 填标题与文字
    await p.click('#pub-title')
    await p.type('#pub-title', title)
    await p.click('#pub-content')
    await p.type('#pub-content', content)
    await sleep(300)

    // 选择历史订单
    const pickerLabel = await p.evaluate(() =>
      Array.from(document.querySelectorAll('.pub__label')).some((x) => (x.textContent || '').includes('关联历史订单'))
    )
    console.log('存在「关联历史订单」入口:', pickerLabel)
    const pickerOpened = await clickByText(p, 'button', '选择历史订单')
    if (!pickerOpened) throw new Error('找不到「选择历史订单」按钮')
    await sleep(1200)
    const firstOrderNo = await p.evaluate(() => {
      const opt = document.querySelector('.pub__opt')
      return opt ? opt.textContent.replace(/\s+/g, ' ').trim() : null
    })
    console.log('历史订单首项:', firstOrderNo)
    if (!firstOrderNo || !firstOrderNo.includes('订单')) throw new Error('历史订单列表为空或没显示订单号')
    await p.evaluate(() => {
      const opt = document.querySelector('.pub__opt')
      for (const t of ['mousedown', 'mouseup', 'click']) {
        opt.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
      }
    })
    await sleep(600)
    const picked = await p.evaluate(() => document.querySelector('.pub__picked')?.textContent?.replace(/\s+/g, ' ').trim())
    console.log('已选关联:', picked)
    if (!picked) throw new Error('未选中关联订单')

    await p.screenshot({ path: 'shots/pub-ready.png' })

    // 发布
    const submitted = await p.evaluate(() => {
      const btn = Array.from(document.querySelectorAll('.pub__foot .btn')).find((x) => (x.textContent || '').includes('发布'))
      if (!btn) return false
      for (const t of ['mousedown', 'mouseup', 'click']) {
        btn.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
      }
      return true
    })
    if (!submitted) throw new Error('找不到发布按钮')
    await p.waitForFunction(() => !document.querySelector('.pub'), { timeout: 20000 })
    await sleep(2500)

    const after = await p.evaluate(() => document.querySelectorAll('.work-card').length)
    console.log('发布前卡片:', before, '发布后:', after, '弹窗已关:', true)

    // 最新排序下第一条应是刚发布的作品
    const firstCardTitle = await p.evaluate(
      () => document.querySelector('.work-card .work-card__title')?.textContent?.trim() || ''
    )
    console.log('最新第一条标题:', firstCardTitle, '| 预期:', title)
    if (!firstCardTitle.includes(title)) {
      // 兜底按标题查找
      const found = await clickByText(p, '.work-card', title)
      if (!found) throw new Error('作品流里找不到刚发布的作品')
      await sleep(1500)
    } else {
      await p.click('.work-card')
    }
    await p.waitForSelector('.wd', { timeout: 15000 })
    await sleep(1200)

    const detail = await p.evaluate(() => ({
      title: document.querySelector('.wd__title')?.textContent?.trim(),
      thumbs: document.querySelectorAll('.wd__thumb').length,
      count: document.querySelector('.wd__img-count')?.textContent?.trim(),
      hasOrder: !!document.querySelector('.wd__order'),
      orderNo: document.querySelector('.wd__order-no')?.textContent?.trim(),
      hasDish: !!document.querySelector('.wd__dish')
    }))
    console.log('作品详情:', JSON.stringify(detail))
    if (!detail.hasOrder) throw new Error('作品详情没有显示关联订单')
    if (detail.thumbs < 2) throw new Error('多图轮播缩略图未显示')
    if (!detail.hasDish) throw new Error('作品详情没有显示关联菜品')

    // 多图切换
    await p.click('.wd__img-nav--next')
    await sleep(300)
    const nextCount = await p.evaluate(() => document.querySelector('.wd__img-count')?.textContent?.trim())
    console.log('切换到下一张:', nextCount)

    // 查看订单（作者本人应看到完整明细）
    await p.click('.wd__order')
    await p.waitForSelector('.od', { timeout: 10000 })
    await sleep(1200)
    const orderModal = await p.evaluate(() => ({
      items: document.querySelectorAll('.od__item').length,
      total: document.querySelector('.od__total strong')?.textContent?.trim(),
      snapshot: !!document.querySelector('.od__snapshot')
    }))
    console.log('订单弹窗:', JSON.stringify(orderModal))
    if (!orderModal.items) throw new Error('作者查看订单没有显示明细')
    await p.screenshot({ path: 'shots/pub-order-detail.png' })
    await p.click('.od__close')
    await sleep(500)

    // 跳转点餐并打开菜品详情
    await p.click('.wd__dish')
    await sleep(2500)
    const dishJump = await p.evaluate(() => ({
      scene: document.querySelector('.scene-view')?.getAttribute('data-scene'),
      menu: !!document.querySelector('.menu-panel'),
      detailModal: !!document.querySelector('.modal__surface.detail'),
      detailName: document.querySelector('.modal__surface.detail h2, .modal__surface.detail .detail__name')?.textContent?.trim()
    }))
    console.log('点餐跳转:', JSON.stringify(dishJump))
    if (!dishJump.detailModal) throw new Error('点击关联菜品后没有打开菜品详情弹窗')

    await p.screenshot({ path: 'shots/pub-done.png' })
    console.log('pageerror:', errs.length, errs.slice(0, 2))
    console.log('E2E_RESULT=PASS')
  } finally {
    await b.close()
  }
})().catch((e) => {
  console.error('E2E_RESULT=FAIL', e)
  process.exitCode = 1
})
