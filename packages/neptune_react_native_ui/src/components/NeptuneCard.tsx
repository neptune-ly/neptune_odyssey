// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Themed surface card. Background, radius, and outline all read from the theme.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

import { createElement } from "react";
import type { ReactNode } from "react";
import { View, StyleSheet } from "react-native";
import type { ViewProps, ViewStyle, StyleProp } from "react-native";
import { useNeptuneTheme } from "../context.js";

export interface NeptuneCardProps extends ViewProps {
  /** Use the slightly raised surface-container tone instead of plain surface. */
  container?: boolean;
  /** Draw a hairline outline. */
  outlined?: boolean;
  style?: StyleProp<ViewStyle>;
  children?: ReactNode;
}

export function NeptuneCard({
  container = false,
  outlined = false,
  style,
  children,
  ...rest
}: NeptuneCardProps): ReactNode {
  const theme = useNeptuneTheme();
  const c = theme.colors;

  const styles = StyleSheet.create({
    card: {
      backgroundColor: container ? c["surface-container"] : c.surface,
      borderRadius: theme.shape.lg,
      padding: 16,
      borderWidth: outlined ? 1 : 0,
      borderColor: outlined ? c.outline : "transparent",
    },
  });

  return createElement(View, { style: [styles.card, style], ...rest }, children);
}
