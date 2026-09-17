// Neptune Odyssey 2.0 — additive cross-product experience policy.
// UI policy only: this module does not authenticate events or execute transactions.

export const VISUAL_WORLDS = ["orbit", "current", "bloom", "atelier", "signal", "horizon"] as const;
export type VisualWorld = (typeof VISUAL_WORLDS)[number];
export type ExperienceLocale = "en" | "ar";
export type AppearanceMode = "light" | "dark";
export interface NavigationDestination {
  readonly id: string;
  readonly label: Readonly<Record<ExperienceLocale, string>>;
}
export interface ProductGrammar {
  readonly primaryObject: string;
  readonly appearanceRecipe: string;
  readonly density: "comfortable" | "compact";
  readonly navigation: readonly NavigationDestination[];
  readonly capabilities: readonly string[];
  readonly surfaces: readonly string[];
}

function deepFreeze<T>(value: T): Readonly<T> {
  if (value !== null && typeof value === "object" && !Object.isFrozen(value)) {
    Object.freeze(value);
    for (const child of Object.values(value)) deepFreeze(child);
  }
  return value;
}
function grammar(
  primaryObject: string, appearanceRecipe: string,
  navigation: readonly (readonly [string, string, string])[],
  capabilities: readonly string[], density: "comfortable" | "compact" = "comfortable",
  surfaces: readonly string[] = ["phone", "tablet", "web"],
): ProductGrammar {
  return deepFreeze({ primaryObject, appearanceRecipe, density, capabilities: [...capabilities], surfaces: [...surfaces],
    navigation: navigation.map(([id, en, ar]) => ({ id, label: { en, ar } })) });
}

/** Product grammar is orthogonal to the original six visual worlds and tenant identity. */
export const PRODUCT_GRAMMARS = deepFreeze({
  "retail-bank": grammar("account", "current", [["home","Overview","الرئيسية"],["accounts","Accounts","الحسابات"],["pay","Payments","المدفوعات"],["profile","Profile","حسابي"]], ["accounts","transfers","cards","bills"]),
  "corporate-bank": grammar("approval", "signal", [["overview","Overview","نظرة عامة"],["payments","Payments","المدفوعات"],["approvals","Approvals","الموافقات"],["reports","Reports","التقارير"]], ["bulk-payments","maker-checker","audit","permissions"], "compact", ["desktop","tablet"]),
  wallet: grammar("available-balance", "orbit", [["home","Wallet","المحفظة"],["activity","Activity","الحركات"],["pay","Pay","ادفع"],["services","Services","الخدمات"]], ["funding","p2p","qr-pay","cash-out","cards","bills","vouchers"]),
  merchant: grammar("collection", "signal", [["sales","Sales","المبيعات"],["collect","Collect","التحصيل"],["settlements","Settlements","التسويات"],["team","Team","الفريق"]], ["qr-collection","payment-links","refunds","settlements","staff"], "compact"),
  travel: grammar("itinerary", "voyage", [["explore","Explore","اكتشف"],["trips","Trips","رحلاتي"],["saved","Saved","المحفوظات"],["profile","Profile","حسابي"]], ["flights","stays","activities","itinerary-cache","agency-operations"]),
  mobility: grammar("trip", "pulse", [["ride","Ride","تنقل"],["activity","Rides","الرحلات"],["wallet","Wallet","المحفظة"],["profile","Profile","حسابي"]], ["ride-request","live-location","scheduled-rides","wallet-pay","safety-support"]),
  driver: grammar("trip-request", "pulse", [["drive","Drive","القيادة"],["earnings","Earnings","الأرباح"],["activity","Activity","الحركات"],["account","Account","حسابي"]], ["availability","trip-offers","navigation","earnings","payouts"], "compact"),
  commerce: grammar("product", "market", [["discover","Discover","اكتشف"],["search","Search","بحث"],["bag","Bag","الحقيبة"],["orders","Orders","طلباتي"]], ["catalogue","cart","checkout","tracking","returns"]),
  delivery: grammar("shipment", "signal", [["deliveries","Deliveries","التوصيل"],["route","Route","المسار"],["history","History","السجل"],["support","Support","الدعم"]], ["tracking","route","proof-of-delivery","recipient-contact"], "compact"),
  hospitality: grammar("reservation", "harbor", [["stays","Stays","الإقامات"],["reservation","My stay","إقامتي"],["services","Services","الخدمات"],["profile","Profile","حسابي"]], ["rooms","reservations","room-service","digital-key"]),
  saas: grammar("workspace", "grid", [["overview","Overview","نظرة عامة"],["work","Work","العمل"],["reports","Reports","التقارير"],["settings","Settings","الإعدادات"]], ["tables","workflows","reports","permissions","audit"], "compact", ["desktop","tablet","web"]),
  lifestyle: grammar("collection", "canvas", [["today","Today","اليوم"],["discover","Discover","اكتشف"],["saved","Saved","المحفوظات"],["profile","Profile","حسابي"]], ["collections","saved-items","reminders"]),
});
export type ProductGrammarId = keyof typeof PRODUCT_GRAMMARS;
export function isProductGrammarId(value: unknown): value is ProductGrammarId {
  return typeof value === "string" && Object.prototype.hasOwnProperty.call(PRODUCT_GRAMMARS, value);
}
export function getProductGrammar(id: ProductGrammarId): ProductGrammar {
  if (!isProductGrammarId(id)) throw new RangeError("Unknown product grammar");
  return PRODUCT_GRAMMARS[id];
}
export interface ExperienceRequest {
  readonly product: ProductGrammarId;
  readonly world: VisualWorld;
  readonly brandprint: string;
  readonly locale?: ExperienceLocale;
  readonly mode?: AppearanceMode;
  /** Opt-in only. Unrecognized or non-Boolean flags cannot enable a capability. */
  readonly capabilities?: Readonly<Record<string, boolean>>;
}
export function resolveExperience(request: ExperienceRequest) {
  const product = getProductGrammar(request.product);
  if (!(VISUAL_WORLDS as readonly string[]).includes(request.world)) throw new RangeError("Unknown visual world");
  if (typeof request.brandprint !== "string" || !request.brandprint.trim()) throw new TypeError("A host brandprint identifier is required");
  const locale = request.locale ?? "en", mode = request.mode ?? "light";
  if (locale !== "en" && locale !== "ar") throw new RangeError("Unsupported experience locale");
  if (mode !== "light" && mode !== "dark") throw new RangeError("Unsupported appearance mode");
  return deepFreeze({ product: request.product, world: request.world, brandprint: request.brandprint,
    locale, direction: locale === "ar" ? "rtl" as const : "ltr" as const, mode,
    appearanceRecipe: product.appearanceRecipe, primaryObject: product.primaryObject, density: product.density,
    navigation: product.navigation.map(item => ({ id: item.id, label: item.label[locale] })),
    enabledCapabilities: product.capabilities.filter(key => Object.prototype.hasOwnProperty.call(request.capabilities ?? {}, key) && request.capabilities?.[key] === true),
    preserveDirection: ["amount", "identifier", "qr", "keypad", "geography"],
  });
}

