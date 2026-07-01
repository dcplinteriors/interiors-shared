// Phone-number helpers for the supervisor "synthetic email" auth flow.
//
// Supervisors sign in with a phone number + password, but Firebase email/password
// auth runs underneath: the phone is normalized to a canonical 12-digit form and
// mapped to a fake email. These mirror the backend's TypeScript implementation
// exactly — they are the shared contract, so keep the two in sync.

/// Normalizes a raw phone entry to canonical `91XXXXXXXXXX` form (12 digits).
///
/// Strips all non-digit characters, then: a bare 10-digit number gets `91`
/// prepended; a 12-digit number already starting with `91` is kept as-is;
/// anything else is invalid and returns null.
String? normalizePhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 10) return '91$digits';
  if (digits.length == 12 && digits.startsWith('91')) return digits;
  return null;
}

/// Maps a raw phone entry to its synthetic login email, or null when the phone
/// is invalid (see [normalizePhone]).
String? syntheticEmailForPhone(String raw) {
  final n = normalizePhone(raw);
  return n == null ? null : '$n@phone.dcpl-interiors.app';
}

/// Formats a phone for display, e.g. `919876543210` → `+91 98765 43210`.
///
/// Works from any stored/entered form (strips non-digits first). Falls back to
/// returning the input unchanged if it isn't a recognizable 10- or 12-digit number.
String formatPhone(String raw) {
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  final local = digits.length == 12 && digits.startsWith('91')
      ? digits.substring(2)
      : (digits.length == 10 ? digits : null);
  if (local == null) return raw;
  return '+91 ${local.substring(0, 5)} ${local.substring(5)}';
}
