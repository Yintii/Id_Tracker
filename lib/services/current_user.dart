class CurrentUser {
  static final CurrentUser _instance = CurrentUser._internal();

  factory CurrentUser() {
    return _instance;
  }

  CurrentUser._internal();

  late String token;
  late int userId;
  late String email;
  late String role;

  bool get isLoggedIn => token.isNotEmpty;

  void setUser({
    required String jwtToken,
    required int id,
    required String userEmail,
    required String userRole,
  }) {
    token = jwtToken;
    userId = id;
    email = userEmail;
    role = userRole;
  }

  void clear() {
    token = '';
    userId = -1;
    email = '';
    role = '';
  }
}
