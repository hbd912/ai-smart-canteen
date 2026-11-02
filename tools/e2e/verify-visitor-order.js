/**
 * 访客视角：非作者点击作品里的关联订单，只能看到订单凭证快照，
 * 不能看到完整订单明细。
 *
 * 用法：node verify-visitor-order.js <E2E作品标题> <访客账号> <访客密码>
 */
const puppeteer = require('puppeteer-core')
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))

const [title, username, password] = process.argv.slice(2)

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
  if (!title || !username || !password) {
    throw new Error('缺少参数：作品标题 / 访客账号 / 访客密码')
  }
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

  try {
    await p.goto('http://127.0.0.1:5173/', { waitUntil: 'networkidle2' })
    await p.waitForSelector('.auth-card', { timeout: 45000 })
    await sleep(500)
    await p.click('#login-username')
    await p.type('#login-username', username)
    await p.click('#login-password')
    await p.type('#login-password', password)
    await p.evaluate(() => document.querySelector('.auth-submit').click())
    await p.waitForFunction(
      () => document.querySelector('.scene-view')?.getAttribute('data-scene') === 'HOME_IDLE',
      { timeout: 50000 }
    )
    await sleep(1500)

    await p.evaluate(() => {
      const el = Array.from(document.querySelectorAll('.sidenav__btn')).find(
        (x) => (x.getAttribute('aria-label') || '') === '精选'
      )
      for (const t of ['mousedown', 'mouseup', 'click']) {
        el.dispatchEvent(new MouseEvent(t, { bubbles: true, cancelable: true }))
      }
    })
    await sleep(2500)

    // 切到最新排序
    await clickByText(p, '.seg-control__btn', '最新')
    await sleep(1800)

    const found = await clickByText(p, '.work-card', title)
    if (!found) throw new Error('访客找不到目标作品: ' + title)
    await p.waitForSelector('.wd', { timeout: 15000 })
    await sleep(1200)

    const orderBtnLabel = await p.evaluate(
      () => document.querySelector('.wd__order-go')?.textContent?.replace(/\s+/g, ' ').trim() || ''
    )
    console.log('访客订单按钮文案:', orderBtnLabel)

    await p.click('.wd__order')
    await p.waitForSelector('.od', { timeout: 10000 })
    await sleep(1000)
    const result = await p.evaluate(() => ({
      snapshot: !!document.querySelector('.od__snapshot'),
      items: document.querySelectorAll('.od__item').length,
      lines: Array.from(document.querySelectorAll('.od__snapshot-line')).map((x) => x.textContent.replace(/\s+/g, ' ').trim()),
      note: document.querySelector('.od__snapshot-note')?.textContent?.trim()
    }))
    console.log('访客订单弹窗:', JSON.stringify(result))
    if (!result.snapshot) throw new Error('访客未看到订单凭证快照')
    if (result.items > 0) throw new Error('访客不应看到完整订单明细')
    if (orderBtnLabel.includes('查看订单')) throw new Error('访客按钮不应显示「查看订单」')

    await p.screenshot({ path: 'shots/pub-order-visitor.png' })
    console.log('pageerror:', errs.length, errs.slice(0, 2))
    console.log('VISITOR_RESULT=PASS')
  } finally {
    await b.close()
  }
})().catch((e) => {
  console.error('VISITOR_RESULT=FAIL', e)
  process.exitCode = 1
})
