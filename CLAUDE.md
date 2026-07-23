# CLAUDE.md

This project's roadmap is driven by `ai/`, not by ad-hoc instructions here.

## Start here

1. Read [ai/project-context.md](ai/project-context.md) — what this app is,
   architecture, domain rules, what NOT to build.
2. Read [ai/coding-standards.md](ai/coding-standards.md) — conventions every
   story must follow.
3. Read [ai/implementation-plan.md](ai/implementation-plan.md) — the ordered
   list of stories and their status.

## Workflow

Work one story at a time, in order:

1. Pick the next unchecked story in `ai/implementation-plan.md` (respecting
   its `Depends On` column).
2. Implement it using that story's file in `ai/stories/0XX-*.md` as the spec
   (Objective, AI Prompt, Acceptance Criteria).
3. Verify the implementation against that story's Acceptance Criteria.
4. Check the story off in `ai/implementation-plan.md` and move its file from
   `ai/stories/` to `ai/completed/`.
5. Stop and report — do not start the next story in the same session unless
   asked to.

Do not skip ahead to a later story before its dependencies are checked off.
Do not implement anything listed under "What NOT to Build" in
`ai/project-context.md`.
