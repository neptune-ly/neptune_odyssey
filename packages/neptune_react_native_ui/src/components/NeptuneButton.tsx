// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Themed Pressable button. Four Material-ish variants, all colored from the theme; min
// height 48 dp for a comfortable touch target. No literal colors, radii, or fonts.
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

import { createElement } from "react";
import type { ReactNode } from "react";
import { Pressable, Text, StyleSheet } from "react-native";
import type { PressableProps, PressableStateCallbackType, ViewStyle, StyleProp } from "react-native";
import { useNeptuneTheme } from "../context.js";

export type NeptuneButtonVariant = "filled" | "tonal" | "outlined" | "text";

export interface NeptuneButtonProps extends Omit<PressableProps, "children" | "style"> {
  variant?: NeptuneButtonVariant;
  label: string;
  disabled?: boolean;
  style?: StyleProp<ViewStyle>;
}

export function NeptuneButton({
  variant = "filled",
  label,
  disabled = false,
  style,
  ...rest
}: NeptuneButtonProps): ReactNode {
  const theme = useNeptuneTheme();
  const c = theme.colors;

  const surface: Record<NeptuneButtonVariant, { bg: string; fg: string; border?: string }> = {
    filled: { bg: c.primary, fg: c["on-primary"] },
    tonal: { bg: c["secondary-container"], fg: c["on-secondary-container"] },
    outlined: { bg: c.surface, fg: c.primary, border: c.outline },
    text: { bg: c.surface, fg: c.primary },
  };
  const v = surface[variant];

  const styles = StyleSheet.create({
    base: {
      minHeight: 48,
      borderRadius: theme.shape.full,
      paddingVertical: 12,
      paddingHorizontal: 24,
      alignItems: "center",
      justifyContent: "center",
      flexDirection: "row",
      backgroundColor: variant === "text" ? "transparent" : v.bg,
      borderWidth: v.border ? 1 : 0,
      borderColor: v.border ?? "transparent",
    },
    label: {
      color: v.fg,
      fontFamily: theme.type.text,
      fontSize: 16,
      fontWeight: "600",
      writingDirection: theme.dir,
    },
  });

  const computeStyle = ({ pressed }: PressableStateCallbackType): StyleProp<ViewStyle> => [
    styles.base,
    { opacity: disabled ? 0.5 : pressed ? 0.85 : 1 },
    style,
  ];

  return createElement(
    Pressable,
    {
      accessibilityRole: "button",
      disabled,
      style: computeStyle,
      ...rest,
    },
    createElement(Text, { style: styles.label }, label),
  );
}
