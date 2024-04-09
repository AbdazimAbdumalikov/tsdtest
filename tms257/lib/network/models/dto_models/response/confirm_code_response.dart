class ConfirmCodeResponse {
  final bool success;
  final int statusCode;
  final String message;

  ConfirmCodeResponse({
    required this.success,
    required this.statusCode,
    required this.message,
  });

  factory ConfirmCodeResponse.fromJson(Map<String, dynamic> json) {
    return ConfirmCodeResponse(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }
}
