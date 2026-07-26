// © 2026 Neptune.Fintech (neptune.ly) · Neptune Odyssey Community License v1.0
//
// NeptuneDemoShell — a complete, running white-label demo app in ~10 lines.
// Ported 1:1 from neptune_demo_shell.dart (`NeptuneDemoShellApp`): the
// Welcome template, then a 5-tab in-context shell (Home/Transfer/Cards/
// Insights/Profile) composed from the existing screen templates, wired to
// any BrandprintConfig — a client's real logo and colours in, a full
// bilingual (EN/AR) app out. The shell owns the theme (dark + arabic drive
// NeptuneTheme and the layout direction, the Dart MaterialApp/Directionality
// wiring), creates the glass scope, marks the tab region as glass backdrop
// and floats the NeptuneDock above it. Theme-only, RTL-safe.

package ly.neptune.odyssey.ui.templates

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalLayoutDirection
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.LayoutDirection
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import ly.neptune.odyssey.tokens.Brandprint
import ly.neptune.odyssey.tokens.BrandprintConfig
import ly.neptune.odyssey.tokens.brandConfigs
import ly.neptune.odyssey.ui.components.NeptuneAvatar
import ly.neptune.odyssey.ui.components.NeptuneBudgetRing
import ly.neptune.odyssey.ui.components.NeptuneButton
import ly.neptune.odyssey.ui.components.NeptuneButtonStyle
import ly.neptune.odyssey.ui.components.NeptuneChip
import ly.neptune.odyssey.ui.components.NeptuneCompareBars
import ly.neptune.odyssey.ui.components.NeptuneCompareData
import ly.neptune.odyssey.ui.components.NeptuneCta
import ly.neptune.odyssey.ui.components.NeptuneDock
import ly.neptune.odyssey.ui.components.NeptuneDockItem
import ly.neptune.odyssey.ui.components.NeptuneFlowStatus
import ly.neptune.odyssey.ui.components.NeptuneFxCard
import ly.neptune.odyssey.ui.components.NeptuneListTile
import ly.neptune.odyssey.ui.components.NeptuneQuickActionItem
import ly.neptune.odyssey.ui.components.NeptuneSection
import ly.neptune.odyssey.ui.components.NeptuneSegmented
import ly.neptune.odyssey.ui.components.NeptuneSparkline
import ly.neptune.odyssey.ui.components.NeptuneStatCard
import ly.neptune.odyssey.ui.components.NeptuneStatusMotion
import ly.neptune.odyssey.ui.components.NeptuneSwitch
import ly.neptune.odyssey.ui.components.NeptuneTierBadge
import ly.neptune.odyssey.ui.components.NeptuneWelcome
import ly.neptune.odyssey.ui.glyphs.NptIcons
import ly.neptune.odyssey.ui.identity.LocalNptGlassScope
import ly.neptune.odyssey.ui.identity.nptGlassBackground
import ly.neptune.odyssey.ui.identity.rememberNptGlassScope
import ly.neptune.odyssey.ui.theme.NeptuneTheme
import ly.neptune.odyssey.ui.theme.rememberNeptuneFontFamily

/**
 * The bilingual copy a demo shell needs. Every field has a sensible default
 * in English/Arabic; override only what your client wants changed.
 *
 * Flutter counterpart: `NeptuneDemoStrings` (neptune_demo_shell.dart).
 */
public class NeptuneDemoStrings(public val arabic: Boolean = false) {

    /** Pick the [ar] string under Arabic, else [en]. */
    public fun t(en: String, ar: String): String = if (arabic) ar else en

