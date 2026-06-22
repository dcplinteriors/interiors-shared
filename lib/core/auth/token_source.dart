/// Supplies the bearer token attached to every API request.
///
/// [AuthService] implements this (via Firebase), but the API layer depends only on
/// this interface — keeping the network boundary decoupled from Firebase and unit-testable.
abstract interface class TokenSource {
  /// The current ID token, or null when signed out.
  Future<String?> idToken();
}
