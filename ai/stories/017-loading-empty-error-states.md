# Story 17 – Loading, Empty & Error States

## Objective

Improve UX.

## AI Prompt

```text
Create reusable

Loading widgets

Skeleton loaders

Empty states

Network error widgets

Retry buttons

Use throughout application.
```

## Acceptance Criteria

- `core/widgets` gains (or has its existing) Loading, Skeleton loader,
  Empty State, and Network Error (with Retry) widgets consolidated into a
  single reusable set — no screen defines its own ad-hoc version
- Every screen introduced in Stories 3–16 that fetches remote data is
  audited and updated to use these shared widgets for its loading/empty/
  error states, per `coding-standards.md`
- Skeleton loaders are used on list/detail screens with a clear visual
  shape (list rows, cards) rather than a single generic spinner, where a
  spinner alone would feel like a regression
- Retry buttons on error states re-trigger the same fetch/provider call
  that failed, not a full screen reload
- No behavior change to what data is fetched — this story is purely
  about consistent presentation of existing loading/empty/error states