    public val welcomeTitle: String get() = t("Banking that", "مصرفيتك مع")
    public val welcomeEmphasis: String get() = t("moves with you.", "الخليج الأول.")
    public val welcomeSub: String get() = t(
        "One account, every currency — send, spend and save, beautifully.",
        "حساب واحد لكل العملات — إرسال وإنفاق وادخار، بأناقة.",
    )
    public val getStarted: String get() = t("Get started", "ابدأ الآن")
    public val haveAccount: String get() = t("I already have an account", "لديّ حساب بالفعل")
    public val goodMorning: String get() = t("Good morning", "صباح الخير")
    public val availableBalance: String get() = t("Available balance", "الرصيد المتاح")
    public val navHome: String get() = t("Home", "الرئيسية")
    public val navTransfer: String get() = t("Transfer", "تحويل")
    public val navCards: String get() = t("Cards", "البطاقات")
    public val navInsights: String get() = t("Insights", "إحصاءات")
    public val navProfile: String get() = t("Profile", "حسابي")
    public val send: String get() = t("Send", "إرسال")
    public val topUp: String get() = t("Top up", "شحن")
    public val pay: String get() = t("Pay", "الدفع")
    public val request: String get() = t("Request", "طلب")
    public val recentActivity: String get() = t("Recent activity", "آخر الحركات")
    public val sendTransfer: String get() = t("Send & transfer", "الإرسال والتحويل")
    public val confirmSend: String get() = t("Confirm & send", "تأكيد وإرسال")
    public val sendingTitle: String get() = t("Sending…", "جارٍ الإرسال…")
    public val sendingSub: String get() =
        t("Securely processing your transfer", "نعالج تحويلك بأمان")
    public val successTitle: String get() = t("Transfer sent", "تم التحويل بنجاح")
    public val doneLabel: String get() = t("Done", "تم")
    public val myCards: String get() = t("My cards", "بطاقاتي")
    public val thisMonth: String get() = t("This month", "هذا الشهر")
    public val lastMonth: String get() = t("Last month", "الشهر الماضي")
    public val spendByCategory: String get() = t("Spend by category", "الإنفاق حسب الفئة")
    public val appearance: String get() = t("Appearance", "المظهر")
    public val themeRow: String get() = t("Dark mode", "الوضع الداكن")
    public val language: String get() = t("Language", "اللغة")
    public val security: String get() = t("Security", "الأمان")
    public val biometric: String get() = t("Biometric login", "الدخول بالبصمة")
    public val logout: String get() = t("Log out", "تسجيل الخروج")
    public val food: String get() = t("Food", "مأكولات")
    public val bills: String get() = t("Bills", "فواتير")
    public val transport: String get() = t("Transport", "مواصلات")
    public val shopping: String get() = t("Shopping", "تسوّق")
    public val salary: String get() = t("Salary", "راتب")
    public val groceryMarket: String get() = t("Grocery Market", "سوق المواد الغذائية")
    public val coffeeBar: String get() = t("Coffee Bar", "مقهى")
    public val today: String get() = t("Today", "اليوم")
    public val yesterday: String get() = t("Yesterday", "أمس")
}

/**
 * A complete, running branded demo app: the Welcome template, then a 5-tab
 * glass-dock shell (Home/Transfer/Cards/Insights/Profile) built entirely from
 * the existing Neptune Odyssey templates and components. Supply a
 * [BrandprintConfig] (a client's real seeds) and a [logo] slot (their real
 * mark) — everything else has a working default so the demo runs immediately.
 *
 * The shell is the app root: it applies [NeptuneTheme] itself (the Dart
 * `MaterialApp.theme/darkTheme/themeMode`) and flips [LocalLayoutDirection]
 * to RTL while Arabic is active (the Dart `Directionality` builder). Dark
 * mode and language toggle live on the Profile tab; the welcome screen
 * carries the language chip; Log out returns to welcome.
 *
 * Flutter counterpart: `NeptuneDemoShellApp` (neptune_demo_shell.dart).
 */
