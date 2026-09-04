# 🐱 Mishmish — Flutter App (مشمش)

Arabic kitten adoption frontend. Part of [`final_projectV2`](../README.md) — see root README for full setup.

## What it does

Splash (3s) → Onboarding (3 pages) → Auth (Login / Sign-Up / Forgot → OTP → Reset) → Home grid (12 kittens) → Detail (Adopt + Favorite) → Favorites → Profile/Logout. All RTL/Cairo.

## Stack

- Flutter 3.12+, Dart 3.x
- `http` 1.2 — `lib/services/api_service.dart:1` (single API layer)
- `shared_preferences` 2.2 — tokens + onboarding flag
- `flutter_launcher_icons` — `assets/icon/cat_icon.png`

## Project layout

```
lib/
  main.dart                 # MaterialApp + RTL wrapper (Locale ar)
  config/theme.dart         # Theme + Cairo
  models/kitten.dart, user.dart
  services/api_service.dart # register/login/forgot/verify/reset/getKittens/toggleFavorite
  screens/
    splash_screen.dart      # delay + prefs check
    onboarding/onboarding_screen.dart
    auth/{login,signup,forgot,verify,reset}_screen.dart
    home/{home_tab,kitten_detail_screen}.dart
    favorites/favorites_tab.dart
    profile/profile_tab.dart
```

## Setup

```bash
flutter pub get
```

### Run

| Target | Command | Base URL note |
|--------|---------|---------------|
| Web | `flutter run -d chrome` | `http://127.0.0.1:8000/api` |
| Emulator | `flutter run -d emulator` | `http://10.0.2.2:8000/api` |
| Phone (USB) | `flutter run -d <id>` (see `flutter devices`) | `http://<PC_LAN_IP>:8000/api` |

Current `lib/services/api_service.dart:6` auto-switches:

```dart
static String get baseUrl {
  if (kIsWeb) return 'http://127.0.0.1:8000/api';
  return 'http://125.31.81.253:8000/api'; // replace with your `hostname -I` / `ipconfig`
}
```

Phone + PC must be on same Wi-Fi and API must run with `--host=0.0.0.0`.

Other commands:

```bash
flutter analyze
flutter test
flutter build apk        # release APK
flutter build web        # static web bundle in build/web
flutter launcher-icons   # regenerate icons after changing assets/icon/cat_icon.png
```

## Troubleshooting

- Empty grid → `curl http://<API>/api/kittens` should return 12 entries; else `php artisan migrate --seed` in `mishmish-api`.
- Phone cannot connect → check `hostname -I` matches `baseUrl` and `php artisan serve --host=0.0.0.0`.
- Web CORS error → ensure `mishmish-api/config/cors.php` exists (root README explains).

## Related

- Backend: [`../mishmish-api/README.md`](../mishmish-api/README.md)
- Showcase: [`../showcase/README.md`](../showcase/README.md)
- API map: [`../mishmish-api/routes/api.php`](../mishmish-api/routes/api.php)
