// Integer milli-dinars keep fee and balance arithmetic exact.
(function(root) {
  function amount(value) {
    const text = String(value).trim();
    if (!/^\d{1,7}(\.\d{1,3})?$/.test(text)) throw Error('Enter an amount with at most 3 decimal places.');
    const [whole, fraction = ''] = text.split('.');
    return Number(whole) * 1000 + Number(fraction.padEnd(3, '0'));
  }
  const money = n => (n / 1000).toLocaleString('en-GB', {minimumFractionDigits:3, maximumFractionDigits:3}) + ' LYD';
  const initial = () => ({balance:12480000, amount:250000, fee:1000, transfer:'draft', bill:'draft', frozen:false, fields:{}, bag:false, booked:false, cancelled:false, rating:5, income:96000, settled:false});
  function settle(state) {
    if (state.transfer === 'confirmed') return;
    if (state.transfer !== 'pending' && state.transfer !== 'unknown') throw Error('No submitted transfer to settle.');
    if (state.amount <= 0 || state.amount + state.fee > state.balance) throw Error('The total is above the available balance.');
    state.balance -= state.amount + state.fee;
    state.transfer = 'confirmed';
  }
  function bill(state) { if(state.bill === 'paid') return; if(state.balance < 20000) throw Error('Insufficient balance.'); state.balance -= 20000; state.bill='paid'; }
  const api = {amount,money,initial,settle,bill};
  if (typeof module !== 'undefined') module.exports=api; else root.OdysseyModel=api;
})(typeof window === 'undefined' ? globalThis : window);
