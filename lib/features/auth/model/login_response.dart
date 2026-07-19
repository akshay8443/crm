class LoginResponse {
  final bool status;
  final String message;
  final String userId;
  final String firstName;
  final String lastName;
  final String email;
  final bool canAccessPurchaseRequest;
  final bool canAccessInventoryTransfer;
  final bool canAccessServiceCall;
  final bool canAccessApDownPayment;
  final bool canAccessGoodsIssue;
  final bool isReadOnly;

  const LoginResponse({
    required this.status,
    required this.message,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.canAccessPurchaseRequest,
    required this.canAccessInventoryTransfer,
    required this.canAccessServiceCall,
    required this.canAccessApDownPayment,
    required this.canAccessGoodsIssue,
    required this.isReadOnly,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      userId: (json['UserId'] ?? '').toString(),
      firstName: (json['FirstName'] ?? '').toString(),
      lastName: (json['LastName'] ?? '').toString(),
      email: (json['Email'] ?? '').toString(),
      canAccessPurchaseRequest: _isYes(json['PurchaseRequest']),
      canAccessInventoryTransfer: _isYes(json['InventoryTransfer']),
      canAccessServiceCall: _isYes(json['ServiceCall']),
      canAccessApDownPayment: _isYes(json['APDownPayment']),
      canAccessGoodsIssue: _isYes(json['GoodsIssue']),
      isReadOnly: _isYes(json['ReadOnly']),
    );
  }

  static bool _isYes(Object? value) => value.toString().trim().toUpperCase() == 'Y';
}
