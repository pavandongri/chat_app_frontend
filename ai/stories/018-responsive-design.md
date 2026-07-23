# Story 18 – Responsive Design

## Objective

Support multiple devices.

## AI Prompt

```text
Make all screens responsive.

Support

Phones

Tablets

Landscape

Portrait

Avoid overflow.

Adaptive spacing.

Adaptive typography.
```

## Acceptance Criteria

- Every screen from Stories 3–17 is audited on phone and tablet, in both
  portrait and landscape, with no overflow errors or clipped content
- Spacing and typography scale using `Spacing`/`AppTypography` from
  `core/theme` (per `coding-standards.md`) rather than fixed pixel values
  sprinkled through feature code
- List/detail layouts adapt sensibly on wider (tablet) viewports (e.g.
  usable max content width, not just a stretched phone layout)
- No new features/screens are introduced — this story only fixes layout
  behavior of existing screens