export type MotionLevel = "restrained" | "standard" | "expressive";
export type MotionContext = "discovery" | "navigation" | "confirmation" | "security" | "driver-navigation";
/** Token references, not a parallel hard-coded animation scale. */
export function motionPolicy(context: MotionContext, requested: MotionLevel, reduced: boolean) {
  if (!["discovery","navigation","confirmation","security","driver-navigation"].includes(context)) throw new RangeError("Unknown motion context");
  if (!["restrained","standard","expressive"].includes(requested)) throw new RangeError("Unknown motion level");
  const guarded = ["confirmation","security","driver-navigation"].includes(context);
  const level: MotionLevel = guarded ? "restrained" : requested;
  return deepFreeze({ level, mode: reduced ? "Reduced" : "Full",
    durationToken: level === "expressive" ? "o2/motion/expressive" : level === "standard" ? "o2/motion/transition" : "o2/motion/feedback",
    distanceToken: level === "expressive" ? "o2/motion/travel" : `o2/motion/distance/${level}`,
    decorativeMotion: !reduced && !guarded,
    continuousMotion: false,
  });
}

export interface Money { readonly minor: bigint; readonly currency: string; readonly scale: number; }
function assertMoney(value: Money): void {
  if (typeof value.minor !== "bigint") throw new TypeError("Use integer minor units (bigint), never floating-point money");
  if (!/^[A-Z]{3}$/.test(value.currency)) throw new TypeError("Expected a three-letter currency code");
  if (!Number.isInteger(value.scale) || value.scale < 0 || value.scale > 6) throw new RangeError("Invalid currency scale");
}
/** The host supplies approved currency precision. LYD demo quotes use scale 3. */
export function sumMoney(values: readonly Money[]): Money {
  if (!values.length) throw new RangeError("At least one amount is required");
  const first = values[0]; assertMoney(first);
  let minor = 0n;
  for (const value of values) {
    assertMoney(value);
    if (value.currency !== first.currency || value.scale !== first.scale) throw new RangeError("Cannot add different currencies or scales");
    minor += value.minor;
  }
  return deepFreeze({ minor, currency: first.currency, scale: first.scale });
}
/** Returns isolated text fields so a renderer can use <bdi dir="ltr"> safely in RTL. */
export function formatMoney(value: Money, locale = "en"): Readonly<{ amount: string; currency: string; direction: "ltr" }> {
  assertMoney(value);
  const unit = 10n ** BigInt(value.scale), absolute = value.minor < 0n ? -value.minor : value.minor;
  const integer = new Intl.NumberFormat(locale, { maximumFractionDigits: 0 });
  const digit = new Intl.NumberFormat(locale, { useGrouping: false });
  const decimal = new Intl.NumberFormat(locale).formatToParts(1.1).find(p => p.type === "decimal")?.value ?? ".";
  const minus = integer.formatToParts(-1).find(p => p.type === "minusSign")?.value ?? "-";
  const fraction = (absolute % unit).toString().padStart(value.scale, "0").replace(/[0-9]/g, n => digit.format(Number(n)));
  return deepFreeze({ amount: (value.minor < 0n ? minus : "") + integer.format(absolute / unit) + (value.scale ? decimal + fraction : ""), currency: value.currency, direction: "ltr" as const });
}
export interface ExperienceQuote {
  readonly id: string;
  readonly expiresAtMs: number;
  readonly items: readonly Money[];
}
export function reviewQuote(quote: ExperienceQuote, nowMs: number): Money {
  if (!quote.id?.trim() || !Number.isSafeInteger(quote.expiresAtMs) || !Number.isSafeInteger(nowMs)) throw new TypeError("Invalid quote identity or clock");
  if (nowMs >= quote.expiresAtMs) throw new RangeError("Quote expired: request a new quote before submitting");
  if (quote.items.some(item => { assertMoney(item); return item.minor < 0n; })) throw new RangeError("A purchase quote cannot contain a negative line");
  return sumMoney(quote.items);
}

