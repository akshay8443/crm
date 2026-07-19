import '../../features/auth/model/login_response.dart';

class UserSession {
  UserSession._();

  static String _loggedInEmail = '';
  static String _userId = '';
  static String _firstName = '';
  static String _lastName = '';
  static bool _canAccessPurchaseRequest = false;
  static bool _canAccessInventoryTransfer = false;
  static bool _canAccessServiceCall = false;
  static bool _canAccessApDownPayment = false;
  static bool _canAccessGoodsIssue = false;
  static bool _isReadOnly = false;

  static String get loggedInEmail => _loggedInEmail;
  static String get userId => _userId;
  static String get firstName => _firstName;
  static String get lastName => _lastName;
  static bool get canAccessPurchaseRequest => _canAccessPurchaseRequest;
  static bool get canAccessInventoryTransfer => _canAccessInventoryTransfer;
  static bool get canAccessServiceCall => _canAccessServiceCall;
  static bool get canAccessApDownPayment => _canAccessApDownPayment;
  static bool get canAccessGoodsIssue => _canAccessGoodsIssue;
  static bool get isReadOnly => _isReadOnly;

  static void setLoggedInEmail(String email) {
    _loggedInEmail = email.trim();
  }

  static void setLoginResponse(LoginResponse response, {String fallbackEmail = ''}) {
    _loggedInEmail = response.email.trim().isNotEmpty
        ? response.email.trim()
        : fallbackEmail.trim();
    _userId = response.userId.trim();
    _firstName = response.firstName.trim();
    _lastName = response.lastName.trim();
    _canAccessPurchaseRequest = response.canAccessPurchaseRequest;
    _canAccessInventoryTransfer = response.canAccessInventoryTransfer;
    _canAccessServiceCall = response.canAccessServiceCall;
    _canAccessApDownPayment = response.canAccessApDownPayment;
    _canAccessGoodsIssue = response.canAccessGoodsIssue;
    _isReadOnly = response.isReadOnly;
  }

  static void clear() {
    _loggedInEmail = '';
    _userId = '';
    _firstName = '';
    _lastName = '';
    _canAccessPurchaseRequest = false;
    _canAccessInventoryTransfer = false;
    _canAccessServiceCall = false;
    _canAccessApDownPayment = false;
    _canAccessGoodsIssue = false;
    _isReadOnly = false;
  }
}
