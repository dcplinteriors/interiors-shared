/// App-wide configuration. Override the API base URL at build time with
/// `--dart-define=API_BASE_URL=https://...`.
class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api',
  );
}
