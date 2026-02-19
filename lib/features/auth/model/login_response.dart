class LoginResponse {
  final bool status;
  final String message;

  const LoginResponse({required this.status, required this.message});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }
}
