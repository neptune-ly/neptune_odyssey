// Neptune Odyssey — @neptune.fintech/react-native-ui · © 2026 Neptune.Fintech (neptune.ly)
// Minimal ambient stub for the slice of `react-native` this layer touches. The real
// `react-native` package is a heavy peer dependency we deliberately do NOT install: it
// would bloat CI and pull native toolchains for a pure-TypeScript build. Declaring only
// the surface we use lets `tsc` typecheck + emit declarations without the dependency.
// Consumers supply the real `react-native` at runtime (a peerDependency).
// Licensed under the Neptune Odyssey Community License v1.0 (see LICENSE).

declare module "react-native" {
  import type { ComponentType, ReactNode, Ref } from "react";

  export type ViewStyle = Record<string, unknown>;
  export type TextStyle = Record<string, unknown>;

  // Mirrors RN's recursive style prop: a value, a falsy slot, or a (nested) array of
  // either. This is what lets `style={[a, maybeUndefined]}` typecheck.
  export type Falsy = undefined | null | false;
  export interface RecursiveArray<T>
    extends Array<T | ReadonlyArray<T> | RecursiveArray<T>> {}
  export type StyleProp<T> = T | RecursiveArray<T | Falsy> | Falsy;

  export interface ViewProps {
    style?: StyleProp<ViewStyle>;
    children?: ReactNode;
    pointerEvents?: "auto" | "none" | "box-none" | "box-only";
    accessibilityLabel?: string;
    accessibilityRole?: string;
    testID?: string;
    ref?: Ref<unknown>;
    [key: string]: unknown;
  }

  export interface TextProps {
    style?: StyleProp<TextStyle>;
    children?: ReactNode;
    numberOfLines?: number;
    accessibilityLabel?: string;
    accessibilityRole?: string;
    testID?: string;
    ref?: Ref<unknown>;
    [key: string]: unknown;
  }

  export interface PressableStateCallbackType {
    pressed: boolean;
  }

  export interface PressableProps {
    style?:
      | StyleProp<ViewStyle>
      | ((state: PressableStateCallbackType) => StyleProp<ViewStyle>);
    children?: ReactNode | ((state: PressableStateCallbackType) => ReactNode);
    onPress?: () => void;
    onLongPress?: () => void;
    disabled?: boolean;
    accessibilityLabel?: string;
    accessibilityRole?: string;
    testID?: string;
    ref?: Ref<unknown>;
    [key: string]: unknown;
  }

  export const View: ComponentType<ViewProps>;
  export const Text: ComponentType<TextProps>;
  export const Pressable: ComponentType<PressableProps>;

  export const StyleSheet: {
    create<T extends Record<string, ViewStyle | TextStyle>>(styles: T): T;
    readonly hairlineWidth: number;
    flatten<T>(style: StyleProp<T>): T;
  };
}
