class OrderCheck {
  bool? success;
  int? statusCode;
  String? message;
  Data? data;

  OrderCheck({this.success, this.statusCode, this.message, this.data});

  OrderCheck.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  bool? complete;

  Data({this.complete});

  Data.fromJson(Map<String, dynamic> json) {
    complete = json['complete'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['complete'] = this.complete;
    return data;
  }
}
