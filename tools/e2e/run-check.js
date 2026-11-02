const puppeteer = require('puppeteer-core')
const sleep = (ms) => new Promise((r) => setTimeout(r, ms))
;(async () => {
  const b = await puppeteer.launch({ executablePath:'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
    headless:'new', protocolTimeout:180000, args:['--window-size=1920,1080','--autoplay-policy=no-user-gesture-required','--mute-audio']})
  const p = await b.newPage(); await p.setViewport({width:1920,height:1080})
  const errs = []
  p.on('pageerror', e => errs.push(String(e).slice(0,200)))
  await p.goto('http://127.0.0.1:5173/', {waitUntil:'networkidle2'})
  await p.waitForSelector('.auth-card', {timeout:45000}); await sleep(600)
  await p.click('#login-username'); await p.type('#login-username','student')
  await p.click('#login-password'); await p.type('#login-password','123456')
  await p.evaluate(()=>document.querySelector('.auth-submit').click())
  await p.waitForFunction(()=>document.querySelector('.scene-view')?.getAttribute('data-scene')==='HOME_IDLE',{timeout:50000})
  await sleep(2000)
  const home = await p.evaluate(()=>{
    const root = document.querySelector('.scene-view')
    const vids = Array.from(document.querySelectorAll('.scene-bg__video'))
    const active = vids.filter(v=>Number(getComputedStyle(v).opacity)>0.05)
    return { scene: root?.getAttribute('data-scene'), panel: root?.getAttribute('data-panel'),
      ppPhase: root?.getAttribute('data-pp-phase'),
      nav: Array.from(document.querySelectorAll('.sidenav__label')).map(e=>e.textContent.trim()),
      video: active[0]?.getAttribute('src')?.split('/').pop(), playing: !active[0]?.paused,
      hasAI: /今天吃什么/.test(document.body.innerText),
      hasSearch: !!document.querySelector('.topbar__search'),
      videoError: !!document.querySelector('.video-error') }
  })
  console.log('首页:', JSON.stringify(home))
  await p.screenshot({path:'shots/run-home.png'})
  // ping-pong 观察
  const phases=[]
  for(let i=0;i<28;i++){
    const ph = await p.evaluate(()=>document.querySelector('.scene-view')?.getAttribute('data-pp-phase'))
    if(ph && phases[phases.length-1]!==ph) phases.push(ph)
    await sleep(250)
  }
  console.log('往返相位:', JSON.stringify(phases))
  console.log('pageerror:', errs.length, errs.slice(0,2))
  await b.close()
})()
