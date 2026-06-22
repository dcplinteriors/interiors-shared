import 'package:flutter/foundation.dart' show kDebugMode;

/// App-wide configuration shared by the Admin and User apps.
///
/// API base URL resolution (first match wins):
///   1. `--dart-define=API_BASE_URL=https://...` — explicit override, else
///   2. **debug** builds  → local backend (`flutter run`), else
///   3. **profile/release** builds → deployed backend (Render).
///
/// So `flutter run` talks to your local server, while `flutter build` (web/apk/…)
/// ships pointing at production — with `--dart-define` still able to override both.
class AppConfig {
  static const String _localBaseUrl = 'http://localhost:8080/api';
  static const String _prodBaseUrl =
      'https://interiors-backend.onrender.com/api';

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kDebugMode ? _localBaseUrl : _prodBaseUrl,
  );
}
