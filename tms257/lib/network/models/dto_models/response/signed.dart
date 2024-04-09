import 'dart:convert';

Signed signedFromJson(String str) => Signed.fromJson(json.decode(str));

String signedToJson(Signed data) => json.encode(data.toJson());

class Signed {
  bool signed;

  Signed({
    required this.signed,
  });

  factory Signed.fromJson(Map<String, dynamic> json) => Signed(
        signed: json["signed"],
      );

  Map<String, dynamic> toJson() => {
        "signed": signed,
      };
}
