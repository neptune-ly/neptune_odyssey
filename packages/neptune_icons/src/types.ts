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
  // People & identity
  | "user"
  | "users"
  | "security-shield"
  | "lock"
  | "unlock"
  | "key"
  | "fingerprint"
  | "face-id"
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
  // Support
  | "support"
  // Carets & arrows
  | "chevron-right"
  | "chevron-down"
  | "arrow-right"
  | "arrow-left"
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
  | "tap-to-pay";

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
  "support",
  "chevron-right",
  "chevron-down",
  "arrow-right",
  "arrow-left",
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
];
