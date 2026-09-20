# Component property defaults

Figma shares a component-property default across variants. Where a component has paired English and Arabic text or slot properties, select the property that matches its `Direction` master so fresh instances start with the correct locale. Those paired properties are deliberate editable defaults, not duplicate content.

State-derived copy, such as a frozen-card status or its Freeze/Unfreeze action, belongs to the relevant variant. Do not override it with a shared text property. Property definitions belong to the component set; only bindings in the selected variant affect its visible content. Do not assume every property applies to every variant.

Data examples with distinct numeric defaults expose state-specific fields: Stat card uses `Delta` for Up and `Delta down` for Down; its no-change copy belongs to None. Limit meter uses `Amount`, `Warning amount`, or `Limit amount` for the corresponding status. Trend uses `Value EN`/`Value AR` for Up, `Down value` for Down, and `Flat value` for Flat. These values are editable display fixtures; changing a label does not recalculate chart geometry or execute a financial operation.
