// Neptune Odyssey — Orbit aftercare and Move driver readiness.
// UI policy only. The host must authenticate, order and deduplicate events,
// persist state, enforce permissions and revalidate before any real operation.
import { sumMoney, transitionJourney, type Money, type JourneyEvent } from './experience.js';

function nonblank(value: unknown, name: string): asserts value is string {
  if (typeof value !== 'string' || !value.trim()) throw new TypeError(`${name} is required`);
}
function clock(value: number): void {
  if (!Number.isSafeInteger(value) || value < 0) throw new TypeError('Expected nonnegative integer milliseconds');
}
function nonnegative(value: Money): Money {
  const copy = sumMoney([value]);
  if (copy.minor < 0n) throw new RangeError('Negative servicing amount');
  return copy;
}
function sameMoney(a: Money, b: Money): boolean {
  return a.minor === b.minor && a.currency === b.currency && a.scale === b.scale;
}
export interface ServicedBooking {
  readonly reference: string;
  readonly revision: string;
  readonly state: string;
  readonly originalPayment: Money;
}
export interface CancellationQuote {
  readonly reference: string;
  readonly bookingReference: string;
  readonly bookingRevision: string;
  readonly issuedAtMs: number;
  readonly expiresAtMs: number;
  readonly originalPayment: Money;
  readonly supplierPenalty: Money;
  readonly agencyFee: Money;
  readonly returnTo: 'original-payment-method';
}
/** Reuse canonical minor-unit arithmetic. A quote is not cancellation consent. */
export function reviewCancellation(booking: ServicedBooking, quote: CancellationQuote, nowMs: number) {
  nonblank(booking.reference, 'Booking reference'); nonblank(booking.revision, 'Booking revision');
  nonblank(quote.reference, 'Quote reference');
  clock(nowMs); clock(quote.issuedAtMs); clock(quote.expiresAtMs);
  if (booking.state !== 'confirmed') throw new RangeError('Booking is not eligible for a new cancellation');
  if (quote.bookingReference !== booking.reference || quote.bookingRevision !== booking.revision) {
    throw new RangeError('Quote does not match the current booking revision');
  }
  if (quote.issuedAtMs > nowMs || quote.expiresAtMs <= nowMs || quote.expiresAtMs <= quote.issuedAtMs) {
    throw new RangeError('Cancellation quote is not currently valid');
  }
  const originalPayment = nonnegative(booking.originalPayment);
  if (!sameMoney(originalPayment, nonnegative(quote.originalPayment))) throw new RangeError('Original payment mismatch');
  const supplierPenalty = nonnegative(quote.supplierPenalty), agencyFee = nonnegative(quote.agencyFee);
  const retainedFees = sumMoney([supplierPenalty, agencyFee]);
  // Including originalPayment validates currencies/scales even when both fees are zero.
  sumMoney([originalPayment, retainedFees]);
  if (retainedFees.minor > originalPayment.minor) throw new RangeError('Fees exceed the original payment');
  if (quote.returnTo !== 'original-payment-method') throw new RangeError('Unsupported refund destination');
  const estimatedRefund = Object.freeze({ ...originalPayment, minor: originalPayment.minor - retainedFees.minor });
  return Object.freeze({ quoteReference: quote.reference, bookingReference: booking.reference,
    bookingRevision: booking.revision, originalPayment, supplierPenalty, agencyFee, retainedFees,
    estimatedRefund, returnTo: quote.returnTo, expiresAtMs: quote.expiresAtMs });
}
export interface CancellationConsent {
  readonly accepted: boolean;
  readonly quoteReference: string;
  readonly bookingReference: string;
  readonly bookingRevision: string;
}
/** Host must revalidate and persist the intent atomically; this is not an idempotency store. */
export function requestCancellation(booking: ServicedBooking, quote: CancellationQuote, consent: CancellationConsent, nowMs: number) {
  const review = reviewCancellation(booking, quote, nowMs);
  if (consent.accepted !== true || consent.quoteReference !== review.quoteReference ||
      consent.bookingReference !== review.bookingReference || consent.bookingRevision !== review.bookingRevision) {
    throw new TypeError('Explicit consent for the current quote and booking is required');
  }
  return Object.freeze({ ...review, state: transitionJourney('booking', booking.state, { type: 'CANCEL', authority: 'user' }) });
}
/** Keep provider cancellation, refund processing and confirmed credit as separate states. */
export function advanceAftercare(state: string, event: JourneyEvent): string {
  if (!['cancel_requested', 'cancelled', 'refund_pending'].includes(state) ||
      !['CANCELLED', 'REFUND_PENDING', 'REFUNDED'].includes(event.type)) throw new RangeError('Invalid aftercare event');
  return transitionJourney('booking', state, event);
}

