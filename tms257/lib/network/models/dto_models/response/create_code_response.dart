class CreateCodeResponse {
  final bool success;
  final int statusCode;
  final String message;
  final int code;

  CreateCodeResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    required this.code,
  });

  factory CreateCodeResponse.fromJson(Map<String, dynamic> json) {
    return CreateCodeResponse(
      success: json['success'],
      statusCode: json['statusCode'],
      message: json['message'],
      code: json['data']['code'],
    );
  }
}