export type JourneyKind = "booking" | "ride" | "order" | "payout";
export type EventAuthority = "user" | "provider" | "device";
export interface JourneyEvent { readonly type: string; readonly authority: EventAuthority; readonly reference?: string; }
interface Rule { readonly from: readonly string[]; readonly to: string; readonly by: EventAuthority; readonly reference?: true; }
const rule = (from: readonly string[], to: string, by: EventAuthority, reference?: true): Rule => ({ from, to, by, ...(reference ? { reference } : {}) });
const COMMON = {
  QUOTE_RECEIVED: rule(["draft","failed"], "quoted", "provider", true),
  SUBMIT: rule(["quoted"], "submitting", "user"),
  TIMEOUT: rule(["submitting","pending"], "unknown", "device"),
  PAYMENT_AUTHORIZED: rule(["submitting"], "pending", "provider", true),
  CONFIRMED: rule(["submitting","pending","unknown"], "confirmed", "provider", true),
  DECLINED: rule(["submitting","pending","unknown"], "failed", "provider", true),
  CANCEL: rule(["confirmed"], "cancel_requested", "user"),
  CANCELLED: rule(["cancel_requested"], "cancelled", "provider", true),
  REFUND_PENDING: rule(["cancelled","refund_requested"], "refund_pending", "provider", true),
  REFUNDED: rule(["refund_pending"], "refunded", "provider", true),
};
export const JOURNEY_RULES: Readonly<Record<JourneyKind, Readonly<Record<string, Rule>>>> = deepFreeze({
  booking: { ...COMMON },
  order: { ...COMMON,
    SHIPPED: rule(["confirmed"], "in_transit", "provider", true),
    DELIVERED: rule(["in_transit"], "delivered", "provider", true),
    REQUEST_REFUND: rule(["confirmed","delivered"], "refund_requested", "user"),
  },
  payout: {
    QUOTE_RECEIVED: rule(["draft","failed"], "quoted", "provider", true),
    SUBMIT: rule(["quoted"], "pending", "user"),
    TIMEOUT: rule(["pending"], "unknown", "device"),
    PAID: rule(["pending","unknown"], "confirmed", "provider", true),
    DECLINED: rule(["pending","unknown"], "failed", "provider", true),
  },
  ride: {
    QUOTE_RECEIVED: rule(["draft","unavailable","cancelled"], "quoted", "provider", true),
    REQUEST: rule(["quoted"], "searching", "user"),
    ASSIGNED: rule(["searching","unknown"], "assigned", "provider", true),
    ARRIVING: rule(["assigned","unknown"], "arriving", "provider", true),
    STARTED: rule(["assigned","arriving","unknown"], "in_progress", "provider", true),
    COMPLETED: rule(["in_progress","unknown"], "completed", "provider", true),
    UNAVAILABLE: rule(["searching","unknown"], "unavailable", "provider", true),
    CANCEL: rule(["searching","assigned","arriving"], "cancel_requested", "user"),
    CANCELLED: rule(["cancel_requested"], "cancelled", "provider", true),
    TIMEOUT: rule(["searching","assigned","arriving","in_progress"], "unknown", "device"),
  },
});
/** Receives trusted, deduplicated backend events. The authority field is NOT authentication. */
export function transitionJourney(kind: JourneyKind, state: string, event: JourneyEvent): string {
  if (!Object.prototype.hasOwnProperty.call(JOURNEY_RULES, kind)) throw new RangeError("Unknown journey kind");
  const rules = JOURNEY_RULES[kind];
  const next = Object.prototype.hasOwnProperty.call(rules, event.type) ? rules[event.type] : undefined;
  if (!next || !next.from.includes(state)) throw new RangeError(`Invalid ${kind} transition: ${state} / ${event.type}`);
  if (next.by !== event.authority) throw new TypeError("Incorrect event authority for UI state transition");
  if (next.reference && (typeof event.reference !== "string" || !event.reference.trim())) throw new TypeError("Provider outcome requires a reference");
  return next.to;
}
export function isOutcomeUncertain(state: string): boolean {
  return ["submitting","searching","pending","unknown","cancel_requested","refund_pending"].includes(state);
}
