from playwright.sync_api import sync_playwright
import json, pathlib, os
root = pathlib.Path(__file__).resolve().parents[1]
out = pathlib.Path(os.environ.get('ODYSSEY_ARTIFACTS', str(root / '.artifacts/product-worlds')))
out.mkdir(parents=True, exist_ok=True)
results=[]
def check(name,test):
    try:
        test(); results.append({'name':name,'passed':True})
    except Exception as e: results.append({'name':name,'passed':False,'error':str(e)})
def ok(value):
    assert value
with sync_playwright() as p:
    launch = {'headless': True}
    if os.environ.get('ODYSSEY_CHROMIUM'): launch['executable_path'] = os.environ['ODYSSEY_CHROMIUM']
    browser=p.chromium.launch(**launch)
    page=browser.new_page(viewport={'width':1440,'height':1100})
    errors=[];page.on('pageerror',lambda e: errors.append(str(e)))
    page.set_content((root/'site/product-worlds/standalone.html').read_text(),wait_until='networkidle')
    check('Original three SVG scenes loaded',lambda:ok(page.locator('.products .art svg').count()==3))
    check('Travel starts with a quoted state',lambda:ok(page.locator('#state').inner_text()=='quoted'))
    page.locator('[data-event=SUBMIT]').click()
    check('Submission does not confirm booking',lambda:ok(page.locator('#state').inner_text()=='submitting'))
    page.locator('[data-event=PAYMENT_AUTHORIZED]').click()
    check('Authorization waits for supplier',lambda:ok(page.locator('#state').inner_text()=='pending'))
    page.locator('[data-event=TIMEOUT]').click()
    check('Timeout becomes unknown',lambda:ok(page.locator('#state').inner_text()=='unknown'))
    page.locator('[data-event=RETRY_BLOCKED]').click()
    check('Blind resubmission blocked and state retained',lambda:ok(page.locator('#state').inner_text()=='unknown' and 'Blocked safely' in page.locator('#notice').inner_text()))
    page.locator('[data-event=CONFIRMED]').click()
    check('Confirmed supplier event resolves unknown',lambda:ok(page.locator('#state').inner_text()=='confirmed'))
    page.locator('[data-product=mobility]').click()
    for event in ['REQUEST','ASSIGNED','ARRIVING','STARTED','COMPLETED']:page.locator(f'[data-event={event}]').click()
    check('Complete driver event sequence',lambda:ok(page.locator('#state').inner_text()=='completed'))
    page.locator('[data-product=commerce]').click()
    for event in ['SUBMIT','PAYMENT_AUTHORIZED','CONFIRMED','SHIPPED'] :page.locator(f'[data-event={event}]').click()
    check('Shipped is in transit, not delivered',lambda:ok(page.locator('#state').inner_text()=='in_transit'))
    page.locator('[data-event=DELIVERED]').click();page.locator('[data-event=REQUEST_REFUND]').click()
    check('Refund request is not refunded',lambda:ok(page.locator('#state').inner_text()=='refund_requested'))
    page.locator('[data-event=REFUND_PENDING]').click();page.locator('[data-event=REFUNDED]').click()
    check('Provider refund completion is separate',lambda:ok(page.locator('#state').inner_text()=='refunded'))
    page.locator('#locale').select_option('ar');page.locator('#mode').select_option('dark');page.locator('#reduced').check()
    check('Arabic language and direction are real DOM properties',lambda:ok(page.locator('html').get_attribute('lang')=='ar' and page.locator('html').get_attribute('dir')=='rtl'))
    check('Dark mode changes computed surface',lambda:ok(page.evaluate('getComputedStyle(document.body).backgroundColor')=='rgb(10, 14, 24)'))
    check('Monetary fields stay isolated LTR',lambda:ok(page.locator('#preview bdi[dir=ltr]').count()>=3))
    check('Reduced motion removes art animation',lambda:ok(page.evaluate("[...document.querySelectorAll('.scene-enter')].every(n=>getComputedStyle(n).animationName==='none')")))
    page.screenshot(path=str(out/'lab-desktop-ar-dark.png'),full_page=True)
    page.locator('#locale').select_option('en');page.locator('#mode').select_option('light');page.locator('[data-product=travel]').click();page.locator('#reset').click()
    page.screenshot(path=str(out/'lab-desktop.png'),full_page=True)
    page.set_viewport_size({'width':390,'height':844})
    check('No horizontal overflow at phone width',lambda:ok(page.evaluate('document.documentElement.scrollWidth <= innerWidth')))
    page.locator('#locale').select_option('ar');page.locator('[data-product=mobility]').click()
    check('Mobile RTL also has no horizontal overflow',lambda:ok(page.evaluate('document.documentElement.scrollWidth <= innerWidth')))
    check('Map geographic direction remains LTR',lambda:ok(page.evaluate("getComputedStyle(document.querySelector('.map')).direction")=='ltr'))
    page.screenshot(path=str(out/'lab-phone-ar.png'),full_page=True)
    check('No runtime JavaScript errors',lambda:ok(len(errors)==0))
    browser.close()
report={'total':len(results),'passed':sum(r['passed'] for r in results),'failed':sum(not r['passed'] for r in results),'checks':results}
(out/'browser-results.json').write_text(json.dumps(report,indent=2))
print(json.dumps(report,indent=2)); assert report['failed']==0
