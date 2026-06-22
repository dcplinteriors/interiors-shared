/// A user — the authenticated caller's profile (`GET /me`) or a supervisor record
/// (`GET /supervisors`). `role` is `'admin'` or `'supervisor'`.
///
/// `photoUrl` is the supervisor's profile-image object path (resolved to a signed URL on demand).
/// `workOrders` (assigned work-order names) is present only in the supervisor list response.
class User {
  const User({
    required this.uid,
    required this.role,
    required this.name,
    this.email,
    this.phone,
    this.photoUrl,
    this.isActive,
    this.createdAt,
    this.workOrders = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    uid: json['uid'] as String,
    role: json['role'] as String,
    name: json['name'] as String? ?? '',
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    photoUrl: json['photoUrl'] as String?,
    isActive: json['isActive'] as bool?,
    createdAt: json['createdAt'] as String?,
    workOrders:
        (json['workOrders'] as List?)?.map((e) => e as String).toList() ??
        const [],
  );

  final String uid;
  final String role; // 'admin' | 'supervisor'
  final String name;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final bool? isActive;
  final String? createdAt;

  /// Names of the work orders currently assigned to this supervisor (supervisor list only).
  final List<String> workOrders;

  bool get isAdmin => role == 'admin';
  bool get isSupervisor => role == 'supervisor';
}
