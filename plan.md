# 🐱 Mishmish — مشمش — Simplified Plan

## What We're Building
Arabic kitten store app. Users browse kittens, save favorites, have a profile. That's it.

## Stack
- **Flutter** → http, shared_preferences, flutter_launcher_icons
- **Laravel** → simple REST API, no heavy auth
- **MySQL** → 3 tables

## Database (3 tables only)

```sql
users (id, name, email, password, created_at)
kittens (id, name, breed, age, description, price, image_url, created_at)
favorites (id, user_id, kitten_id, created_at)
```

## API Endpoints (minimal)

| Method | Endpoint | What it does |
|--------|----------|-------------|
| POST | /api/register | Create account |
| POST | /api/login | Login, return token |
| POST | /api/logout | Logout |
| POST | /api/forgot-password | Send OTP email |
| POST | /api/verify-code | Check OTP |
| POST | /api/reset-password | New password |
| GET | /api/kittens | All kittens |
| GET | /api/kittens/{id} | One kitten |
| GET | /api/favorites | My favorites |
| POST | /api/favorites/{id} | Toggle favorite |

## Screens (Flutter)

1. **Splash** → 3s delay → check SharedPreferences
2. **Onboarding** → 3 pages → save done state
3. **Login** → email + password
4. **SignUp** → name + email + password
5. **Forgot Password** → email → OTP screen → reset screen
6. **Home** → grid of kittens from API
7. **Kitten Detail** → image + info + adopt button
8. **Favorites** → saved kittens
9. **Profile** → name + email + logout

## Implementation Order

### Phase 1: Laravel Backend
- Create project, setup MySQL, run migrations
- Auth endpoints (register, login, logout)
- Password reset (forgot → OTP → reset)
- Kittens + Favorites endpoints
- Seed 10 kitten entries

### Phase 2: Flutter Setup
- Create project, add packages
- Folder structure
- Theme + Arabic fonts

### Phase 3: Splash + Onboarding
- Splash with delay + SharedPreferences check
- 3-page onboarding with "ابدأ الآن" button

### Phase 4: Auth Screens
- Login, SignUp, Forgot Password, Verify Code, Reset Password
- Connect to Laravel API

### Phase 5: Main App
- Bottom nav (Home, Favorites, Profile)
- Kitten grid + detail screen
- Favorites toggle
- Logout

## Arabic UI
- All text Arabic
- RTL layout
- Cairo font
- RTL-friendly design

## Done.
