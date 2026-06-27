// Neptune white-label — runtime tenant registry + live theme loader.
// Mirrors the 5 reference JSON sets in configs/*.tenant.json so the DCs can
// apply a tenant skin live without a fetch. Source of truth for VALUES is
// tokens/themes.css; this file only carries the per-tenant LEVER selections.
(function () {
  const T = {
    "neptune-retail": {
      id: "neptune-retail", label: "Neptune Retail", institution: "Neptune Holdings LY",
      theme: "neptune", flavor: "retail", shapeScale: 1.0,
      currency: "LYD", tier: "Neptune Member", tone: "clear, confident, calm",
      balanceLabel: "Available balance", primaryCta: "New transfer",
      features: { wallet: false, vouchers: true, merchantPay: false, topUp: false, addMoney: true, qrNfc: true },
      levers: 7
    },
    "neptune-corporate": {
      id: "neptune-corporate", label: "Neptune Corporate", institution: "Neptune Holdings LY",
      theme: "neptune", flavor: "corporate", shapeScale: 1.0,
      currency: "LYD", tier: "Admin · Maker", tone: "precise, accountable",
      balanceLabel: "Total position", primaryCta: "New batch",
      features: { wallet: false, vouchers: false, merchantPay: false, topUp: false, addMoney: false, qrNfc: false },
      levers: 9
    },
    "triton-retail": {
      id: "triton-retail", label: "Triton Retail", institution: "Triton Bank",
      theme: "triton", flavor: "retail", shapeScale: 1.0,
      currency: "LYD", tier: "Triton Gold", tone: "warm, hospitable, trusted",
      balanceLabel: "Available balance", primaryCta: "New transfer",
      features: { wallet: false, vouchers: false, merchantPay: false, topUp: false, addMoney: true, qrNfc: true },
      levers: 9
    },
    "nereid-wallet": {
      id: "nereid-wallet", label: "Nereid Wallet", institution: "Nereid",
      theme: "nereid", flavor: "wallet", shapeScale: 1.0,
      currency: "LYD", tier: "Nereid Plus", tone: "light, optimistic, instant",
      balanceLabel: "Wallet balance", primaryCta: "Add money",
      features: { wallet: true, vouchers: true, merchantPay: true, topUp: true, addMoney: true, qrNfc: true },
      levers: 10
    },
    "proteus-retail": {
      id: "proteus-retail", label: "Proteus Retail", institution: "Proteus",
      theme: "proteus", flavor: "retail", shapeScale: 1.0,
      currency: "LYD", tier: "Proteus Premier", tone: "formal, secure, authoritative",
      balanceLabel: "Available balance", primaryCta: "New transfer",
      features: { wallet: false, vouchers: false, merchantPay: false, topUp: false, addMoney: true, qrNfc: true },
      levers: 9
    }
  };

  // applyTenant(rootEl, tenantId): set brand levers on a wrapper element.
  // Sets data-theme + shape scale; returns the tenant record so the caller can
  // map content/feature levers into its own render. Mode + dir are left to the host.
  function applyTenant(rootEl, id) {
    const t = T[id] || T["neptune-retail"];
    if (rootEl) {
      rootEl.setAttribute("data-theme", t.theme);
      rootEl.style.setProperty("--npt-shape-scale", String(t.shapeScale));
    }
    return t;
  }

  window.NEPTUNE_TENANTS = T;
  window.NEPTUNE_applyTenant = applyTenant;
})();
