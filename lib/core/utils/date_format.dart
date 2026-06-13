import 'package:intl/intl.dart';

/// Formats an ISO date (`yyyy-MM-dd` or full ISO timestamp) as e.g. `07 Jun 2026`.
/// Falls back to the raw string when it can't be parsed.
String formatDate(String iso) {
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}