@Composable
public fun NeptuneDemoShellApp(
    config: BrandprintConfig,
    bankNameEn: String,
    bankNameAr: String,
    logo: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    startArabic: Boolean = false,
    customerName: String = "Lina Atiya",
    customerNameAr: String = "لينا عطية",
) {
    // The Dart `_NeptuneDemoShellAppState` fields, verbatim.
    var arabic by remember { mutableStateOf(startArabic) }
    var dark by remember { mutableStateOf(false) }
    var inApp by remember { mutableStateOf(false) }

    val l = remember(arabic) { NeptuneDemoStrings(arabic = arabic) }
    val bankName = if (arabic) bankNameAr else bankNameEn

    NeptuneTheme(config = config, dark = dark, arabic = arabic) {
        CompositionLocalProvider(
            LocalLayoutDirection provides if (arabic) LayoutDirection.Rtl else LayoutDirection.Ltr,
        ) {
            val scheme = MaterialTheme.colorScheme
            Box(modifier.fillMaxSize().background(scheme.surface)) {
                if (inApp) {
                    DemoTabShell(
                        l = l,
                        logo = logo,
                        customerName = if (arabic) customerNameAr else customerName,
                        dark = dark,
                        arabic = arabic,
                        onToggleDark = { dark = it },
                        onToggleArabic = { arabic = it },
                        onLogout = { inApp = false },
                    )
                } else {
                    DemoWelcome(
                        l = l,
                        bankName = bankName,
                        logo = logo,
                        arabic = arabic,
                        onEnter = { inApp = true },
                        onToggleArabic = { arabic = !arabic },
                    )
                }
            }
        }
    }
}

/**
 * [NeptuneDemoShellApp] from a reference brand id
 * (`"neptune"|"triton"|"nereid"|"proteus"`) **or** a portable `NO1-…`
 * brandprint string — the same dual input [NeptuneTheme] accepts.
 *
 * @throws IllegalArgumentException on an unknown brand id or a malformed
 *   brandprint.
 */
@Composable
public fun NeptuneDemoShellApp(
    brand: String,
    bankNameEn: String,
    bankNameAr: String,
    logo: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    startArabic: Boolean = false,
    customerName: String = "Lina Atiya",
    customerNameAr: String = "لينا عطية",
) {
    val config = remember(brand) {
        if (brand.startsWith("NO1-")) {
            Brandprint.decode(brand)
        } else {
            requireNotNull(brandConfigs[brand]) { "unknown reference brand: $brand" }
        }
    }
    NeptuneDemoShellApp(
        config = config,
        bankNameEn = bankNameEn,
        bankNameAr = bankNameAr,
        logo = logo,
        modifier = modifier,
        startArabic = startArabic,
        customerName = customerName,
        customerNameAr = customerNameAr,
    )
}

// --- welcome ---------------------------------------------------------------------

/** The welcome branch of the Dart shell: `NeptuneWelcome` with the client
 * lockup + CTA pair, and the language chip floated top-end (the Dart
 * `PositionedDirectional(top: 18, end: 18)` inside `SafeArea`). */
@Composable
private fun DemoWelcome(
    l: NeptuneDemoStrings,
    bankName: String,
    logo: @Composable () -> Unit,
    arabic: Boolean,
    onEnter: () -> Unit,
    onToggleArabic: () -> Unit,
) {
    Box(Modifier.fillMaxSize()) {
        NeptuneWelcome(
            brandInitial = bankName.take(1),
            brandName = bankName,
            lockup = { BrandLockup(logo = logo, name = bankName) },
            title = l.welcomeTitle,
            emphasis = l.welcomeEmphasis,
            supporting = l.welcomeSub,
            primaryAction = { NeptuneCta(l.getStarted, onClick = onEnter, arrow = true) },
            secondaryAction = { NeptuneCta(l.haveAccount, onClick = onEnter, tonal = true) },
        )
        Box(
            Modifier
                .align(Alignment.TopEnd)
                .windowInsetsPadding(
                    WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.End),
                )
                .padding(top = 18.dp, end = 18.dp),
        ) {
            NeptuneChip(
                label = if (arabic) "English" else "العربية",
                onClick = onToggleArabic,
            )
        }
    }
}

/** The client mark next to the bank name at display-w800 20sp — the Dart
 * `_BrandLockup` (11dp between logo and name). */
@Composable
private fun BrandLockup(logo: @Composable () -> Unit, name: String) {
    val scheme = MaterialTheme.colorScheme
    val display = rememberNeptuneFontFamily(NeptuneTheme.type.display)
    Row(verticalAlignment = Alignment.CenterVertically) {
        logo()
        Spacer(Modifier.width(11.dp))
        Text(
            name,
            style = MaterialTheme.typography.titleLarge.copy(
                fontFamily = display,
                fontWeight = FontWeight.W800,
                fontSize = 20.sp,
                color = scheme.onSurface,
            ),
        )
    }
}

