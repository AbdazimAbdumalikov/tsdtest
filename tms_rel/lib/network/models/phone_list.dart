class PhoneList {
  Data? data;

  PhoneList({this.data});

  factory PhoneList.fromJson(Map<String, dynamic> json) {
    return PhoneList(
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  @override
  String toString() {
    return 'PhoneList(data: $data)';
  }
}

class Data {
  int? employeeId;
  List<String>? phones;

  Data({this.employeeId, this.phones});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      employeeId: json['employee_id'],
      phones: json['phones'] != null ? List<String>.from(json['phones']) : [],
    );
  }

  @override
  String toString() {
    return 'Data(employeeId: $employeeId, phones: $phones)';
  }
}
