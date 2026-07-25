# Story 31 – Phase 2 Consistency & QA Pass

## Objective

Final audit pass across the entire redesigned app: confirm theme
consistency, no hardcoded colors regressed back in, responsive correctness,
and no leftover dead code from the redesign.

## AI Prompt

```text
Audit the full app after Stories 21–30:

- Grep for hardcoded Color(...)/hex values or literal TextStyle font sizes
  introduced during the redesign; fix any found
- Verify every screen renders correctly in both light and dark theme
- Verify responsive behavior (phone/tablet, portrait/landscape) across all
  4 bottom-nav tabs, auth screens, and the chat screen
- Remove any dead code, duplicated one-off widgets, or commented-out code
  introduced while iterating on Stories 21–30
- Confirm no Phase 1 domain rule or backend contract was altered (see
  project-context.md Core Domain Rules) — this phase is UI/UX only
- Confirm no "What NOT to Build" item was accidentally introduced (no
  real-time transport, no group chat, no media messages, etc.)
```

## Acceptance Criteria

- No hardcoded colors/literal text styles exist anywhere in `lib/`
- Every screen confirmed correct in both light and dark theme
- Responsive check passes on phone and tablet, portrait and landscape, for
  all 4 tabs, auth flow, and chat screen
- No dead code, duplicated widgets, or leftover TODOs from Stories 21–30
- Core domain rules and backend contracts from `project-context.md` are
  unchanged
- No item from "What NOT to Build" was introduced during the redesign
