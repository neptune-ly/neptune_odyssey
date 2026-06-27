// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Hero balance card. The web layer paints a gradient via CSS; RN has no gradient without
// a native dependency, so we keep this layer dependency-free and use a solid `primary`
// fill with `on-primary` content. Amount uses tabular figures. All values from the theme.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

import { createElement } from "react";
import type { ReactNode } from "react";
import { View, Text, StyleSheet } from "react-native";
import type { ViewProps, ViewStyle, StyleProp } from "react-native";
import { useNeptuneTheme } from "../context.js";

export interface NeptuneBalanceCardProps extends ViewProps {
  label: string;
  amount: string;
  currency?: string;
  style?: StyleProp<ViewStyle>;
}

export function NeptuneBalanceCard({
  label,
  amount,
  currency,
  style,
  ...rest
}: NeptuneBalanceCardProps): ReactNode {
  const theme = useNeptuneTheme();
  const c = theme.colors;
  const t = theme.type;

  const styles = StyleSheet.create({
    card: {
      backgroundColor: c.primary,
      borderRadius: theme.shape.xl,
      paddingVertical: 24,
      paddingHorizontal: 24,
    },
    label: {
      color: c["on-primary"],
      fontFamily: t.text,
      fontSize: 13,
      opacity: 0.85,
      marginBottom: 8,
      writingDirection: theme.dir,
    },
    amountRow: {
      flexDirection: "row",
      alignItems: "flex-end",
    },
    amount: {
      color: c["on-primary"],
      fontFamily: t.num,
      fontSize: 34,
      fontWeight: String(t.displayWeight),
      fontVariant: ["tabular-nums"],
      writingDirection: theme.dir,
    },
    currency: {
      color: c["on-primary"],
      fontFamily: t.text,
      fontSize: 16,
      opacity: 0.85,
      marginStart: 8,
      marginBottom: 4,
      writingDirection: theme.dir,
    },
  });

  return createElement(
    View,
    { style: [styles.card, style], accessibilityRole: "summary", ...rest },
    createElement(Text, { style: styles.label }, label),
    createElement(
      View,
      { style: styles.amountRow },
      createElement(Text, { style: styles.amount }, amount),
      currency ? createElement(Text, { style: styles.currency }, currency) : null,
    ),
  );
}
