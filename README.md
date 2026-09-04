# 🐱 Mishmish — مشمش

> Arabic kitten adoption app. Browse kittens, save favorites, manage your profile.  
> Built as a final term project for Mobile Applications.

**Stack:** Flutter (Arabic RTL) + Laravel 13 REST API + SQLite + React showcase.

[![Flutter](https://img.shields.io/badge/Flutter-3.12-blue?logo=flutter)](https://flutter.dev)
[![Laravel](https://img.shields.io/badge/Laravel-13-red?logo=laravel)](https://laravel.com)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![PHP](https://img.shields.io/badge/PHP-8.5-777BB4?logo=php)](https://php.net)

> **Showcase:** open [`showcase/index.html`](showcase/index.html) or run `npm run dev` inside [`showcase/`](showcase/) for an interactive code + API tour (Arabic).

---

## 📸 What it looks like

- **Splash** → 3s → checks `SharedPreferences` (`onboarding_done` / `auth_token`)
- **Onboarding** → 3-page `PageView` (Arabic) → save state
- **Auth** → Login / Sign-Up / Forgot → OTP (6-digit) → Reset
- **Home** → 2-column grid from `GET /api/kittens` → Detail with Adopt + Favorite toggle
- **Favorites** → `GET /api/favorites` (auth required)
- **Profile** → name/email + Logout

All UI is RTL (`Directionality` + `Locale('ar')`) with `Cairo` font and `AppTheme` (`lib/config/theme.dart:1`).

---

## 🏗️ Architecture

| Layer | Tech | Notes |
|-------|------|-------|
| Mobile / Web | **Flutter** | `http`, `shared_preferences`, `flutter_launcher_icons` (`mishmish/pubspec.yaml:1`) |
| Backend | **Laravel 13** | Sanctum tokens, SQLite, 6 migrations, 2 seeders |
| Showcase | **React + Vite** | Interactive docs at `showcase/src` |
| Auth | Sanctum Bearer tokens | `Authorization: Bearer <token>` |
| Storage | `SharedPreferences` | `auth_token`, `user_name`, `user_email`, `onboarding_done` |

---

## 📁 Project structure

```
final_projectV2/
├── mishmish/          # Flutter app (mobile + web)
│   ├── lib/
│   │   ├── main.dart              # RTL wrapper + theme
│   │   ├── config/theme.dart
│   │   ├── models/kitten.dart, user.dart
│   │   ├── services/api_service.dart  # ← single API entry (see Run section)
│   │   └── screens/
│   │       ├── splash_screen.dart
│   │       ├── onboarding/
│   │       ├── auth/ (login, signup, forgot, verify, reset)
│   │       ├── home/ (home_tab + kitten_detail)
│   │       ├── favorites/
│   │       └── profile/
│   ├── assets/icon/cat_icon.png
│   ├── pubspec.yaml
│   └── web/
├── mishmish-api/            # Laravel REST API
│   ├── routes/api.php             # 10 endpoints (5 public + 5 auth)
│   ├── app/Http/Controllers/Api/ (AuthController, KittenController, FavoriteController)
│   ├── config/cors.php            # allows web + phone origins
│   ├── database/migrations/ (6)
│   ├── database/seeders/KittenSeeder.php (12 kittens, Arabic, cataas.com images)
│   └── .env                       # DB_CONNECTION=sqlite
├── showcase/              # React + Vite interactive showcase
│   ├── index.html
│   ├── src/
│   └── vite.config.js
├── plan.md                # Original minimal plan (Arabic)
└── README.md              # ← you are here
```

---

## 🚀 Quick start

### Prerequisites

```bash
flutter --version   # 3.12+
php -v              # 8.5
composer -V
node -v             # for showcase (optional)
adb --version       # for physical device
```

### 1) Backend — Laravel API

```bash
cd mishmish-api
composer install
cp .env.example .env        # or use existing .env (sqlite already configured)
php artisan key:generate
php artisan migrate --seed  # creates DB + 12 kittens (re-run with --seed if empty)
php artisan serve --host=0.0.0.0 --port=8000
# → http://127.0.0.1:8000  and http://<LAN_IP>:8000 for phones
```

`GET /api/kittens` is public — hit `http://127.0.0.1:8000/api/kittens` to verify (should return 12 entries).

### 2) Frontend — Flutter

```bash
cd mishmish
flutter pub get
```

**Pick one target:**

| Target | Command | Base URL needed (`lib/services/api_service.dart:6`) |
|--------|---------|------------------------------------------------------|
| **Web (Chrome)** | `flutter run -d chrome` | `http://127.0.0.1:8000/api` (or `kIsWeb` branch — already configured ✅) |
| **Android emulator** | `flutter run -d emulator` | `http://10.0.2.2:8000/api` |
| **Physical phone (USB)** | `flutter run -d <deviceId>` | `http://<YOUR_PC_LAN_IP>:8000/api` |

Current code auto-switches:

```dart
// lib/services/api_service.dart:6
static String get baseUrl {
  if (kIsWeb) return 'http://127.0.0.1:8000/api';
  return 'http://125.31.81.253:8000/api'; // ← replace with your `hostname -I` / `ipconfig`
}
```

Find your LAN IP:

```bash
hostname -I          # Linux
ipconfig             # Windows (look for IPv4)
ipconfig getifaddr en0  # macOS
```

Phone and PC must be on the **same Wi-Fi**. Keep the API running with `--host=0.0.0.0` so the phone can reach it.

### 3) Showcase (optional)

```bash
cd showcase
npm install
npm run dev
```

Interactive map of every `lib/*.dart` file and API endpoint.

---

## 🔌 API (see `mishmish-api/routes/api.php:1`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/register` | public | `{name, email, password, password_confirmation}` → 201 + token |
| POST | `/api/login` | public | `{email, password}` → token |
| POST | `/api/logout` | Bearer | delete token |
| POST | `/api/forgot-password` | public | `{email}` → `{code}` (demo: code returned) |
| POST | `/api/verify-code` | public | `{email, code}` |
| POST | `/api/reset-password` | public | `{email, password}` |
| GET | `/api/kittens` | public | `Kitten[]` (12 seeded) |
| GET | `/api/kittens/{id}` | public | single |
| GET | `/api/favorites` | Bearer | user's favorites |
| POST | `/api/favorites/{kittenId}` | Bearer | toggle → `{is_favorite}` |

Auth uses `auth:sanctum` + Bearer tokens stored in `SharedPreferences`.

CORS is open (`mishmish-api/config/cors.php:1` → `allowed_origins: *`) so web and phone both work. Change to your domain for production.

**DB:** SQLite (`database/database.sqlite`), 3 tables (`users`, `kittens`, `favorites`) + `password_reset_tokens`. Switch to MySQL by editing `mishmish-api/.env`.

---

## 🎨 Theming & i18n

- `lib/config/theme.dart` — primary palette, Cairo font
- `MaterialApp(locale: Locale('ar'), builder: Directionality rtl)` (`lib/main.dart:15`)
- All strings Arabic — validators throw `'حدث خطأ'` on API errors (`lib/services/api_service.dart:121`)

---

## 🧪 Verify

```bash
cd mishmish-api && php artisan test
cd mishmish && flutter analyze
cd mishmish && flutter test
curl http://127.0.0.1:8000/api/kittens | jq .
```

---

## 🐛 Common issues

- **Phone shows empty / connection error** → API not reachable: check same Wi-Fi, `hostname -I` matches `baseUrl`, and `php artisan serve --host=0.0.0.0`.
- **Web blocked by CORS** → ensure `mishmish-api/config/cors.php` exists and `HandleCors` middleware is in default stack (Laravel 13 includes it).
- **Emulator not reaching API** → use `10.0.2.2` not `127.0.0.1`.
- **No kittens** → `php artisan migrate --seed` (seeder creates 12 via `cataas.com` images).

---

## 📄 Docs & requirements

- `plan.md` — minimal build plan (Arabic)
- `متطلبات المشروع النهائي المخفف لمادة تطبيقات الموبايل.pdf` — original spec (Arabic)
- `mishmish/README.md` — Flutter-only setup
- `mishmish-api/README.md` — Laravel-only setup
- `showcase/README.md` — React showcase setup

---

## 👥 Team / Contributions

- Fork → feature branch → PR. Keep Arabic UI + RTL.
- Run `flutter analyze` + `php artisan test` before pushing.
- Add screenshots to `showcase/public/` if you change screens.

## 📝 License

MIT — do what you want, credit appreciated.

---

*Built with ❤️ — `مشمش`*
