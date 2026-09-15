# 🐱 Mishmish Adoption — مشمش

Mobile-first kitten adoption app: a Flutter frontend (Android + iOS) backed by a Laravel REST API with MySQL. Arabic RTL UI, token authentication (Sanctum), email-OTP password reset, favorites synced per user.

> University final project — Mobile Applications course. This branch (`feature/mobile-cleanup-and-upgrade`) is the cleaned, mobile-only upgrade: desktop/web platforms removed, config centralized, design system + shared widgets added, API layer hardened. No push / merge until reviewed.

## Features

- **Splash** with 3-state routing: Onboarding → Login → Home
- **Onboarding**: 3 pages, persisted via SharedPreferences
- **Auth**: sign up, login (email or username), logout (token revoked + prefs cleared)
- **Password reset**: forgot → 6-digit OTP via Laravel Notification → verify → reset (15-min expiry, resend supported)
- **Home**: kitten grid from the API, pull-to-refresh, Arabic search, breed filter chips
- **Detail**: photo header, breed/age chips, adopt dialog, favorite toggle
- **Favorites**: server-synced list with optimistic toggle + rollback on failure
- **Profile**: cached name/email, about row, logout with confirmation
- **States everywhere**: loading / empty / error + retry on all API screens
- **Custom launcher icon** (Android + iOS) via `flutter_launcher_icons`

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.12+, Dart 3.x (`http`, `shared_preferences`, `flutter_local_notifications`, `flutter_launcher_icons`) |
| Backend | Laravel 13, PHP, Sanctum tokens, Notifications |
| Database | MySQL (migrations + seeders: 12 kittens, demo user) |
| Targets | Android + iOS only |

## Project Structure

```
mishmish_adoption/
├── mishmish/                    # Flutter app (android/ + ios/ only)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/              # app_config.dart, theme.dart (design system)
│   │   ├── models/              # kitten.dart, user.dart
│   │   ├── services/            # api_service.dart, notification_service.dart
│   │   ├── widgets/             # state_views.dart, kitten_image.dart
│   │   └── screens/             # splash, onboarding, auth×5, home×3, favorites, profile
│   ├── assets/icon/             # launcher icon
│   ├── assets/images/cats/      # offline fallback photos (12)
│   ├── android/ ios/            # mobile platforms
│   └── test/                    # widget + unit tests
├── mishmish-api/                # Laravel REST API
│   ├── app/Http/Controllers/Api/# AuthController, KittenController, FavoriteController
│   ├── app/Models/              # User, Kitten, Favorite
│   ├── app/Notifications/       # SendOtpNotification
│   ├── routes/api.php           # 10 endpoints
│   └── database/                # migrations + seeders
├── run.sh                       # backend + adb reverse + flutter launcher
└── متطلبات المشروع...pdf        # course requirements (Arabic)
```

## Architecture

```
┌─────────────┐   HTTP/JSON    ┌──────────────┐   Eloquent   ┌─────────┐
│ Flutter app │ ◄────────────► │ Laravel API  │ ◄──────────► │  MySQL  │
│ (RTL, ar)   │  Sanctum token │ /api/*       │              │         │
└─────────────┘                └──────────────┘              └─────────┘
       │                              │
       │ SharedPreferences            │ Log + Notification
       │ (token/profile/onboarding)   │ (OTP code)
       ▼                              ▼
  on-device cache              system notification
```

**Auth flow:** `register/login → token → Authorization: Bearer` on protected routes (`logout`, `favorites*`). Public: `kittens*`, `forgot/verify/reset-password`.

**Screens flow:** `Splash → (Onboarding?) → Login ⇄ SignUp → Home ⇄ Detail / Favorites / Profile`; `Login → Forgot → Verify → Reset → Login`.

## API Setup (Laravel)

```bash
cd mishmish-api
composer install
# .env:
#   DB_CONNECTION=mysql DB_HOST=127.0.0.1 DB_PORT=3306
#   DB_DATABASE=mishmish DB_USERNAME=root DB_PASSWORD=
php artisan key:generate
php artisan migrate --seed
php artisan serve --host=0.0.0.0 --port=8000
```

Demo account: `user@mishmish.com` / `123456`. OTP codes are logged to `mishmish-api/storage/logs/laravel.log` and also shown as a system notification on the phone (no SMTP required).

Endpoints (`routes/api.php`): `POST register|login|forgot-password|verify-code|reset-password`, `GET kittens|kittens/{id}`, `POST logout`, `GET favorites`, `POST favorites/{kittenId}`.

## Flutter Setup

```bash
cd mishmish
flutter pub get
flutter analyze
flutter test
```

## Environment Configuration

Single source: `mishmish/lib/config/app_config.dart` — `overrideHost` (physical-device LAN IP), `requestTimeout` (10s), SharedPreferences keys. The app auto-uses `10.0.2.2` on Android emulator, `127.0.0.1` on iOS simulator.

## Running the Project

Zero-flag launcher (backend + `adb reverse` + app):

```bash
./run.sh          # start everything
./run.sh status   # backend / adb / flutter status
./run.sh stop     # stop backend, free port 8000
```

Manual: start Laravel first, then `flutter run` from `mishmish/`.

## Android Setup

App ID `com.mishmish.mishmish`, label `مشمش`, `INTERNET` + `POST_NOTIFICATIONS` permissions, launcher icon generated. Release: `flutter build apk` (debug-signed by default; add your keystore for store builds).

## iOS Setup

Display name `مشمش`, `NSAllowsLocalNetworking` set for local `http://` development (no exception needed once the API is HTTPS). Notifications permission requested at startup. Release: `flutter build ipa` (macOS + signing required).

## Testing

```bash
cd mishmish && flutter test          # widget + model + config tests
cd ../mishmish-api && php artisan test  # auth flow feature tests
```

## Build Instructions

```bash
cd mishmish
flutter build apk --release   # Android
flutter build ipa --release   # iOS (macOS only)
```

## Known Limitations

- API served over plain HTTP for local dev (use HTTPS + remove local-network exception in production).
- OTP code is returned in the `forgot-password` JSON response and system notification so evaluation works without SMTP — never ship this to production.
- Auth token lives in SharedPreferences (adequate for coursework; use secure storage for production).
- No pagination on `/kittens` (fine for 12 rows), no deep links, portrait-first layouts.

## Future Improvements

- `flutter_secure_storage` for tokens; stop returning OTP in API responses once SMTP is configured.
- HTTPS production API + remove `NSAllowsLocalNetworking`.
- Adoption-request records + status tracking (currently a confirmation dialog), shelter info, push notifications.
- Pagination/search on the backend, image caching (`cached_network_image`), golden tests.
