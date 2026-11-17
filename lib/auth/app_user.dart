/// Role names stored in Firestore: users/{uid}.role
class UserRole {
  static const guest = 'guest'; // not stored, means "not logged in"
  static const individual = 'individual';
  static const employer = 'employer';
  static const trainer = 'trainer';
  static const admin = 'admin';
}

class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final Map<String, dynamic> extra;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.extra = const {},
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: (data['name'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      role: (data['role'] ?? UserRole.individual) as String,
      extra: data,
    );
  }
}
