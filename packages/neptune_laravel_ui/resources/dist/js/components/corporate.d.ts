import { NptElement } from "./base.js";
/**
 * <npt-approval-item title="Vendor payment — ACME" amount="48,200.00" currency="LYD"
 *   maker="Mona Khaled" status="pending|approved|rejected"></npt-approval-item>
 * A maker-checker queue item. Approve/Reject buttons emit `approve` / `reject`.
 * Buttons hide once the item is no longer `pending`; the status chip reflects state.
 */
export declare class NptApprovalItem extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private onClick;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-batch-card filename="payroll-jun.csv" totalAmount="1,204,800.00" currency="LYD"
 *   payeeCount="312" requiredApprovals="2" validated="308" warnings="3" errors="1">
 *   <npt-button slot="action">Submit batch</npt-button>
 * </npt-batch-card>
 * A bulk-payment batch summary with a validated/warnings/errors counts row and an
 * action slot for the primary CTA.
 */
export declare class NptBatchCard extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-audit-row actor="Mona Khaled" action="approved payment" target="#PAY-3192"
 *   time="2026-06-27 14:02"></npt-audit-row>
 * A compact audit-log line with a leading status dot.
 */
export declare class NptAuditRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-user-row name="Mona Khaled" email="mona@bank.ly" role="Checker"
 *   initials="MK" src="" [suspended]>
 *   <npt-icon-button slot="actions">⋯</npt-icon-button>
 * </npt-user-row>
 * A user-admin list row: avatar/initials, name + email, role chip, status, and a
 * trailing actions slot. `suspended` dims the row and shows a Suspended chip.
 */
export declare class NptUserRow extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-permission-toggle label="Approve payments"
 *   description="Allow this role to release outgoing transfers" [checked] [disabled]>
 * </npt-permission-toggle>
 * Label + description + a switch-like toggle. Emits `change` when toggled.
 */
export declare class NptPermissionToggle extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    connectedCallback(): void;
    disconnectedCallback(): void;
    private toggle;
    private onClick;
    private onKey;
    protected styles(): string;
    protected render(): string;
}
/**
 * <npt-workflow-status steps="Submitted,Checked,Approved" active="1"></npt-workflow-status>
 * A compact multi-step status indicator. `active` is the zero-based index of the
 * current step; earlier steps render as complete, later steps as upcoming.
 */
export declare class NptWorkflowStatus extends NptElement {
    static observedAttributes: string[];
    attributeChangedCallback(): void;
    protected styles(): string;
    protected render(): string;
}
//# sourceMappingURL=corporate.d.ts.map