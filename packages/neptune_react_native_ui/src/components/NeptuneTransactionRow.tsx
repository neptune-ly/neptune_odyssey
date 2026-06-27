// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// A single transaction line: title + subtitle on the leading edge, a tabular amount on
// the trailing edge. Logical layout (marginStart/End, flexDirection:row) so it mirrors
// correctly under RTL. Credit amounts use the success role; debits use on-surface. All
// colors/fonts from the theme. Licensed under the Neptune Odyssey Community License v1.0.

import { createElement } from "react";
import type { ReactNode } from "react";
import { View, Text, Pressable, StyleSheet } from "react-native";
import type { ViewStyle, StyleProp } from "react-native";
import { useNeptuneTheme } from "../context.js";

export interface NeptuneTransactionRowProps {
  title: string;
  subtitle?: string;
  amount: string;
  /** Positive money in (rendered with the success color). */
  credit?: boolean;
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
  testID?: string;
}

export function NeptuneTransactionRow({
  title,
  subtitle,
  amount,
  credit = false,
  onPress,
  style,
  testID,
}: NeptuneTransactionRowProps): ReactNode {
  const theme = useNeptuneTheme();
  const c = theme.colors;
  const t = theme.type;

  const styles = StyleSheet.create({
    row: {
      flexDirection: "row",
      alignItems: "center",
      minHeight: 56,
      paddingVertical: 8,
      paddingHorizontal: 16,
      backgroundColor: c.surface,
    },
    main: { flex: 1, marginEnd: 12 },
    title: {
      color: c["on-surface"],
      fontFamily: t.text,
      fontSize: 16,
      writingDirection: theme.dir,
    },
    subtitle: {
      color: c["on-surface-variant"],
      fontFamily: t.text,
      fontSize: 13,
      marginTop: 2,
      writingDirection: theme.dir,
    },
    amount: {
      color: credit ? c.success : c["on-surface"],
      fontFamily: t.num,
      fontSize: 16,
      fontVariant: ["tabular-nums"],
      writingDirection: theme.dir,
    },
  });

  const content = createElement(
    View,
    { style: [styles.row, style], testID },
    createElement(
      View,
      { style: styles.main },
      createElement(Text, { style: styles.title, numberOfLines: 1 }, title),
      subtitle
        ? createElement(Text, { style: styles.subtitle, numberOfLines: 1 }, subtitle)
        : null,
    ),
    createElement(Text, { style: styles.amount }, amount),
  );

  if (onPress) {
    return createElement(
      Pressable,
      { onPress, accessibilityRole: "button", style: ({ pressed }) => ({ opacity: pressed ? 0.7 : 1 }) },
      content,
    );
  }
  return content;
}
