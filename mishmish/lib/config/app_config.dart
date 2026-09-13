/// Centralized environment + API configuration.
///
/// All tunables that were previously scattered (base URL, timeouts,
/// SharedPreferences keys) live here so screens and services never
/// hardcode them.
class AppConfig {
  AppConfig._();

  /// LAN host of the Laravel server for physical-device testing.
  /// Set to your computer's Wi-Fi IP when testing on a real phone,
  /// e.g. `overrideHost = '192.168.1.100'`. Leave null for
  /// emulator / simulator defaults.
  static String? overrideHost;

  /// Active host, auto-switched to the Android-emulator alias
  /// (`10.0.2.2`) on first connection failure.
  static String activeHost = '127.0.0.1';

  static const int apiPort = 8000;

  static String get baseUrl {
    final host = (overrideHost != null && overrideHost!.isNotEmpty)
        ? overrideHost!
        : activeHost;
    return 'http://$host:$apiPort/api';
  }

  /// Host part without the `/api` suffix, used to resolve
  /// relative image paths returned by the backend.
  static String get serverRoot => baseUrl.replaceAll('/api', '');

  static const Duration requestTimeout = Duration(seconds: 10);

  // SharedPreferences keys.
  static const String keyAuthToken = 'auth_token';
  static const String keyUserName = 'user_name';
  static const String keyUserEmail = 'user_email';
  static const String keyOnboardingDone = 'onboarding_done';
}
