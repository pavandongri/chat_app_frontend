# UI/UX Redesign Brief (Phase 2)

Source brief driving `ai/stories/021-*.md` through `031-*.md`. This is the
original ask, kept verbatim for reference — the implementation detail lives
in the individual story files, not here.

We're building this app with **WhatsApp as the primary inspiration**, but we
don't want to copy it exactly. The goal is to create a **modern, premium,
production-ready chat application** that feels familiar to WhatsApp while
having its own polished identity.

## 1. Theme & Color System

* WhatsApp-inspired color palette (teal/green primary colors).
* Centralized theme system — every color (primary, secondary, background,
  text, borders, icons, buttons, cards, etc.) comes from the centralized
  theme, not hardcoded.
* Single source of truth: changing the primary color in one file updates
  the entire application.
* Supports light theme, dark theme, and easy future customization.

## 2. Premium UI

The app should feel modern and premium. Wherever appropriate, use:

* Glassmorphism (glass background effects)
* Soft shadows
* Smooth rounded corners
* Modern cards
* Elegant spacing
* Subtle gradients
* Clean typography
* Smooth animations
* Beautiful transitions

Especially apply these effects to: Sign In, Sign Up, authentication screens,
dialogs, cards, profile screen, and other places where it improves the UI
without affecting usability.

## 3. Home Screen Redesign

Bottom Navigation Bar with 4 tabs, WhatsApp-style:

1. **Chats** (default) — friends sorted by recent conversation, each row
   showing profile picture, name, last message, timestamp, unread count.
   Tapping a friend opens the chat screen.
2. **Friend Requests** — incoming requests with Accept/Reject; beautiful
   empty state if none.
3. **Friend Search** — search bar on top, list of non-friend users below
   (profile picture, name, username, mutual friends optional, Send Friend
   Request button), filters instantly.
4. **Profile** — profile picture, name, username, bio (future-ready), email,
   Edit Profile, Settings, Logout — premium look.

## 4. Overall Design Language

WhatsApp-inspired layout, clean, minimalistic, modern, consistent spacing,
responsive, smooth animations, beautiful loading states, elegant empty
states, premium appearance, industry-standard UI/UX.

## 5. Code Quality

* Clean code, Flutter best practices, reusable widgets, scalable, no
  duplicated UI code.
* Reusable components for: buttons, text fields, cards, list tiles, app
  bars, bottom navigation, dialogs, loading widgets, empty state widgets.

## 6. Important

Redesign the UI while preserving existing functionality — do not break any
existing features unless absolutely necessary. Focus on better UX, visual
hierarchy, consistency, maintainability, and future scalability.
