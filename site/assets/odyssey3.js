// Theme specimen uses the SDK; text/layout express product identity.
(() => {
  const specimen = document.getElementById('specimen');
  const expression = document.getElementById('expression-choice');
  const mode = document.getElementById('mode-toggle');
  const language = document.getElementById('language-toggle');
  const copy = {
    en: {brand:'Neptune. Everyday',demo:'Design specimen',greeting:'A brighter everyday.',subtitle:'Your money, at a glance.',balance:'Available balance',primary:'Send money ↗',secondary:'Explore services',activity:'Recent activity',period:'Today',purchase:'Everyday essentials',purchaseDetail:'Card purchase · 10:42',received:'Transfer received',receivedDetail:'Current account · 09:16',story:'Room for your next chapter.'},
    ar: {brand:'نبتون. كل يوم',demo:'نموذج تصميم',greeting:'يومك أكثر إشراقاً.',subtitle:'أموالك، بنظرة واحدة.',balance:'الرصيد المتاح',primary:'إرسال أموال ↖',secondary:'اكتشف الخدمات',activity:'آخر العمليات',period:'اليوم',purchase:'احتياجات يومية',purchaseDetail:'شراء بالبطاقة · 10:42',received:'حوالة واردة',receivedDetail:'الحساب الجاري · 09:16',story:'مساحة لفصلك القادم.'}
  };
  function render() {
    const composed = expression.value === 'composed';
    const dark = mode.getAttribute('aria-pressed') === 'true';
    const ar = language.getAttribute('aria-pressed') === 'true';
    Neptune.applyTheme(specimen, 'neptune', {edition:'odyssey3',product:'wallet',mode:dark?'dark':'light',dir:ar?'rtl':'ltr',reducedMotion:matchMedia('(prefers-reduced-motion: reduce)').matches});
    specimen.lang = ar?'ar':'en';
    specimen.classList.toggle('composed',composed);
    document.getElementById('expression-layout').classList.toggle('dark-demo',dark);
    specimen.querySelectorAll('[data-copy]').forEach(el => el.textContent=copy[ar?'ar':'en'][el.dataset.copy]);
    if(composed) {
      specimen.querySelector('[data-copy="brand"]').textContent=ar?'نبتون. الحسابات':'Neptune. Accounts';
      specimen.querySelector('[data-copy="greeting"]').textContent=ar?'كل التفاصيل أمامك.':'A clear view of your money.';
    }
    document.getElementById('expression-name').textContent=composed?'Assured. Precise. Alive.':'Warm. Bright. Everyday.';
    document.getElementById('expression-description').textContent=composed?'A decisive ink balance band, disciplined functional type and an open ledger make the same content feel composed.':'An open composition with a vivid balance pocket, rounded display voice and one small editorial moment.';
    document.getElementById('expression-rule').textContent=composed?'Ink leads. One accent supports. Rules and space give the data a clear rhythm.':'Cyan leads. Lilac supports. Ink gives the details their structure.';
  }
  expression.addEventListener('change',render);
  for(const button of [mode,language]) button.addEventListener('click',()=>{button.setAttribute('aria-pressed',String(button.getAttribute('aria-pressed')!=='true'));render();});
  render();
})();
