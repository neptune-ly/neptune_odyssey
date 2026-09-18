/* ponytail: in-memory demo state; replace the boundary with authenticated APIs for production. */
const {amount,money,initial,settle,bill}=OdysseyModel;
const screens=Object.fromEntries(ODYSSEY_SCREENS.map(s=>[s.key,s]));
const prefixes={Clarity:'A',Reserve:'N',Drive:'D',Orbit:'O'};
const states=Object.fromEntries(Object.keys(prefixes).map(b=>[b,initial()]));
const $=s=>document.querySelector(s), esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
let current='A01', mode='light', timer, error='';
const propsKey=(prefix,key)=>['first','last','email','passport','card','expiry','cvv'].includes(key)?'O-'+key:prefix+'-'+key;
const goButton=(to,label,kind='primary',key='')=>`<button type="button" class="${kind}" data-to="${esc(to)}" data-key="${key}">${esc(label)}</button>`;
const defaults={'Balance':{Label:'Available balance',Amount:'12,480.000 LYD',Meta:'Current account · 2148'},'Payment card':{Name:'Amal Ben Musa',Number:'••••  ••••  ••••  2148',State:'Active'},'Illustrated panel':{Title:'Your bank.\nWithin reach.',Detail:'Support when you need it.'}};
function property(item,s,st){
 const p={...(ODYSSEY_DEFAULTS[item.component]||{}),...(defaults[item.component]||{}),...(item.props||{})},k=s.key.slice(1),bank=['A','N'].includes(s.key[0]);
 if(bank){
  if(item.component==='Balance')p.Amount=money(st.balance);
  for(const name of Object.keys(p))if(typeof p[name]==='string')p[name]=p[name].replace(/250\.000 LYD/g,money(st.amount)).replace(/251\.000 LYD/g,money(st.amount+st.fee));
  if(item.key==='amount')p.Helper='Available '+money(st.balance);
  if(['06','07','09'].includes(k)&&item.component==='Summary'){p.Details=(p.Details||'').replace(/Amal Ben Musa/g,st.fields[s.key[0]+'-name']||'Amal Ben Musa').replace(/4092/g,(st.fields[s.key[0]+'-account']||'4092').slice(-4));}
  if(k==='09'&&item.key==='summary')p.Details+='\nAvailable after transfer  '+money(st.balance);
  if(item.key==='outgoing')p.Value='−'+money(st.amount+st.fee);
 }
 if(s.brand==='Drive'){
  if(item.component==='Journey'){p.Origin=st.fields['D-pickup']||p.Origin;p.Destination=st.fields['D-search']||st.fields['D-destination']||p.Destination;}
  if(k==='18'&&item.component==='Balance')p.Amount=money(st.income);
 }
 if(s.brand==='Orbit'){
  const name=(st.fields['O-first']||'Amal')+' '+(st.fields['O-last']||'Saleh');
  for(const key of Object.keys(p))if(typeof p[key]==='string')p[key]=p[key].replace(/Amal Saleh/g,name).replace(/amal@example.com/g,st.fields['O-email']||'amal@example.com');
  if(item.component==='Journey')p.Detail=(st.fields['O-date']||'2026-10-22')+' · 10:30–10:40 · 1h 10m\nAll departure / arrival times are local.';
  if(k==='03'&&item.key==='heading')p.Detail=(st.fields['O-date']||'2026-10-22')+' · 1 adult · Prices include taxes';
 }
 return p;
}
function itemHTML(item,s,st){
 const p=property(item,s,st), to=item.to, key=item.key, state=(item.state||'').replace('State=',''), tag=to?'button':'div';
 const attrs=to?`type="button" data-to="${esc(to)}" data-key="${key}"`:'';
 if(item.art)return `<img class="hero-art" src="../assets/${item.art}.svg" style="width:${item.width||354}px" alt="">`;
 switch(item.component){
 case 'Heading': return `<section class="heading">${p.Eyebrow?`<p class="eyebrow">${esc(p.Eyebrow)}</p>`:''}<h2>${esc(p.Title)}</h2>${p.Detail?`<p>${esc(p.Detail)}</p>`:''}</section>`;
 case 'App bar': return `<div class="appbar"><button type="button" data-to="${to}">${esc(p.Back||'‹ Back')}</button><span>${esc(p.Title)}</span></div>`;
 case 'Button': return goButton(to,p.Label,(item.state||'').includes('Secondary')?'secondary':(item.state||'').includes('Quiet')?'quiet':'primary',key);
 case 'Field': {
  const fieldKey=propsKey(s.key[0],key);let value=st.fields[fieldKey]??p.Value??'',type='text',extra='',helper=p.Helper||'';
  if(key==='passcode'){type='password';value=st.fields[fieldKey]??'123456';helper='Test passcode: 123456. Do not enter your real passcode.';}
  if(key==='otp'){value=st.fields[fieldKey]??'123456';extra='inputmode="numeric" maxlength="6"';helper='Test code: 123456';}
  if(key==='email')type='email'; if(key==='cvv'){type='password';extra='inputmode="numeric" maxlength="4"';}
  if(['amount','number','phone','customer','pin'].includes(key))extra='inputmode="decimal"';
  if(key==='account')value=st.fields[fieldKey]??'001004092';
  if(key==='date'){type='date';value=st.fields[fieldKey]??'2026-10-22';extra='min="2026-09-18"';}
  const fixed=(s.brand==='Orbit'&&['from','to'].includes(key))||key==='provider';
  if(fixed)helper='Fixed route in this prototype';
  return `<div class="field"><label for="${key}">${esc(p.Label)}</label><input id="${key}" name="${key}" type="${type}" value="${esc(value)}" ${extra} ${fixed?'readonly':''} autocomplete="off" data-field="${fieldKey}" aria-describedby="${key}-help"><small id="${key}-help">${esc(helper)}</small></div>`;
 }
 case 'Balance': return `<${tag} ${attrs} class="balance"><span>${esc(p.Label)}</span><strong><bdi>${esc(p.Amount)}</bdi></strong><small>${esc(p.Meta)}</small></${tag}>`;
 case 'Status': return `<div class="status" data-state="${state}" role="status"><strong>${esc(p.Title)}</strong><p>${esc(p.Detail)}</p></div>`;
 case 'Summary':return `<section class="summary"><strong>${esc(p.Title)}</strong><div class="details">${esc(p.Details)}</div><div class="total"><bdi>${esc(p.Total)}</bdi></div></section>`;
 case 'List row':return `<${tag} ${attrs} class="card"><strong>${esc(p.Title)}</strong><span class="detail">${esc(p.Detail)}</span><span class="value"><bdi>${esc(p.Value)}</bdi></span></${tag}>`;
 case 'Flight option': case 'Ride option':return `<${tag} ${attrs} class="card"><strong>${esc(p.Route||p.Title||p.Name||'Everyday')}</strong><span class="detail">${esc(p.Detail)}</span><span class="value">${esc(p.Price||p.Value)}</span></${tag}>`;
 case 'Choice':
  if(key==='rating')return `<div class="field"><label for="rating">How was your ride?</label><select id="rating" data-rating>${[5,4,3,2,1].map(n=>`<option value="${n}" ${st.rating===n?'selected':''}>${n} out of 5</option>`).join('')}</select></div>`;
  if(!to)return `<div class="choice"><label><input type="checkbox" ${state==='Selected'?'checked':''} data-consent="${key}"><span><strong>${esc(p.Label)}</strong><br><span class="detail">${esc(p.Detail)}</span></span></label></div>`;
  return `<button ${attrs} class="choice" aria-pressed="${state==='Selected'}"><strong>${esc(p.Label)}</strong><span class="detail">${esc(p.Detail)}</span></button>`;
 case 'Journey':return `<section class="journey"><strong>${esc(p.Origin)}</strong><div class="route-line"></div><strong>${esc(p.Destination)}</strong><span class="detail">${esc(p.Detail)}</span></section>`;
 case 'Illustrated panel':return `<${tag} ${attrs} class="illustrated-panel"><div><strong>${esc(p.Title)}</strong><p>${esc(p.Detail)}</p></div><img src="../assets/wallet-hand.svg" alt=""></${tag}>`;
 case 'Navigation bar':return `<nav class="navigation" aria-label="Main navigation">${(s.locale==='ar'?[...item.slots].reverse():item.slots).map(slot=>`<button type="button" data-to="${slot.to}" ${slot.to===(/AR$|DK$/.test(s.key)?s.key[0]+(['A','N'].includes(s.key[0])?'03':'02'):s.key)?'aria-current="page"':''}>${esc(slot.label)}</button>`).join('')}</nav>`;
 case 'Payment card':return `<div class="payment-card"><span>NEPTUNE / ${esc(s.brand.toUpperCase())}</span><strong>•••• •••• •••• 2148</strong><span>Amal Ben Musa · ${st.frozen?'Frozen':'Active'}</span></div>`;
 case 'Sheet':return `<section class="summary"><strong>${esc(p.Title)}</strong><div class="details">${esc(p.Detail)}</div></section>`;
 default:return '';
 }
}
function render(){
 clearTimeout(timer);const s=screens[current],st=states[s.brand];
 document.documentElement.dataset.brand=s.brand;document.documentElement.dataset.mode=mode;document.documentElement.lang=s.locale==='ar'?'ar':'en';$('#screen').dir=s.locale==='ar'?'rtl':'ltr';$('#brand').value=s.brand;
 $('#appearance').setAttribute('aria-pressed',String(mode==='dark'));$('#appearance').textContent=mode==='dark'?'Light mode':'Dark mode';$('#language').textContent=s.locale==='ar'?'English':'العربية';
 $('#screen-name').textContent=s.title;$('#route-info').textContent=`${current} · ${s.brand} · ${s.locale==='ar'?'Arabic home preview':'English journey'}`;
 $('#world-art').src='../assets/'+({Clarity:'everyday-people',Reserve:'local-bank',Drive:'drive-street',Orbit:'orbit-departure'}[s.brand])+'.svg';
 $('#world-note').textContent={Clarity:'Confidence, with a human touch. Clear decisions come first.',Reserve:'Quiet confidence. Familiar service, thoughtfully drawn.',Drive:'Friendly movement. A clear pickup, a familiar face, a safer journey.',Orbit:'Room to explore. Every fare and every next step in view.'}[s.brand];
 let body=s.items.map(item=>itemHTML(item,s,st)).join('');
 if(current==='O13'&&!st.booked)body=`<section class="heading"><p class="eyebrow">YOUR BOOKINGS</p><h2>Your next story awaits.</h2><p>No trips booked yet.</p></section><img class="hero-art" src="../assets/orbit-departure.svg" alt="">`+goButton('O02','Find a flight');
 if(current==='D18'&&st.settled)body=body.replace('96.000 LYD',money(st.income));
 if(['A09','N09','O11','O26'].includes(current))body+='<button type="button" class="quiet" data-download>Download receipt / itinerary</button>';
 $('#screen').innerHTML=`<form novalidate class="product ${current.endsWith('01')?'welcome':''}"><div class="system-bar" aria-hidden="true"><span>9:41</span><span>5G · 100%</span></div>${error?`<div class="error-banner" role="alert" tabindex="-1">${esc(error)}</div>`:''}${body}</form>`;
 const examples=s.brand==='Orbit'?[['O12','Unknown payment'],['O19','Declined payment'],['O17','Price changed']]:s.brand==='Drive'?[['D13','Cancel a ride'],['D15','Driver journey'],['D14','Manual pickup']]:[[s.key[0]+'10','Unknown transfer'],[s.key[0]+'11','Failed transfer'],[s.key[0]+'20','Expired code']];
 $('#scenario-list').innerHTML=examples.map(([to,label])=>goButton(to,label,'quiet')).join('');
 if(current==='D09')timer=setTimeout(()=>navigate('D10'),8000);
 if(error) $('.error-banner').focus();
}
function capture(){const st=states[screens[current].brand];for(const input of $('#screen').querySelectorAll('[data-field]'))st.fields[input.dataset.field]=input.value;const rating=$('[data-rating]');if(rating)st.rating=Number(rating.value);}
function validate(to){
 const s=screens[current],st=states[s.brand],p=current[0],step=current.slice(1),v=k=>(st.fields[propsKey(p,k)]||'').trim();
 const advancing=$('#screen [data-to="'+to+'"][class="primary"]');if(!advancing)return;
 for(const input of $('#screen').querySelectorAll('[data-field]'))if(!['reference','comment'].includes(input.name)&&!input.value.trim())throw Error('Please fill in '+input.labels[0].textContent.toLowerCase()+'.');
 if(['A','N'].includes(p)){
  if(step==='02'&&v('passcode')!=='123456')throw Error('Use the test passcode 123456.');
  if(step==='05'){const n=amount(v('amount'));if(n<=0)throw Error('Enter an amount greater than zero.');if(n+st.fee>st.balance)throw Error('The amount and fee exceed your available balance.');st.amount=n;}
  if(step==='07'&&v('otp').replace(/\s/g,'')!=='123456')throw Error('That code does not match. Use the test code 123456.');
  if(step==='17'&&!$('[data-consent]').checked)throw Error('Review and accept the account terms to continue.');
  if(step==='19'&&!/^\d{8,24}$/.test(v('account')))throw Error('Enter an account number of 8–24 digits.');
 }
 if(current==='D17'&&v('pin').replace(/\s/g,'')!=='4821')throw Error('The rider PIN does not match. Use 4821.');
 if(p==='O'){
  if(step==='05'&&!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v('email')))throw Error('Enter a valid email address.');
  if(['08','25'].includes(step)){if(v('card').replace(/\s/g,'')!=='4242424242424242')throw Error('Use the test card 4242 4242 4242 4242.');if(!/^\d{3,4}$/.test(v('cvv')))throw Error('Enter a 3 or 4 digit security code.');if(!/^(0[1-9]|1[0-2])\/\d{2}$/.test(v('expiry')))throw Error('Use MM/YY for expiry.');}
 }
}
function navigate(to){
 if(!screens[to])return;capture();const s=screens[current],st=states[s.brand],p=current[0];
 try{validate(to);if(['A','N'].includes(p)){
  if(current===p+'02'&&to===p+'03')Object.assign(st,initial());
  if(to===p+'04'&&current===p+'03')st.transfer='draft';
  if(to===p+'08')st.transfer='pending';
  if(to===p+'10')st.transfer='unknown';
  if(to===p+'09'&&[p+'08',p+'10'].includes(current))settle(st);
  if(to===p+'11')st.transfer='failed';
  if(to===p+'15'&&current===p+'14')st.bill='draft';
  if(to===p+'23')bill(st);
  if(to===p+'13')st.frozen=true;if(to===p+'12')st.frozen=false;
 }
 if(current==='D23'&&to==='D18'&&!st.settled){st.income+=16000;st.settled=true;}
 if(to==='D16')st.settled=false;
 if(to==='O21')st.bag=true;if(to==='O07')st.bag=false;
 if(['O10','O26'].includes(to))st.booked=true;
 if(to==='O22'){st.booked=false;st.cancelled=true;}
 error='';if(to.endsWith('DK'))mode='dark';location.hash=to;if(current===to)render();
 }catch(e){error=e.message;render();}
}
document.addEventListener('click',e=>{const btn=e.target.closest('[data-to]');if(btn){e.preventDefault();navigate(btn.dataset.to);}if(e.target.closest('[data-download]')){const s=screens[current],st=states[s.brand];const text=s.title+'\nDESIGN PROTOTYPE — SAMPLE ONLY\n'+s.items.filter(i=>i.props).map(i=>Object.values(property(i,s,st)).join('\n')).join('\n\n');const url=URL.createObjectURL(new Blob([text],{type:'text/plain;charset=utf-8'}));const a=document.createElement('a');a.href=url;a.download=current+'-sample-receipt.txt';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}});
document.addEventListener('submit',e=>{e.preventDefault();const action=$('#screen .primary[data-to]');if(action)navigate(action.dataset.to);});
$('#brand').addEventListener('change',e=>{error='';location.hash=prefixes[e.target.value]+'01';});
$('#appearance').onclick=()=>{capture();mode=mode==='light'?'dark':'light';render();};
$('#language').onclick=()=>{const s=screens[current],p=current[0];navigate(s.locale==='ar'?p+(['A','N'].includes(p)?'03':'02'):p+'AR');};
$('#reset').onclick=()=>{const brand=screens[current].brand;states[brand]=initial();error='';location.hash=prefixes[brand]+'01';render();};
window.addEventListener('hashchange',()=>{const next=location.hash.slice(1);if(screens[next])current=next;error='';render();$('#screen').focus();window.scrollTo({top:0,behavior:'instant'});});
if(screens[location.hash.slice(1)])current=location.hash.slice(1);
if(['A','N'].includes(current[0])){const st=states[screens[current].brand];if(current.endsWith('10'))st.transfer='unknown';if(current.endsWith('08'))st.transfer='pending';if(current.endsWith('09')){st.transfer='pending';settle(st);}}
render();
