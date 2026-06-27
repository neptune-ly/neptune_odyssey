// Let any <npt-*> Neptune custom element be used directly in JSX. The typed
// wrappers from @neptune.fintech/react-ui (NptButton, NptCard, …) cover the
// common ones; this opens up the full set (npt-stat-card, npt-icon, …).
import type { DetailedHTMLProps, HTMLAttributes } from "react";

type NptElement = DetailedHTMLProps<HTMLAttributes<HTMLElement>, HTMLElement> &
  Record<string, unknown>;

declare global {
  namespace JSX {
    interface IntrinsicElements {
      [tag: `npt-${string}`]: NptElement;
    }
  }
}

export {};
