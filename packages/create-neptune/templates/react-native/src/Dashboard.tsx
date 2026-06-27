// {{PROJECT_TITLE}} — sample dashboard, composed from @neptune.fintech/react-native-ui.
import { Pressable, SafeAreaView, ScrollView, StyleSheet, View } from "react-native";
import {
  NeptuneBalanceCard,
  NeptuneButton,
  NeptuneCard,
  NeptuneText,
  NeptuneTransactionRow,
  useNeptuneTheme,
} from "@neptune.fintech/react-native-ui";
import type { Mode } from "@neptune.fintech/react-native-ui";

export interface DashboardProps {
  mode: Mode;
  onToggleMode: () => void;
}

export function Dashboard({ mode, onToggleMode }: DashboardProps) {
  const theme = useNeptuneTheme();
  const c = theme.colors;

  return (
    <SafeAreaView style={[styles.root, { backgroundColor: c.background }]}>
      <View style={styles.bar}>
        <NeptuneText variant="title">{{PROJECT_TITLE}}</NeptuneText>
        <Pressable
          onPress={onToggleMode}
          style={[styles.modeBtn, { borderColor: c["outline-variant"] }]}
        >
          <NeptuneText variant="label">{mode === "dark" ? "☀ Light" : "☾ Dark"}</NeptuneText>
        </Pressable>
      </View>

      <ScrollView contentContainerStyle={styles.body}>
        <NeptuneBalanceCard label="Available balance" amount="12,480.50" currency="LYD" />

        <View style={styles.statRow}>
          <NeptuneCard container style={styles.stat}>
            <NeptuneText variant="label" muted>
              Income
            </NeptuneText>
            <NeptuneText variant="title">9,120 LYD</NeptuneText>
          </NeptuneCard>
          <NeptuneCard container style={styles.stat}>
            <NeptuneText variant="label" muted>
              Spending
            </NeptuneText>
            <NeptuneText variant="title">3,540 LYD</NeptuneText>
          </NeptuneCard>
        </View>

        <NeptuneText variant="label" muted style={styles.sectionTitle}>
          RECENT ACTIVITY
        </NeptuneText>
        <NeptuneCard outlined>
          <NeptuneTransactionRow title="Salary" subtitle="Today · Transfer" amount="+3,200.00 LYD" credit />
          <NeptuneTransactionRow title="Grocery Market" subtitle="Yesterday · Card" amount="-86.40 LYD" />
          <NeptuneTransactionRow title="Electricity" subtitle="Mon · Bill" amount="-120.00 LYD" />
          <NeptuneTransactionRow title="Refund" subtitle="Sun · OnePay" amount="+45.00 LYD" credit />
        </NeptuneCard>

        <NeptuneButton variant="filled" label="Send money" onPress={() => undefined} />
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  root: { flex: 1 },
  bar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingTop: 12,
    paddingBottom: 8,
  },
  modeBtn: { borderWidth: 1, borderRadius: 999, paddingVertical: 8, paddingHorizontal: 14 },
  body: { padding: 20, gap: 16 },
  statRow: { flexDirection: "row", gap: 12 },
  stat: { flex: 1, gap: 4 },
  sectionTitle: { marginTop: 4, letterSpacing: 1 },
});