// --- the 5-tab glass-dock shell ----------------------------------------------------

/** The Dart `_DemoTabShell`: shell-owned tab/transfer state, the tab content
 * marked as glass backdrop, and the floating dock (the Dart
 * `EdgeInsetsDirectional.fromSTEB(12, 0, 12, 12)` bottom bar). */
@Composable
private fun DemoTabShell(
    l: NeptuneDemoStrings,
    logo: @Composable () -> Unit,
    customerName: String,
    dark: Boolean,
    arabic: Boolean,
    onToggleDark: (Boolean) -> Unit,
    onToggleArabic: (Boolean) -> Unit,
    onLogout: () -> Unit,
) {
    var tab by remember { mutableStateOf(0) }
    var transferStep by remember { mutableStateOf(0) }
    var sendState by remember { mutableStateOf<NeptuneFlowStatus?>(null) }

    // The Dart `_send()`: 2200ms of simulated processing, then success. Lives
    // at the shell level, so it keeps running if the user switches tabs.
    LaunchedEffect(sendState) {
        if (sendState == NeptuneFlowStatus.Loading) {
            delay(2200)
            sendState = NeptuneFlowStatus.Success
        }
    }

    // The shell hosts the glass dock: it creates the scope, publishes it, and
    // marks the tab content region as the backdrop the dock blurs.
    val glass = rememberNptGlassScope()
    CompositionLocalProvider(LocalNptGlassScope provides glass) {
        Box(Modifier.fillMaxSize()) {
            Box(Modifier.fillMaxSize().nptGlassBackground(glass)) {
                when (tab) {
                    0 -> NeptuneDashboardTemplate(
                        greeting = l.goodMorning,
                        customer = customerName,
                        balanceLabel = l.availableBalance,
                        balance = "LYD 24,830.75",
                        balanceCaption = "•••• 4821",
                        leading = { Box(Modifier.width(26.dp)) { logo() } },
                        actions = listOf(
                            NeptuneQuickActionItem(l.send, { Icon(NptIcons.send, contentDescription = null) }, {}),
                            NeptuneQuickActionItem(l.topUp, { Icon(NptIcons.cardAdd, contentDescription = null) }, {}),
                            NeptuneQuickActionItem(l.pay, { Icon(NptIcons.qrCode, contentDescription = null) }, {}),
                            NeptuneQuickActionItem(l.request, { Icon(NptIcons.request, contentDescription = null) }, {}),
                        ),
                        statPair = NeptuneStatData(l.thisMonth, "3,540", "LYD", "−2.1%"),
                        activityTitle = l.recentActivity,
                        transactions = listOf(
                            NeptuneTxData(l.salary, "${l.today} · ${l.sendTransfer}", "+3,200.00 LYD", credit = true),
                            NeptuneTxData(l.groceryMarket, "${l.today} · ${l.navCards}", "−86.40 LYD"),
                            NeptuneTxData(l.coffeeBar, "${l.yesterday} · ${l.navCards}", "−4.50 LYD"),
                        ),
                    )
                    1 -> {
                        val outcome = sendState
                        if (outcome == null) {
                            NeptuneTransferTemplate(
                                step = transferStep,
                                payees = listOf(
                                    NeptunePayeeData(l.t("Sara Nuri", "سارة نوري"), "•••• 7390"),
                                    NeptunePayeeData(l.t("Omar K.", "عمر ك."), "•••• 1204"),
                                ),
                                confirmLabel = l.confirmSend,
                                onPayee = {},
                                onContinue = { transferStep = 1 },
                                onConfirm = { sendState = NeptuneFlowStatus.Loading },
                            )
                        } else {
                            TransferOutcome(
                                l = l,
                                status = outcome,
                                onDone = {
                                    sendState = null
                                    transferStep = 0
                                },
                            )
                        }
                    }
                    2 -> CardsTab(l)
                    3 -> InsightsTab(l)
                    else -> ProfileTab(
                        l = l,
                        customerName = customerName,
                        dark = dark,
                        arabic = arabic,
                        onToggleDark = onToggleDark,
                        onToggleArabic = onToggleArabic,
                        onLogout = onLogout,
                    )
                }
            }
            Box(
                Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .windowInsetsPadding(
                        WindowInsets.safeDrawing
                            .only(WindowInsetsSides.Bottom + WindowInsetsSides.Horizontal),
                    )
                    .padding(start = 12.dp, end = 12.dp, bottom = 12.dp),
            ) {
                NeptuneDock(
                    items = listOf(
                        NeptuneDockItem(l.navHome) { Icon(NptIcons.home, contentDescription = null) },
                        NeptuneDockItem(l.navTransfer) { Icon(NptIcons.transfer, contentDescription = null) },
                        NeptuneDockItem(l.navCards) { Icon(NptIcons.card, contentDescription = null) },
                        NeptuneDockItem(l.navInsights) { Icon(NptIcons.chartPie, contentDescription = null) },
                        NeptuneDockItem(l.navProfile) { Icon(NptIcons.user, contentDescription = null) },
                    ),
                    selectedIndex = tab,
                    onSelect = { tab = it },
                    modifier = Modifier.fillMaxWidth(),
                )
            }
        }
    }
}

