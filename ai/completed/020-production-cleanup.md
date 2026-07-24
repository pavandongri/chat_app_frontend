# Story 20 – Production Cleanup

## Objective

Prepare app for production.

## AI Prompt

```text
Review project.

Remove duplicate widgets.

Optimize rebuilds.

Improve Riverpod providers.

Optimize API layer.

Improve routing.

Clean code.

Consistent naming.

Prepare production-ready Flutter application.
```

## Acceptance Criteria

- No duplicate widget implementations remain — anything overlapping with
  `core/widgets` has been consolidated (final sweep on top of Story 17)
- Riverpod providers are audited for unnecessary rebuilds (correct
  `autoDispose` usage, no god-providers), per `coding-standards.md`
- `core/network` Dio setup, interceptors, and error parsing are reviewed
  for duplication or dead code
- Routing in `routes/` has no unused routes, magic strings, or dead
  redirects
- Naming (files, classes, providers, methods) matches the conventions in
  `coding-standards.md` throughout `lib/`
- No dead code, commented-out blocks, or leftover TODOs remain anywhere
  in `lib/`
- This is the final story — once complete, all 20 stories in
  `implementation-plan.md` are checked off and moved to `ai/completed/`
