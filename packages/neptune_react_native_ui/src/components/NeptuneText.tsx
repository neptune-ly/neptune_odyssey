// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Themed Text. Every typographic value (family, weight, tracking, color) comes from the
// resolved theme — there are no literals. The `num` variant enables tabular figures via
// fontVariant so currency columns align. Licensed under the Neptune Odyssey Community
// License v1.0 (see LICENSE).

import { createElement } from "react";
import type { ReactNode } from "react";
import { Text, StyleSheet } from "react-native";
import type { TextProps, TextStyle, StyleProp } from "react-native";
import { useNeptuneTheme } from "../context.js";

export type NeptuneTextVariant = "display" | "title" | "body" | "label" | "num";

export interface NeptuneTextProps extends TextProps {
  variant?: NeptuneTextVariant;
  /** Muted (on-surface-variant) instead of full-emphasis on-surface. */
  muted?: boolean;
  style?: StyleProp<TextStyle>;
  children?: ReactNode;
}

export function NeptuneText({
  variant = "body",
  muted = false,
  style,
  children,
  ...rest
}: NeptuneTextProps): ReactNode {
  const theme = useNeptuneTheme();
  const c = theme.colors;
  const t = theme.type;

  const base: Record<NeptuneTextVariant, TextStyle> = {
    display: {
      fontFamily: t.display,
      fontWeight: String(t.displayWeight),
      letterSpacing: t.displayTracking * 16,
      fontSize: 32,
      lineHeight: 38,
      writingDirection: theme.dir,
    },
    title: {
      fontFamily: t.display,
      fontWeight: String(t.displayWeight),
      fontSize: 20,
      lineHeight: 26,
      writingDirection: theme.dir,
    },
    body: {
      fontFamily: t.text,
      fontSize: 16,
      lineHeight: 22,
      writingDirection: theme.dir,
    },
    label: {
      fontFamily: t.text,
      fontSize: 13,
      lineHeight: 18,
      writingDirection: theme.dir,
    },
    num: {
      fontFamily: t.num,
      fontSize: 16,
      lineHeight: 22,
      fontVariant: ["tabular-nums"],
      writingDirection: theme.dir,
    },
  };

  const styles = StyleSheet.create({
    text: {
      ...base[variant],
      color: muted ? c["on-surface-variant"] : c["on-surface"],
    },
  });

  return createElement(Text, { style: [styles.text, style], ...rest }, children);
}