// --- transfer outcome --------------------------------------------------------------

/** The Dart shell's own outcome screen (it does not delegate to the transfer
 * template's step 2): centred `NeptuneStatusMotion` at 116dp, the
 * sending/success title, the processing line or the sent amount, and the
 * Done CTA once settled. */
@Composable
private fun TransferOutcome(
    l: NeptuneDemoStrings,
    status: NeptuneFlowStatus,
    onDone: () -> Unit,
) {
    val scheme = MaterialTheme.colorScheme
    val typography = MaterialTheme.typography
    val sending = status == NeptuneFlowStatus.Loading

    Box(
        Modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            )
            .padding(32.dp),
        contentAlignment = Alignment.Center,
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            NeptuneStatusMotion(status = status, size = 116.dp)
            Spacer(Modifier.height(22.dp))
            Text(
                if (sending) l.sendingTitle else l.successTitle,
                style = typography.headlineSmall.copy(color = scheme.onSurface),
            )
            Spacer(Modifier.height(8.dp))
            Text(
                if (sending) l.sendingSub else NeptuneTheme.formatDigits("LYD 250.00"),
                style = typography.bodyMedium.copy(color = scheme.onSurfaceVariant),
            )
            Spacer(Modifier.height(26.dp))
            if (!sending) {
                NeptuneCta(l.doneLabel, onClick = onDone, expand = false)
            }
        }
    }
}

// --- cards tab ---------------------------------------------------------------------

/** The Dart `_CardsTab`: the cards template with a local freeze toggle. */
@Composable
private fun CardsTab(l: NeptuneDemoStrings) {
    var frozen by remember { mutableStateOf(false) }
    NeptuneCardsTemplate(
        title = l.myCards,
        cards = listOf(
            NeptuneCardData(holder = "LINA ATIYA", last4 = "4821", expiry = "08/27", scheme = "VISA"),
        ),
        frozen = frozen,
        onControl = { if (it == "freeze") frozen = !frozen },
        activityTitle = l.recentActivity,
        transactions = listOf(
            NeptuneTxData(l.groceryMarket, "${l.today} · ${l.navCards}", "−86.40 LYD"),
            NeptuneTxData(l.coffeeBar, "${l.yesterday} · ${l.navCards}", "−4.50 LYD"),
        ),
    )
}

// --- insights tab --------------------------------------------------------------------

/** The Dart `_InsightsTab`: budget ring + stat card + sparkline, the
 * category comparison and the FX card. */
