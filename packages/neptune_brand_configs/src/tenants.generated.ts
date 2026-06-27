// GENERATED — do not edit. Source: configs/*.tenant.json (the 5 reference tenants).
// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0

export const TENANTS = {
  "neptune-retail": {
    "$schema": "neptune.tenant.config/v1",
    "extends": "neptune-core@A",
    "tenant": {
      "id": "neptune-retail",
      "displayName": "Neptune Retail",
      "institution": "Neptune Holdings LY",
      "market": "LY",
      "status": "reference",
      "note": "Platform baseline. The retail experience before a bank adds its voice."
    },
    "brand": {
      "theme": "neptune",
      "wordmark": "Neptune",
      "shortName": "Neptune",
      "logoMark": "markNeptune",
      "palette": {
        "primaryHue": 258,
        "tertiaryHue": 200,
        "seed": "signal-blue",
        "accents": [
          "#2A6FDB",
          "aqua"
        ]
      },
      "fonts": {
        "display": "Hanken Grotesk",
        "text": "Hanken Grotesk",
        "num": "Hanken Grotesk",
        "displayAr": "IBM Plex Sans Arabic",
        "textAr": "IBM Plex Sans Arabic"
      },
      "shapeScale": 1,
      "cornerFamily": {
        "xs": 8,
        "sm": 12,
        "md": 16,
        "lg": 24,
        "xl": 32,
        "2xl": 44
      },
      "motif": "sonar tide-rings",
      "heroEmblem": "depth rings",
      "motionPersonality": "smooth-fluid",
      "glassTint": "oceanic",
      "cardArt": "gradient-primary-to-tertiary",
      "loginShell": "depth-emblem panel",
      "dashboardHero": "balance-first account cards",
      "navAccent": "primary",
      "tone": "clear, confident, calm"
    },
    "productFlavor": {
      "active": "retail-mobile+retail-web",
      "density": "comfortable",
      "platforms": [
        "flutter",
        "web"
      ]
    },
    "features": {
      "accounts": true,
      "cards": {
        "virtual": true,
        "physical": true,
        "freeze": true,
        "limits": true
      },
      "wallet": false,
      "qrNfc": true,
      "bills": true,
      "vouchers": true,
      "goals": true,
      "statements": true,
      "transfers": {
        "internal": true,
        "local": true,
        "intl": true,
        "swift": true,
        "wu": true,
        "onepay": true
      },
      "beneficiaries": true,
      "bulk": false,
      "approvals": false,
      "userManagement": false,
      "reports": false,
      "audit": false,
      "insights": true,
      "securityCenter": true,
      "multiSession": true,
      "notifications": true
    },
    "content": {
      "en": {
        "loginHeadline": "Your money, beautifully in your control.",
        "tierLabel": "Neptune Member",
        "primaryCta": "New transfer",
        "currencyName": "Libyan Dinar"
      },
      "ar": {
        "loginHeadline": "أموالك، تحت سيطرتك تمامًا.",
        "tierLabel": "عضو نبتون",
        "primaryCta": "تحويل جديد",
        "currencyName": "دينار ليبي"
      }
    },
    "compliance": {
      "currency": "LYD",
      "locale": "en-LY",
      "ibanFormat": "LY## #### #### #### #### ####",
      "phoneFormat": "+218 9# ### ####",
      "idFormat": "12-digit national ID",
      "kyc": "tier-based",
      "dailyLimit": 50000,
      "approvalLimits": null,
      "workingDays": [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu"
      ],
      "cutoffs": {
        "local": "15:00",
        "swift": "13:00"
      },
      "statementFormat": "PDF/CSV",
      "auditRetentionMonths": 84,
      "numerals": "latin-or-arabic"
    },
    "platformOverrides": {
      "flutter": {
        "themeExtension": "NeptuneTheme",
        "useMaterial3": true,
        "colorSchemeSeedHue": 258
      },
      "web": {
        "cssVarsTheme": "neptune",
        "sidebarWidth": 256,
        "breakpoints": {
          "sm": 600,
          "md": 905,
          "lg": 1240
        }
      }
    },
    "levers": {
      "moved": [
        "color",
        "shape",
        "typography",
        "logo",
        "motif",
        "cardArt",
        "loginShell"
      ],
      "count": 7,
      "rule": "≥6 of 12 — PASS (this is the baseline tenant)"
    }
  },
  "neptune-corporate": {
    "$schema": "neptune.tenant.config/v1",
    "extends": "neptune-core@A",
    "tenant": {
      "id": "neptune-corporate",
      "displayName": "Neptune Corporate",
      "institution": "Neptune Holdings LY",
      "market": "LY",
      "status": "reference",
      "verifiedDomains": [
        "neptune.ly"
      ],
      "note": "Same Neptune brand, corporate flavor. Dense, permissioned, workflow-driven."
    },
    "brand": {
      "theme": "neptune",
      "wordmark": "Neptune",
      "shortName": "Neptune Business",
      "logoMark": "markNeptune",
      "palette": {
        "primaryHue": 258,
        "tertiaryHue": 200,
        "seed": "signal-blue"
      },
      "fonts": {
        "display": "Hanken Grotesk",
        "text": "Hanken Grotesk",
        "num": "Hanken Grotesk",
        "displayAr": "IBM Plex Sans Arabic",
        "textAr": "IBM Plex Sans Arabic"
      },
      "shapeScale": 1,
      "cornerFamily": {
        "xs": 8,
        "sm": 12,
        "md": 16,
        "lg": 24,
        "xl": 32,
        "2xl": 44
      },
      "motif": "sonar tide-rings",
      "heroEmblem": "depth rings",
      "motionPersonality": "smooth-fluid",
      "glassTint": "oceanic",
      "cardArt": "treasury KPI surfaces",
      "loginShell": "domain-aware business sign-in",
      "dashboardHero": "treasury cash-position dashboard",
      "navAccent": "secondary-container",
      "tone": "precise, accountable, operational"
    },
    "productFlavor": {
      "active": "corporate-web",
      "density": "dense",
      "platforms": [
        "web"
      ]
    },
    "features": {
      "accounts": true,
      "cards": {
        "virtual": true,
        "physical": true,
        "freeze": true,
        "limits": true
      },
      "wallet": false,
      "qrNfc": false,
      "bills": false,
      "vouchers": false,
      "goals": false,
      "statements": true,
      "transfers": {
        "internal": true,
        "local": true,
        "intl": true,
        "swift": true,
        "wu": false,
        "onepay": false
      },
      "beneficiaries": true,
      "bulk": true,
      "batches": {
        "salary": true,
        "supplier": true,
        "fileUpload": true,
        "repairRows": true
      },
      "approvals": {
        "makerChecker": true,
        "multiLevel": true,
        "approvalMatrix": true
      },
      "userManagement": true,
      "roles": true,
      "reports": true,
      "customReports": true,
      "costCenters": true,
      "audit": true,
      "insights": false,
      "securityCenter": true,
      "multiSession": true,
      "notifications": true
    },
    "content": {
      "en": {
        "loginHeadline": "Treasury, control and clarity for your whole organisation.",
        "tierLabel": "Admin · Maker",
        "primaryCta": "New batch",
        "orgLabel": "Neptune Holdings LY"
      },
      "ar": {
        "loginHeadline": "الخزينة والتحكم والوضوح لمؤسستك بالكامل.",
        "tierLabel": "مشرف · منشئ",
        "primaryCta": "دفعة جديدة",
        "orgLabel": "نبتون القابضة"
      }
    },
    "compliance": {
      "currency": "LYD",
      "locale": "en-LY",
      "ibanFormat": "LY## #### #### #### #### ####",
      "phoneFormat": "+218 9# ### ####",
      "idFormat": "commercial registration",
      "kyc": "KYB corporate",
      "dailyLimit": 5000000,
      "approvalLimits": [
        {
          "uptoLYD": 50000,
          "approvals": 1
        },
        {
          "uptoLYD": 500000,
          "approvals": 2
        },
        {
          "aboveLYD": 500000,
          "approvals": 3
        }
      ],
      "workingDays": [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu"
      ],
      "cutoffs": {
        "local": "14:30",
        "swift": "12:30",
        "salary": "11:00"
      },
      "statementFormat": "PDF/CSV/XLSX/MT940",
      "auditRetentionMonths": 120,
      "numerals": "latin"
    },
    "platformOverrides": {
      "flutter": {
        "themeExtension": "NeptuneTheme",
        "useMaterial3": true,
        "note": "corporate is web-only"
      },
      "web": {
        "cssVarsTheme": "neptune",
        "sidebarWidth": 256,
        "tableDensity": "dense",
        "breakpoints": {
          "sm": 600,
          "md": 905,
          "lg": 1240,
          "xl": 1640
        }
      }
    },
    "levers": {
      "moved": [
        "color",
        "shape",
        "typography",
        "logo",
        "motif",
        "cardArt",
        "loginShell",
        "dashboardHero",
        "contentTone"
      ],
      "count": 9,
      "rule": "≥6 of 12 — PASS (distinct corporate dashboard hero + tone vs Neptune Retail)"
    }
  },
  "triton-retail": {
    "$schema": "neptune.tenant.config/v1",
    "extends": "neptune-core@A",
    "tenant": {
      "id": "triton-retail",
      "displayName": "Triton Retail",
      "institution": "Triton Bank",
      "market": "LY",
      "status": "reference",
      "note": "Retail demo brand. Warm, rooted, coastal. Same structure, fully re-skinned."
    },
    "brand": {
      "theme": "triton",
      "wordmark": "Triton Bank",
      "shortName": "Triton",
      "logoMark": "markTriton",
      "palette": {
        "primaryHue": 162,
        "tertiaryHue": 86,
        "seed": "emerald",
        "accents": [
          "emerald",
          "warm-gold"
        ]
      },
      "fonts": {
        "display": "Bricolage Grotesque",
        "text": "Hanken Grotesk",
        "num": "Hanken Grotesk",
        "displayAr": "Reem Kufi",
        "textAr": "Tajawal"
      },
      "shapeScale": 1,
      "cornerFamily": {
        "xs": 12,
        "sm": 18,
        "md": 26,
        "lg": 34,
        "xl": 44,
        "2xl": 56,
        "note": "organic, larger radii"
      },
      "motif": "coastal soft arc rings",
      "heroEmblem": "arch silhouette",
      "motionPersonality": "calm-graceful",
      "glassTint": "warm-amber",
      "cardArt": "emerald-gold woven",
      "loginShell": "arcade arches panel",
      "dashboardHero": "warm balance-first cards",
      "navAccent": "primary",
      "tone": "warm, hospitable, trusted"
    },
    "productFlavor": {
      "active": "retail-mobile+retail-web",
      "density": "comfortable",
      "platforms": [
        "flutter",
        "web"
      ]
    },
    "features": {
      "accounts": true,
      "cards": {
        "virtual": true,
        "physical": true,
        "freeze": true,
        "limits": true
      },
      "wallet": false,
      "qrNfc": true,
      "bills": true,
      "vouchers": false,
      "goals": true,
      "statements": true,
      "transfers": {
        "internal": true,
        "local": true,
        "intl": true,
        "swift": true,
        "wu": true,
        "onepay": false
      },
      "beneficiaries": true,
      "bulk": false,
      "approvals": false,
      "userManagement": false,
      "reports": false,
      "audit": false,
      "insights": true,
      "securityCenter": true,
      "multiSession": true,
      "notifications": true
    },
    "content": {
      "en": {
        "loginHeadline": "Banking with coastal, built for today.",
        "tierLabel": "Triton Gold",
        "primaryCta": "New transfer",
        "currencyName": "Libyan Dinar"
      },
      "ar": {
        "loginHeadline": "مصرفية بعراقة، صُممت لليوم.",
        "tierLabel": "أندلس الذهبية",
        "primaryCta": "تحويل جديد",
        "currencyName": "دينار ليبي"
      }
    },
    "compliance": {
      "currency": "LYD",
      "locale": "ar-LY",
      "ibanFormat": "LY## #### #### #### #### ####",
      "phoneFormat": "+218 9# ### ####",
      "idFormat": "12-digit national ID",
      "kyc": "tier-based",
      "dailyLimit": 40000,
      "approvalLimits": null,
      "workingDays": [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu"
      ],
      "cutoffs": {
        "local": "15:00",
        "swift": "13:00"
      },
      "statementFormat": "PDF/CSV",
      "auditRetentionMonths": 84,
      "numerals": "arabic-default"
    },
    "platformOverrides": {
      "flutter": {
        "themeExtension": "TritonTheme",
        "useMaterial3": true,
        "colorSchemeSeedHue": 162
      },
      "web": {
        "cssVarsTheme": "triton",
        "sidebarWidth": 256,
        "breakpoints": {
          "sm": 600,
          "md": 905,
          "lg": 1240
        }
      }
    },
    "levers": {
      "moved": [
        "color",
        "shape",
        "typography",
        "logo",
        "motif",
        "cardArt",
        "loginShell",
        "motion",
        "contentTone"
      ],
      "count": 9,
      "rule": "≥6 of 12 — PASS (emerald+gold, organic 26px corners, Bricolage/Reem Kufi, arch motif, graceful motion)"
    }
  },
  "nereid-wallet": {
    "$schema": "neptune.tenant.config/v1",
    "extends": "neptune-core@A",
    "tenant": {
      "id": "nereid-wallet",
      "displayName": "Nereid Wallet",
      "institution": "Nereid",
      "market": "LY",
      "status": "reference",
      "note": "Digital-first wallet. Balance-led, payment-led, faster and lighter than banking — never relabeled banking."
    },
    "brand": {
      "theme": "nereid",
      "wordmark": "Nereid",
      "shortName": "Nereid",
      "logoMark": "markNereid",
      "palette": {
        "primaryHue": 292,
        "tertiaryHue": 350,
        "seed": "violet",
        "accents": [
          "violet",
          "luminous-rose"
        ]
      },
      "fonts": {
        "display": "Space Grotesk",
        "text": "Hanken Grotesk",
        "num": "Space Grotesk",
        "displayAr": "Readex Pro",
        "textAr": "Readex Pro"
      },
      "shapeScale": 1,
      "cornerFamily": {
        "xs": 4,
        "sm": 8,
        "md": 12,
        "lg": 18,
        "xl": 26,
        "2xl": 36,
        "note": "crisp, precise"
      },
      "motif": "crisp digital light-grid",
      "heroEmblem": "spark / star",
      "motionPersonality": "light-quick-crisp",
      "glassTint": "violet-luminous",
      "cardArt": "spark gradient",
      "loginShell": "light-grid spark panel",
      "dashboardHero": "wallet balance hero + add-money",
      "navAccent": "primary",
      "tone": "light, optimistic, instant"
    },
    "productFlavor": {
      "active": "wallet-mobile+wallet-web",
      "density": "comfortable-light",
      "platforms": [
        "flutter",
        "web"
      ]
    },
    "features": {
      "accounts": false,
      "cards": {
        "linked": true,
        "virtual": true,
        "physical": false,
        "freeze": true,
        "limits": true
      },
      "wallet": true,
      "balanceHero": true,
      "addMoney": true,
      "topUp": true,
      "sendRequest": true,
      "qrNfc": true,
      "merchantPay": true,
      "vouchers": true,
      "promos": true,
      "goals": false,
      "statements": false,
      "transfers": {
        "internal": false,
        "local": true,
        "intl": false,
        "swift": false,
        "wu": false,
        "onepay": true
      },
      "beneficiaries": true,
      "bulk": false,
      "approvals": false,
      "userManagement": false,
      "reports": false,
      "audit": false,
      "activity": true,
      "limits": true,
      "securityCenter": true,
      "multiSession": true,
      "notifications": true
    },
    "content": {
      "en": {
        "loginHeadline": "Pay, top up and split — in a tap.",
        "tierLabel": "Nereid Plus",
        "primaryCta": "Add money",
        "balanceLabel": "Wallet balance",
        "currencyName": "Libyan Dinar"
      },
      "ar": {
        "loginHeadline": "ادفع واشحن وقسّم — بلمسة.",
        "tierLabel": "نوران بلس",
        "primaryCta": "إضافة أموال",
        "balanceLabel": "رصيد المحفظة",
        "currencyName": "دينار ليبي"
      }
    },
    "compliance": {
      "currency": "LYD",
      "locale": "en-LY",
      "ibanFormat": "wallet-id or +218 mobile",
      "phoneFormat": "+218 9# ### ####",
      "idFormat": "national ID (eKYC)",
      "kyc": "eKYC tiered wallet limits",
      "dailyLimit": 5000,
      "monthlyLimit": 30000,
      "walletCeilingLYD": 15000,
      "approvalLimits": null,
      "workingDays": [
        "everyday"
      ],
      "cutoffs": {
        "instant": "24/7"
      },
      "statementFormat": "in-app activity only",
      "auditRetentionMonths": 60,
      "numerals": "latin"
    },
    "platformOverrides": {
      "flutter": {
        "themeExtension": "NereidTheme",
        "useMaterial3": true,
        "colorSchemeSeedHue": 292
      },
      "web": {
        "cssVarsTheme": "nereid",
        "shell": "centered-app",
        "maxContentWidth": 1080,
        "breakpoints": {
          "sm": 600,
          "md": 905,
          "lg": 1240
        }
      }
    },
    "levers": {
      "moved": [
        "color",
        "shape",
        "typography",
        "logo",
        "motif",
        "cardArt",
        "loginShell",
        "motion",
        "dashboardHero",
        "contentTone"
      ],
      "count": 10,
      "rule": "≥6 of 12 — PASS (violet+rose, crisp 12px, Space Grotesk, light-grid motif, wallet hero — a different product entirely)"
    }
  },
  "proteus-retail": {
    "$schema": "neptune.tenant.config/v1",
    "extends": "neptune-core@A",
    "tenant": {
      "id": "proteus-retail",
      "displayName": "Proteus Retail",
      "institution": "Proteus",
      "market": "LY",
      "status": "reference",
      "note": "Institutional, secure, corporate-stable. Conservative retail with an authoritative voice."
    },
    "brand": {
      "theme": "proteus",
      "wordmark": "Proteus",
      "shortName": "Proteus",
      "logoMark": "markProteus",
      "palette": {
        "primaryHue": 248,
        "tertiaryHue": 85,
        "seed": "navy",
        "accents": [
          "navy",
          "gold",
          "neutral"
        ]
      },
      "fonts": {
        "display": "Sora",
        "text": "Hanken Grotesk",
        "num": "Sora",
        "displayAr": "Noto Kufi Arabic",
        "textAr": "IBM Plex Sans Arabic"
      },
      "shapeScale": 1,
      "cornerFamily": {
        "xs": 6,
        "sm": 10,
        "md": 14,
        "lg": 20,
        "xl": 28,
        "2xl": 38,
        "note": "structured"
      },
      "motif": "secure guilloché / shield hatch",
      "heroEmblem": "shield chevrons",
      "motionPersonality": "stable-minimal-authoritative",
      "glassTint": "navy-steel",
      "cardArt": "navy-gold institutional",
      "loginShell": "shield guilloché panel",
      "dashboardHero": "balance-first, restrained",
      "navAccent": "primary",
      "tone": "formal, secure, authoritative"
    },
    "productFlavor": {
      "active": "retail-mobile+retail-web",
      "density": "comfortable",
      "platforms": [
        "flutter",
        "web"
      ]
    },
    "features": {
      "accounts": true,
      "cards": {
        "virtual": false,
        "physical": true,
        "freeze": true,
        "limits": true
      },
      "wallet": false,
      "qrNfc": true,
      "bills": true,
      "vouchers": false,
      "goals": false,
      "statements": true,
      "transfers": {
        "internal": true,
        "local": true,
        "intl": true,
        "swift": true,
        "wu": false,
        "onepay": false
      },
      "beneficiaries": true,
      "bulk": false,
      "approvals": false,
      "userManagement": false,
      "reports": false,
      "audit": false,
      "insights": true,
      "securityCenter": true,
      "multiSession": true,
      "notifications": true
    },
    "content": {
      "en": {
        "loginHeadline": "Stability you can bank on.",
        "tierLabel": "Proteus Premier",
        "primaryCta": "New transfer",
        "currencyName": "Libyan Dinar"
      },
      "ar": {
        "loginHeadline": "استقرار يمكنك الاعتماد عليه.",
        "tierLabel": "إف جي إل بي بريمير",
        "primaryCta": "تحويل جديد",
        "currencyName": "دينار ليبي"
      }
    },
    "compliance": {
      "currency": "LYD",
      "locale": "en-LY",
      "ibanFormat": "LY## #### #### #### #### ####",
      "phoneFormat": "+218 9# ### ####",
      "idFormat": "12-digit national ID",
      "kyc": "branch-grade tiered",
      "dailyLimit": 35000,
      "approvalLimits": null,
      "workingDays": [
        "Sun",
        "Mon",
        "Tue",
        "Wed",
        "Thu"
      ],
      "cutoffs": {
        "local": "14:00",
        "swift": "12:00"
      },
      "statementFormat": "PDF/MT940",
      "auditRetentionMonths": 120,
      "numerals": "latin-or-arabic"
    },
    "platformOverrides": {
      "flutter": {
        "themeExtension": "ProteusTheme",
        "useMaterial3": true,
        "colorSchemeSeedHue": 248
      },
      "web": {
        "cssVarsTheme": "proteus",
        "sidebarWidth": 256,
        "breakpoints": {
          "sm": 600,
          "md": 905,
          "lg": 1240
        }
      }
    },
    "levers": {
      "moved": [
        "color",
        "shape",
        "typography",
        "logo",
        "motif",
        "cardArt",
        "loginShell",
        "motion",
        "contentTone"
      ],
      "count": 9,
      "rule": "≥6 of 12 — PASS (navy+gold, structured 14px, Sora/Noto Kufi, shield guilloché motif, authoritative tone)"
    }
  }
} as const;
