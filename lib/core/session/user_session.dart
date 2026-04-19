class UserSession {
  UserSession._();

  static String _loggedInEmail = '';

  static String get loggedInEmail => _loggedInEmail;

  static void setLoggedInEmail(String email) {
    _loggedInEmail = email.trim();
  }

  static void clear() {
    _loggedInEmail = '';
  }
}