export type DriverReviewStatus = 'draft' | 'in_review' | 'needs_action' | 'approved' | 'suspended';
export interface DriverDocument { readonly kind: string; readonly reference: string; readonly expiresAtMs: number | null; }
export interface DriverRequirement { readonly kind: string; readonly expiryRequired: boolean; }
export interface DriverReview {
  readonly driverReference: string;
  readonly vehicleReference: string;
  readonly revision: number;
  readonly status: DriverReviewStatus;
  readonly documents: readonly DriverDocument[];
  readonly reviewReference: string | null;
  readonly approvedUntilMs: number | null;
}
function document(value: DriverDocument): DriverDocument {
  nonblank(value.kind, 'Document kind'); nonblank(value.reference, 'Document reference');
  if (value.expiresAtMs !== null) clock(value.expiresAtMs);
  return Object.freeze({ kind: value.kind, reference: value.reference, expiresAtMs: value.expiresAtMs });
}
function snapshot(value: DriverReview): DriverReview {
  nonblank(value.driverReference, 'Driver reference'); nonblank(value.vehicleReference, 'Vehicle reference');
  if (!Number.isSafeInteger(value.revision) || value.revision < 0) throw new RangeError('Invalid document revision');
  if (!['draft','in_review','needs_action','approved','suspended'].includes(value.status)) throw new RangeError('Unknown driver review status');
  if (!Array.isArray(value.documents)) throw new TypeError('Documents must be an array');
  const documents = value.documents.map(document);
  if (new Set(documents.map(x => x.kind)).size !== documents.length) throw new RangeError('Duplicate document kind');
  if (value.reviewReference !== null) nonblank(value.reviewReference, 'Review reference');
  if (value.approvedUntilMs !== null) clock(value.approvedUntilMs);
  return Object.freeze({ driverReference: value.driverReference, vehicleReference: value.vehicleReference,
    revision: value.revision, status: value.status, documents: Object.freeze(documents),
    reviewReference: value.reviewReference, approvedUntilMs: value.approvedUntilMs });
}
function eligibleDocuments(value: DriverReview, requirements: readonly DriverRequirement[], nowMs: number): boolean {
  clock(nowMs);
  if (!Array.isArray(requirements) || !requirements.length) throw new TypeError('Explicit nonempty operator requirements are required');
  const kinds = new Set<string>();
  for (const requirement of requirements) {
    nonblank(requirement.kind, 'Required document kind');
    if (kinds.has(requirement.kind) || typeof requirement.expiryRequired !== 'boolean') throw new TypeError('Invalid or duplicate requirement');
    kinds.add(requirement.kind);
    const d = value.documents.find(x => x.kind === requirement.kind);
    if (!d || (requirement.expiryRequired && d.expiresAtMs === null) ||
        (d.expiresAtMs !== null && d.expiresAtMs <= nowMs)) return false;
  }
  return true;
}
export function newDriverReview(driverReference: string, vehicleReference: string): DriverReview {
  return snapshot({ driverReference, vehicleReference, revision: 0, status: 'draft', documents: [], reviewReference: null, approvedUntilMs: null });
}
/** Replacing a document always clears approval. Do not accept edits while review is pending. */
export function recordDriverDocument(value: DriverReview, uploaded: DriverDocument): DriverReview {
  const current = snapshot(value), next = document(uploaded);
  if (current.status === 'in_review') throw new RangeError('Wait for the current review result');
  return snapshot({ ...current, revision: current.revision + 1, status: 'draft', reviewReference: null, approvedUntilMs: null,
    documents: [...current.documents.filter(x => x.kind !== next.kind), next] });
}
export function submitDriverReview(value: DriverReview, requirements: readonly DriverRequirement[], nowMs: number): DriverReview {
  const current = snapshot(value);
  if (!['draft','needs_action'].includes(current.status) || !eligibleDocuments(current, requirements, nowMs)) {
    throw new RangeError('Current required documents are needed before submission');
  }
  return snapshot({ ...current, status: 'in_review', reviewReference: null, approvedUntilMs: null });
}
export interface DriverDecision {
  readonly authority: 'provider';
  readonly driverReference: string;
  readonly vehicleReference: string;
  readonly revision: number;
  readonly reviewReference: string;
  readonly result: 'approved' | 'needs_action' | 'suspended';
  readonly approvedUntilMs?: number;
}
/** Authority is an integration contract, not authentication. The host verifies signed/session-authorized events. */
export function applyDriverDecision(value: DriverReview, decision: DriverDecision, requirements: readonly DriverRequirement[], nowMs: number): DriverReview {
  const current = snapshot(value); clock(nowMs); nonblank(decision.reviewReference, 'Provider review reference');
  if (decision.authority !== 'provider' || decision.driverReference !== current.driverReference ||
      decision.vehicleReference !== current.vehicleReference || decision.revision !== current.revision) throw new TypeError('Decision does not match the current driver, vehicle and document revision');
  if (!['approved','needs_action','suspended'].includes(decision.result)) throw new RangeError('Unknown review decision');
  const allowed = decision.result === 'suspended' ? current.status === 'approved' : current.status === 'in_review';
  if (!allowed) throw new RangeError('Unexpected or already applied review decision');
  let approvedUntilMs: number | null = null;
  if (decision.result === 'approved') {
    clock(decision.approvedUntilMs as number);
    if ((decision.approvedUntilMs as number) <= nowMs || !eligibleDocuments(current, requirements, nowMs)) throw new RangeError('Approval requires current documents and a future validity boundary');
    approvedUntilMs = decision.approvedUntilMs as number;
  }
  return snapshot({ ...current, status: decision.result, reviewReference: decision.reviewReference, approvedUntilMs });
}
export interface DriverOnlineContext {
  readonly enabled: boolean;
  readonly nowMs: number;
  /** Host-approved freshness deadline, not a guessed device TTL. */
  readonly snapshotFreshUntilMs: number;
  readonly requirements: readonly DriverRequirement[];
}
/** Fail closed for stale, expired, suspended, unapproved or malformed UI snapshots. Never executes GO_ONLINE. */
export function canDriverGoOnline(value: DriverReview, context: DriverOnlineContext): boolean {
  try {
    const current = snapshot(value); clock(context.nowMs); clock(context.snapshotFreshUntilMs);
    return context.enabled === true && current.status === 'approved' && !!current.reviewReference &&
      current.approvedUntilMs !== null && context.nowMs < current.approvedUntilMs &&
      context.nowMs < context.snapshotFreshUntilMs && eligibleDocuments(current, context.requirements, context.nowMs);
  } catch { return false; }
}
