const puppeteer = require('puppeteer-core')
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
const nav = (p,l) => p.evaluate((lb)=>{
  const el = Array.from(document.querySelectorAll('.sidenav__btn')).find(x=>(x.getAttribute('aria-label')||'')===lb)
  if(!el) return
  for(const t of ['mousedown','mouseup','click']) el.dispatchEvent(new MouseEvent(t,{bubbles:true,cancelable:true}))
}, l)
;(async () => {
  const b = await puppeteer.launch({ executablePath:'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless:'new', protocolTimeout:180000, args:['--window-size=1920,1080','--autoplay-policy=no-user-gesture-required','--mute-audio']})
  const p = await b.newPage(); await p.setViewport({width:1920,height:1080})
  const errs=[]; p.on('pageerror', e=>errs.push(String(e).slice(0,200)))
  await p.goto('http://127.0.0.1:5173/', {waitUntil:'networkidle2'})
  await p.waitForSelector('.auth-card', {timeout:45000}); await sleep(600)
  await p.click('#login-username'); await p.type('#login-username','student')
  await p.click('#login-password'); await p.type('#login-password','123456')
  await p.evaluate(()=>document.querySelector('.auth-submit').click())
  await p.waitForFunction(()=>document.querySelector('.scene-view')?.getAttribute('data-scene')==='HOME_IDLE',{timeout:50000})
  await sleep(1800)
  const home = await p.evaluate(()=>({
    scene: document.querySelector('.scene-view').getAttribute('data-scene'),
    nav: Array.from(document.querySelectorAll('.sidenav__label')).map(e=>e.textContent.trim()),
    video: Array.from(document.querySelectorAll('.scene-bg__video')).filter(v=>Number(getComputedStyle(v).opacity)>0.05)[0]?.getAttribute('src')?.split('/').pop(),
    search: !!document.querySelector('.topbar__search')
  }))
  console.log('[首页]', JSON.stringify(home))
  await nav(p,'点餐')
  await p.waitForFunction(()=>document.querySelector('.scene-view')?.getAttribute('data-scene')==='MENU_OPEN',{timeout:30000})
  await sleep(2000)
  const menu = await p.evaluate(()=>({
    cards: document.querySelectorAll('.dish-card').length,
    badges: document.querySelectorAll('.dish-card__rating').length,
    tags: document.querySelector('.dish-card .tag')?.textContent?.trim()
  }))
  console.log('[点餐]', JSON.stringify(menu))
  const t0=Date.now()
  await nav(p,'订单')
  await sleep(400)
  const ord = await p.evaluate(()=>({ panel: document.querySelector('.scene-view').getAttribute('data-panel'), hasUI: /我的订单/.test(document.body.innerText) }))
  console.log('[订单]', JSON.stringify(ord), '切换耗时', Date.now()-t0, 'ms')
  await sleep(1200)
  await p.evaluate(()=>{
    const btn = Array.from(document.querySelectorAll('button')).find(x=>x.textContent.includes('评价中心'))
    if(btn) for(const t of ['mousedown','mouseup','click']) btn.dispatchEvent(new MouseEvent(t,{bubbles:true,cancelable:true}))
  })
  await sleep(2000)
  const rc = await p.evaluate(()=>({ center: !!document.querySelector('.review-center'), tabs: Array.from(document.querySelectorAll('.rc-tab')).map(t=>t.textContent.trim().replace(/\s+/g,' ')) }))
  console.log('[评价中心]', JSON.stringify(rc))
  await p.screenshot({path:'shots/run-final.png'})
  console.log('[pageerror]', errs.length, errs.slice(0,2))
  await b.close()
})()
