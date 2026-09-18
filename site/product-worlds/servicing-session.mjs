// Local reference simulator only. No auth, persistence, provider calls or money movement.
import { reviewCancellation, requestCancellation, advanceAftercare, newDriverReview,
  recordDriverDocument, submitDriverReview, applyDriverDecision, canDriverGoOnline } from './_servicing/servicing.js';

export const REQUIREMENTS = Object.freeze([
  Object.freeze({kind:'identity',expiryRequired:true}),
  Object.freeze({kind:'licence',expiryRequired:true}),
  Object.freeze({kind:'insurance',expiryRequired:true})
]);
const money = minor => Object.freeze({minor,currency:'LYD',scale:3});
const need = (condition, message) => { if (!condition) throw new Error(message); };
const clean = value => typeof value === 'string' && value.trim().length > 0;

/** Two role views read one local case. All writes are transactional in memory.
 * Provider events are explicitly simulated; these checks are not backend authorization.
 */
export function createServicingSession() {
  const initial = () => {
    const booking = {reference:'OR-DEMO-021',revision:'r1',state:'confirmed',originalPayment:money(1250000n)};
    let driver = newDriverReview('DR-DEMO-1042','VEH-DEMO-1042');
    for (const r of REQUIREMENTS) driver=recordDriverDocument(driver,{kind:r.kind,reference:`DOC-${r.kind}-1`,expiresAtMs:3600000});
    return {now:0,booking,quote:{reference:'CQ-021',bookingReference:booking.reference,bookingRevision:'r1',issuedAtMs:0,expiresAtMs:300000,
      originalPayment:booking.originalPayment,supplierPenalty:money(125000n),agencyFee:money(25000n),returnTo:'original-payment-method'},
      consent:null,acceptedReview:null,driver,checks:[],decision:null,onlineIntent:false,freshUntil:600000,events:[],sequence:1};
  };
  let data=initial();
  function online(d) {return canDriverGoOnline(d.driver,{enabled:true,nowMs:d.now,snapshotFreshUntilMs:d.freshUntil,requirements:REQUIREMENTS});}
  function view() {
    const snapshot=structuredClone(data);
    try {snapshot.review=reviewCancellation(data.booking,data.quote,data.now);snapshot.quoteValid=true;}
    catch {snapshot.review=data.acceptedReview;snapshot.quoteValid=false;}
    snapshot.canGoOnline=online(data);
    snapshot.online=data.onlineIntent && snapshot.canGoOnline;
    return snapshot;
  }
  function act(type,payload={}) {
    const next=structuredClone(data);
    const review=()=>reviewCancellation(next.booking,next.quote,next.now);
    const inReview=()=>need(next.driver.status==='in_review' && !next.decision,'Review is not open');
    const current=()=>need(payload.revision===next.driver.revision,'Document revision changed; review again');
    switch(type) {
      case 'CONSENT': {
        review(); need(typeof payload.accepted==='boolean','Explicit consent choice required');
        next.consent={accepted:payload.accepted,quoteReference:next.quote.reference,bookingReference:next.booking.reference,bookingRevision:next.booking.revision}; break;
      }
      case 'REQUEST_CANCEL': {
        need(next.consent,'Accept the current quote first');
        const result=requestCancellation(next.booking,next.quote,next.consent,next.now);
        next.booking={...next.booking,state:result.state};next.acceptedReview=result;break;
      }
      case 'REFRESH_QUOTE': {
        need(next.booking.state==='confirmed','No new quote for a closed or pending case');
        next.quote={...next.quote,reference:`CQ-DEMO-${++next.sequence}`,bookingRevision:next.booking.revision,issuedAtMs:next.now,expiresAtMs:next.now+300000};next.consent=null;break;
      }
      case 'BOOKING_REVISION_CHANGED': {
        need(next.booking.state==='confirmed','Cannot change a pending case');
        next.booking={...next.booking,revision:`r${++next.sequence}`};next.consent=null;break;
      }
      case 'SUPPLIER_CANCELLED': case 'REFUND_PROCESSING': case 'REFUND_CONFIRMED': {
        const event={SUPPLIER_CANCELLED:'CANCELLED',REFUND_PROCESSING:'REFUND_PENDING',REFUND_CONFIRMED:'REFUNDED'}[type];
        need(payload.authority==='provider' && clean(payload.reference),'Simulated provider reference required');
        need(payload.bookingReference===next.booking.reference && payload.bookingRevision===next.booking.revision,'Provider event does not match this booking revision');
        need(!next.events.some(e=>e.reference===payload.reference),'Duplicate provider event');
        next.booking={...next.booking,state:advanceAftercare(next.booking.state,{type:event,authority:payload.authority,reference:payload.reference})};break;
      }
      case 'SUBMIT_DRIVER': {
        next.driver=submitDriverReview(next.driver,REQUIREMENTS,next.now);next.checks=[];next.decision=null;next.onlineIntent=false;break;
      }
      case 'CHECK_DOCUMENT': {
        inReview();current();need(REQUIREMENTS.some(r=>r.kind===payload.kind),'Unknown document');need(typeof payload.checked==='boolean','Explicit check required');
        next.checks=next.checks.filter(k=>k!==payload.kind);if(payload.checked)next.checks.push(payload.kind);break;
      }
      case 'QUEUE_DECISION': {
        inReview();current();need(['approved','needs_action'].includes(payload.result),'Unknown decision');
        need(clean(payload.reason) && payload.reason.trim().length>=8 && payload.reason.length<=500,'Enter a review note of 8–500 characters');
        if(payload.result==='approved')need(REQUIREMENTS.every(r=>next.checks.includes(r.kind)),'Check every document before approval');
        // This is an operator INTENT. The provider result must still be applied separately.
        next.decision={result:payload.result,reason:payload.reason.trim(),revision:next.driver.revision,reference:`REV-DEMO-${++next.sequence}`,approvedUntilMs:next.now+1800000};break;
      }
      case 'APPLY_DECISION': {
        need(next.decision,'No decision awaiting acknowledgement');
        need(payload.authority==='provider','Only a simulated provider acknowledgement applies a decision');
        need(payload.revision===next.decision.revision,'Stale review acknowledgement');
        const d=next.decision;
        next.driver=applyDriverDecision(next.driver,{authority:'provider',driverReference:next.driver.driverReference,vehicleReference:next.driver.vehicleReference,
          revision:d.revision,reviewReference:d.reference,result:d.result,approvedUntilMs:d.approvedUntilMs},REQUIREMENTS,next.now);
        next.freshUntil=next.now+600000;next.decision=null;next.onlineIntent=false;break;
      }
      case 'REPLACE_DOCUMENT': {
        need(next.driver.status!=='suspended','Suspension requires operator resolution, not a new upload');
        need(!next.decision,'Wait for the queued decision');
        need(REQUIREMENTS.some(r=>r.kind===payload.kind),'Unknown document');
        next.driver=recordDriverDocument(next.driver,{kind:payload.kind,reference:`DOC-${payload.kind}-${++next.sequence}`,expiresAtMs:next.now+3600000});
        next.checks=[];next.onlineIntent=false;break;
      }
      case 'REFRESH_SNAPSHOT': {
        need(payload.authority==='provider','Snapshot freshness must be provider-confirmed');next.freshUntil=next.now+600000;break;
      }
      case 'GO_ONLINE': {need(online(next),'Driver is not eligible with this snapshot');next.onlineIntent=true;break;}
      case 'GO_OFFLINE': {next.onlineIntent=false;break;}
      case 'SUSPEND_DRIVER': {
        need(payload.authority==='provider','A provider suspension event is required');
        next.driver=applyDriverDecision(next.driver,{authority:'provider',driverReference:next.driver.driverReference,vehicleReference:next.driver.vehicleReference,
          revision:next.driver.revision,reviewReference:`SUS-DEMO-${++next.sequence}`,result:'suspended'},REQUIREMENTS,next.now);
        next.onlineIntent=false;next.decision=null;break;
      }
      case 'ADVANCE_CLOCK': {
        need(Number.isSafeInteger(payload.ms) && payload.ms>0 && Number.isSafeInteger(next.now+payload.ms),'Positive safe clock increment required');
        next.now+=payload.ms;if(!online(next))next.onlineIntent=false;break;
      }
      default: throw new Error('Unknown local action');
    }
    next.events.push({number:next.events.length+1,type,atMs:next.now,reference:payload.reference??next.decision?.reference??null,
      bookingState:next.booking.state,driverState:next.driver.status,revision:next.driver.revision,reason:type==='QUEUE_DECISION'?payload.reason.trim():null});
    data=next;return view();
  }
  return Object.freeze({view,act,reset(){data=initial();return view();}});
}