@Composable
private fun InsightsTab(l: NeptuneDemoStrings) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            ),
        contentPadding = PaddingValues(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 110.dp),
    ) {
        item {
            Row(verticalAlignment = Alignment.CenterVertically) {
                NeptuneBudgetRing(spent = 1240.0, limit = 2000.0, label = l.thisMonth)
                Spacer(Modifier.width(14.dp))
                Column(Modifier.weight(1f), horizontalAlignment = Alignment.CenterHorizontally) {
                    NeptuneStatCard(label = l.thisMonth, value = "1,240", unit = "LYD", delta = "−12%")
                    Spacer(Modifier.height(10.dp))
                    NeptuneSparkline(
                        points = listOf(4f, 3f, 5f, 4f, 6f, 5f, 7f),
                        height = 48.dp,
                    )
                }
            }
        }
        item {
            Spacer(Modifier.height(16.dp))
            NeptuneSection(title = l.spendByCategory) {
                NeptuneCompareBars(
                    currentLabel = l.thisMonth,
                    previousLabel = l.lastMonth,
                    data = listOf(
                        NeptuneCompareData(l.food, 430f, 510f),
                        NeptuneCompareData(l.bills, 380f, 330f),
                        NeptuneCompareData(l.transport, 210f, 260f),
                        NeptuneCompareData(l.shopping, 190f, 140f),
                    ),
                )
            }
            Spacer(Modifier.height(16.dp))
            NeptuneFxCard(fromCurrency = "LYD", toCurrency = "USD", rate = "0.2065", change = "+0.4%")
        }
    }
}

// --- profile tab -----------------------------------------------------------------------

/** The Dart `_ProfileTab`: identity row, appearance (dark toggle + EN/ع
 * language segmented), security (biometric switch) and the outlined
 * log-out button. */
@Composable
private fun ProfileTab(
    l: NeptuneDemoStrings,
    customerName: String,
    dark: Boolean,
    arabic: Boolean,
    onToggleDark: (Boolean) -> Unit,
    onToggleArabic: (Boolean) -> Unit,
    onLogout: () -> Unit,
) {
    LazyColumn(
        modifier = Modifier
            .fillMaxSize()
            .windowInsetsPadding(
                WindowInsets.safeDrawing.only(WindowInsetsSides.Top + WindowInsetsSides.Horizontal),
            ),
        contentPadding = PaddingValues(start = 16.dp, top = 12.dp, end = 16.dp, bottom = 110.dp),
    ) {
        item {
            NeptuneListTile(
                title = customerName,
                leading = { NeptuneAvatar(initials = customerName.take(1), size = 48.dp) },
                trailing = { NeptuneTierBadge(tier = "Gold") },
            )
            Spacer(Modifier.height(10.dp))
            NeptuneSection(title = l.appearance) {
                Column {
                    NeptuneListTile(
                        title = l.themeRow,
                        leading = { LeadingIconTile(NptIcons.moon) },
                        trailing = { NeptuneSwitch(value = dark, onChanged = onToggleDark) },
                    )
                    NeptuneListTile(
                        title = l.language,
                        leading = { LeadingIconTile(NptIcons.language) },
                        trailing = {
                            NeptuneSegmented(
                                options = listOf("EN", "ع"),
                                selectedIndex = if (arabic) 1 else 0,
                                onSelect = { onToggleArabic(it == 1) },
                            )
                        },
                    )
                }
            }
            NeptuneSection(title = l.security) {
                NeptuneListTile(
                    title = l.biometric,
                    leading = { LeadingIconTile(NptIcons.fingerprint) },
                    trailing = { NeptuneSwitch(value = true, onChanged = {}) },
                )
            }
            Spacer(Modifier.height(8.dp))
            NeptuneButton(
                label = l.logout,
                onClick = onLogout,
                variant = NeptuneButtonStyle.Outlined,
                icon = { Icon(NptIcons.logout, contentDescription = null) },
                expand = true,
            )
        }
    }
}

/** The Flutter `NeptuneListTile.leadingIcon` recipe (neptune_display.dart):
 * a 40dp `primaryContainer` square on rSm with a 20dp `onPrimaryContainer`
 * icon centred inside. */
@Composable
private fun LeadingIconTile(icon: ImageVector) {
    val scheme = MaterialTheme.colorScheme
    Box(
        Modifier
            .size(40.dp)
            .clip(NeptuneTheme.shape.rSm)
            .background(scheme.primaryContainer),
        contentAlignment = Alignment.Center,
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = scheme.onPrimaryContainer,
            modifier = Modifier.size(20.dp),
        )
    }
}
