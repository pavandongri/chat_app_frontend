# Implementation Plan — Phase 1

Ordered roadmap. Each row links to its full story file in `ai/stories/`.
Work top to bottom — later stories assume earlier ones are done (e.g. chat
screens assume auth + friends exist), and assume the corresponding backend
story (see `../backend/ai/implementation-plan.md`) is already implemented.

| #  | Story                          | File                                                                 | Depends On |
| -- | ------------------------------- | --------------------------------------------------------------------- | ---------- |
| 1  | Flutter Project Foundation      | [001-project-foundation.md](stories/001-project-foundation.md)         | —          |
| 2  | Theme System                    | [002-theme-system.md](stories/002-theme-system.md)                     | 1          |
| 3  | Authentication UI               | [003-authentication-ui.md](stories/003-authentication-ui.md)           | 1, 2       |
| 4  | Authentication API Integration  | [004-authentication-api.md](stories/004-authentication-api.md)         | 3          |
| 5  | Home Screen                     | [005-home-screen.md](stories/005-home-screen.md)                       | 4          |
| 6  | Profile                         | [006-profile.md](stories/006-profile.md)                               | 4, 5       |
| 7  | Search Friends                  | [007-search-friends.md](stories/007-search-friends.md)                 | 4, 5       |
| 8  | Friend Requests                 | [008-friend-requests.md](stories/008-friend-requests.md)               | 7          |
| 9  | Friends List                    | [009-friends-list.md](stories/009-friends-list.md)                     | 8          |
| 10 | Chat List                       | [010-chat-list.md](stories/010-chat-list.md)                           | 9          |
| 11 | Chat Screen                     | [011-chat-screen.md](stories/011-chat-screen.md)                       | 10         |
| 12 | Message API Integration         | [012-message-api-integration.md](stories/012-message-api-integration.md) | 11         |
| 13 | Edit Message                    | [013-edit-message.md](stories/013-edit-message.md)                     | 12         |
| 14 | Delete Message                  | [014-delete-message.md](stories/014-delete-message.md)                 | 12         |
| 15 | Online Status                   | [015-online-status.md](stories/015-online-status.md)                   | 9, 12      |
| 16 | Refresh Mechanism               | [016-refresh-mechanism.md](stories/016-refresh-mechanism.md)           | 12, 15     |
| 17 | Loading, Empty & Error States   | [017-loading-empty-error-states.md](stories/017-loading-empty-error-states.md) | 3–16 |
| 18 | Responsive Design               | [018-responsive-design.md](stories/018-responsive-design.md)           | 3–17       |
| 19 | App Polish                       | [019-app-polish.md](stories/019-app-polish.md)                         | 18         |
| 20 | Production Cleanup              | [020-production-cleanup.md](stories/020-production-cleanup.md)         | all        |

## Workflow

1. Pick the next unstarted story (top to bottom, respecting dependencies).
2. Read [project-context.md](project-context.md) and
   [coding-standards.md](coding-standards.md) if starting a fresh session.
3. Hand the story's AI Prompt to the assistant implementing it, or
   implement it directly following that spec.
4. Verify against the story's Acceptance Criteria.
5. Move the story file from `ai/stories/` to `ai/completed/` once merged.
6. Update the checkbox below.

## Status

- [x] 1 — Flutter Project Foundation
- [x] 2 — Theme System
- [x] 3 — Authentication UI
- [x] 4 — Authentication API Integration
- [x] 5 — Home Screen
- [x] 6 — Profile
- [x] 7 — Search Friends
- [x] 8 — Friend Requests
- [x] 9 — Friends List
- [x] 10 — Chat List
- [x] 11 — Chat Screen
- [x] 12 — Message API Integration
- [x] 13 — Edit Message
- [x] 14 — Delete Message
- [x] 15 — Online Status
- [ ] 16 — Refresh Mechanism
- [ ] 17 — Loading, Empty & Error States
- [ ] 18 — Responsive Design
- [ ] 19 — App Polish
- [ ] 20 — Production Cleanup
