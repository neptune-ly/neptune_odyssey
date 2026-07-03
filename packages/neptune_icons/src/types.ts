// Neptune Odyssey — icon names · © 2026 Neptune.Fintech (neptune.ly)
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).
//
// The canonical IconName union and the ordered ICON_NAMES roster. The ICONS
// map in icons.ts is typed as Record<IconName, string>, so adding a name here
// without a path (or vice-versa) is a compile error — the set cannot drift.

/** Every icon shipped by the Neptune Odyssey icon family. */
export type IconName =
  // Navigation & core
  | "home"
  | "accounts"
  | "card"
  | "card-add"
  | "wallet"
  | "transfer"
  | "send"
  | "receive"
  | "request"
  | "swap-exchange"
  | "qr-code"
  | "contactless"
  // Documents & money flow
  | "bill"
  | "receipt"
  | "statement"
  | "pdf"
  | "download"
  | "upload"
  // Tools
  | "search"
  | "filter"
  | "settings"
  | "edit"
  | "trash"
  | "refresh"
  | "link"
  // People & identity
  | "user"
  | "users"
  | "security-shield"
  | "lock"
  | "unlock"
  | "key"
  | "fingerprint"
  | "face-id"
  | "id-card"
  | "otp"
  // Status & alerts
  | "bell"
  | "eye"
  | "eye-off"
  | "info"
  | "success-check"
  | "warning"
  | "error"
  | "close"
  | "plus"
  | "minus"
  | "star"
  // Charts & insights
  | "chart-line"
  | "chart-pie"
  | "trending-up"
  | "trending-down"
  | "savings"
  // Time & place
  | "calendar"
  | "clock"
  | "location"
  | "phone"
  | "mail"
  | "chat"
  | "camera"
  | "globe"
  // Support
  | "support"
  // Carets & arrows
  | "chevron-right"
  | "chevron-down"
  | "chevron-up"
  | "chevron-left"
  | "arrow-right"
  | "arrow-left"
  | "arrow-up"
  | "arrow-down"
  // Overflow & misc
  | "menu"
  | "more-horizontal"
  | "more-vertical"
  | "copy"
  | "share"
  | "logout"
  | "language"
  | "moon"
  | "sun"
  // Fintech & payments
  | "atm"
  | "pos-terminal"
  | "coins"
  | "cash-stack"
  | "invoice"
  | "pie-budget"
  | "exchange-rate"
  | "crypto"
  | "loan"
  | "insurance"
  | "split-bill"
  | "tap-to-pay"
  | "dispute"
  | "refund"
  | "goal"
  | "shopping-bag"
  | "category-tag";

/** All icon names, in catalogue order. */
export const ICON_NAMES: IconName[] = [
  "home",
  "accounts",
  "card",
  "card-add",
  "wallet",
  "transfer",
  "send",
  "receive",
  "request",
  "swap-exchange",
  "qr-code",
  "contactless",
  "bill",
  "receipt",
  "statement",
  "pdf",
  "download",
  "upload",
  "search",
  "filter",
  "settings",
  "user",
  "users",
  "security-shield",
  "lock",
  "unlock",
  "key",
  "fingerprint",
  "face-id",
  "id-card",
  "otp",
  "bell",
  "eye",
  "eye-off",
  "info",
  "success-check",
  "warning",
  "error",
  "close",
  "plus",
  "minus",
  "star",
  "chart-line",
  "chart-pie",
  "trending-up",
  "trending-down",
  "savings",
  "calendar",
  "clock",
  "location",
  "phone",
  "mail",
  "chat",
  "camera",
  "globe",
  "support",
  "chevron-right",
  "chevron-down",
  "chevron-up",
  "chevron-left",
  "arrow-right",
  "arrow-left",
  "arrow-up",
  "arrow-down",
  "menu",
  "more-horizontal",
  "more-vertical",
  "copy",
  "share",
  "logout",
  "language",
  "moon",
  "sun",
  "atm",
  "pos-terminal",
  "coins",
  "cash-stack",
  "invoice",
  "pie-budget",
  "exchange-rate",
  "crypto",
  "loan",
  "insurance",
  "split-bill",
  "tap-to-pay",
  "dispute",
  "refund",
  "goal",
  "shopping-bag",
  "category-tag",
  "edit",
  "trash",
  "refresh",
  "link",
];
