import {
  NptBalanceCard,
  NptButton,
  NptCard,
  NptNavBar,
  NptNavItem,
  NptTransactionRow,
} from "@neptune.fintech/react-ui";
import type { ModeOption } from "@neptune.fintech/react-ui";

export interface DashboardProps {
  mode: ModeOption;
  onToggleMode: () => void;
}

export function Dashboard({ mode, onToggleMode }: DashboardProps) {
  return (
    <div className="app">
      <header className="app__bar">
        <span className="app__brand">{{PROJECT_TITLE}}</span>
        <button className="app__mode" type="button" onClick={onToggleMode}>
          {mode === "dark" ? "☀ Light" : "☾ Dark"}
        </button>
      </header>

      <main className="app__body">
        <NptBalanceCard
          hero=""
          label="Available balance"
          amount="12,480.50"
          currency="LYD"
          account="•••• 4821"
        />

        <div className="stat-row">
          <npt-stat-card label="Income" value="9,120" unit="LYD" delta="+8.2%"></npt-stat-card>
          <npt-stat-card label="Spending" value="3,540" unit="LYD" delta="-2.1%"></npt-stat-card>
        </div>

        <npt-quick-actions>
          <npt-quick-action label="Send">
            <npt-icon slot="icon" name="transfer"></npt-icon>
          </npt-quick-action>
          <npt-quick-action label="Request">
            <npt-icon slot="icon" name="wallet"></npt-icon>
          </npt-quick-action>
          <npt-quick-action label="Pay">
            <npt-icon slot="icon" name="card"></npt-icon>
          </npt-quick-action>
          <npt-quick-action label="Top up">
            <npt-icon slot="icon" name="card-add"></npt-icon>
          </npt-quick-action>
        </npt-quick-actions>

        <p className="section-title">Recent activity</p>
        <NptCard variant="outlined" className="txns">
          <NptTransactionRow title="Salary" subtitle="Today · Transfer" amount="+3,200.00" currency="LYD" credit="" />
          <NptTransactionRow title="Grocery Market" subtitle="Yesterday · Card" amount="-86.40" currency="LYD" />
          <NptTransactionRow title="Electricity" subtitle="Mon · Bill" amount="-120.00" currency="LYD" />
          <NptTransactionRow title="Refund" subtitle="Sun · OnePay" amount="+45.00" currency="LYD" credit="" />
        </NptCard>

        <NptButton variant="filled" onClick={() => window.alert("Wire this to your transfer flow.")}>
          Send money
        </NptButton>
      </main>

      <nav className="app__nav">
        <NptNavBar>
          <NptNavItem label="Home" active="">
            <npt-icon name="home"></npt-icon>
          </NptNavItem>
          <NptNavItem label="Cards">
            <npt-icon name="card"></npt-icon>
          </NptNavItem>
          <NptNavItem label="Pay">
            <npt-icon name="transfer"></npt-icon>
          </NptNavItem>
          <NptNavItem label="More">
            <npt-icon name="settings"></npt-icon>
          </NptNavItem>
        </NptNavBar>
      </nav>
    </div>
  );
}
