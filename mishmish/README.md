# 🐱 Mishmish — Flutter App (مشمش)

Arabic kitten-adoption frontend (Android + iOS). Part of the monorepo — see the [root README](../README.md) for full setup, API map and architecture.

## What it does

Splash (3s, 3-state routing) → Onboarding (3 pages, persisted) → Auth (Login / Sign-Up / Forgot → OTP → Reset) → Home grid with search + breed filter → Detail (Adopt + Favorite) → Favorites → Profile / Logout. All RTL.

## Stack

- Flutter 3.12+, Dart 3.x
- `http` — single API layer in `lib/services/api_service.dart`
- `shared_preferences` — auth token, profile cache, onboarding flag
- `flutter_local_notifications` — OTP code shown as a system notification (no SMTP needed for evaluation)
- `flutter_launcher_icons` — `assets/icon/cat_icon.png` (Android + iOS)

## Project layout

```
lib/
  main.dart                        # MaterialApp + RTL wrapper (Locale ar)
  config/
    app_config.dart                # base URL, timeouts, prefs keys (single source)
    theme.dart                     # AppColors / AppTextStyles / AppSpacing / AppRadius
  models/
    kitten.dart                    # null-safe fromJson, url resolution
    user.dart
  services/
    api_service.dart               # register/login/logout/forgot/verify/reset/kittens/favorites
    notification_service.dart      # local notifications (Android + iOS init)
  widgets/
    state_views.dart               # LoadingView / EmptyView / ErrorView
    kitten_image.dart              # network → bundled asset → icon fallback
  screens/
    splash_screen.dart             # delay + prefs check → Onboarding/Login/Home
    onboarding/onboarding_screen.dart
    auth/login_screen.dart
    auth/signup_screen.dart
    auth/forgot_password_screen.dart
    auth/verify_code_screen.dart
    auth/reset_password_screen.dart
    home/home_screen.dart          # bottom nav shell (3 tabs)
    home/home_tab.dart             # search + filter + grid
    home/kitten_detail_screen.dart
    favorites/favorites_tab.dart
    profile/profile_tab.dart
```

## Setup

```bash
flutter pub get
```

### Run

| Target | Command | Base URL |
|--------|---------|----------|
| Android emulator | `flutter run` | `http://10.0.2.2:8000/api` (auto-fallback) |
| iOS simulator | `flutter run` | `http://127.0.0.1:8000/api` |
| Physical phone (USB, same Wi-Fi) | `flutter run -d <id>` | `http://<PC_LAN_IP>:8000/api` |

Pointing at a physical device: set your PC's LAN IP once in `lib/config/app_config.dart`:

```dart
static String? overrideHost = '192.168.1.100';
```

Phone + PC must be on the same Wi-Fi and the API must run with `--host=0.0.0.0` (the root `run.sh` does both, including `adb reverse`).

Other commands:

```bash
flutter analyze
flutter test
flutter build apk              # release APK (Android)
flutter build ipa              # release IPA (iOS, macOS only)
dart run flutter_launcher_icons  # regenerate icons after changing assets/icon/cat_icon.png
```

> No web / desktop targets: this app is mobile-only (`android/`, `ios/`).

## Troubleshooting

- Empty grid → `curl http://<API>/api/kittens` should return 12 entries; else `php artisan migrate --seed` in `mishmish-api`.
- Phone cannot connect → check `hostname -I` matches `overrideHost` and `php artisan serve --host=0.0.0.0` is running.
- iOS connection refused on `http://` → `ios/Runner/Info.plist` already allows local networking (`NSAllowsLocalNetworking`); production HTTPS needs no exception.

## Related

- Backend: [`../mishmish-api/README.md`](../mishmish-api/README.md)
- API map: [`../mishmish-api/routes/api.php`](../mishmish-api/routes/api.php)
