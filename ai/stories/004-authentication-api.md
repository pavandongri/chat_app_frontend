# Story 4 – Authentication API Integration

## Objective

Connect Auth UI to backend.

## AI Prompt

```text
Integrate authentication APIs.

Signup

Verify OTP

Resend OTP

Login

Forgot Password

Reset Password

Store JWT using flutter_secure_storage.

Create AuthRepository.

Create AuthProvider.

Handle loading states.

Handle API errors.

Handle token persistence.
```

## Acceptance Criteria

- Signup, Verify OTP, Resend OTP, Login, Forgot Password, and Reset
  Password all call the real backend endpoints via `AuthRepository`
- JWT is persisted in `flutter_secure_storage` on login/signup success and
  cleared on logout
- App restores session from stored JWT on cold start (no forced re-login)
- `AuthProvider` exposes loading/success/error state consumed by Story 3's
  screens without further UI changes
- API/network errors surface through the shared error widgets/snackbars,
  never as an unhandled exception
