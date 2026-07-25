# Story 30 – Micro-Interactions & Transition Polish

## Objective

Add the final layer of purposeful motion across the whole app: page
transitions, tab switches, button feedback, and list entrance animations,
consistently.

## AI Prompt

```text
Pass over the whole app (auth, home shell tabs, chat screen, profile,
friends) and normalize motion:

- go_router page transitions: consistent, subtle, same curve/duration
  everywhere
- Bottom nav tab switch: smooth, consistent with the shell built in
  Story 23
- Button press feedback: consistent ripple/scale across AppButton usages
- List item entrance (chats, friend requests, search results): subtle
  stagger/fade-in on initial load only, not on every rebuild
- Pull-to-refresh indicator styled with theme tokens

Requirements

- No decorative or looping animations — every animation must be tied to a
  real user action or state transition (per coding-standards.md)
- No new dependencies beyond what's already used unless clearly justified
- No functional/behavior changes anywhere — visual/motion polish only
```

## Acceptance Criteria

- Page transitions are visually consistent across every route
- Tab switching in the bottom nav shell (Story 23) has a smooth, consistent
  transition
- Button press feedback is consistent across every AppButton usage
- List entrance animations run once on initial load, not on every
  rebuild/refresh, and are subtle
- No looping/decorative animation exists anywhere in the app
- No behavior change to any screen — this is a pure motion/polish pass
