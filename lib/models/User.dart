import 'dart:convert';

import 'package:ccchat/models/PrivateKeyString.dart';
import 'package:pointycastle/asymmetric/api.dart';

class ChatUser {
  String id = "";
  String? name;
  String? email;
  String? type;
  String? career;
  String? departament;
  bool emailVerified = false;
  List<dynamic>? subject;
  RSAPublicKey? publicKey;
  PrivateKeyString? privateKey;

  ChatUser.builderWithID(
    this.id,
    this.name,
    this.email,
    this.type,
  );

  ChatUser.builderWithoutID(
    this.name,
    this.email,
    this.type,
  );

  ChatUser.builderEmpty();

  ///Method that convert a string to JSON
  factory ChatUser.fromRawJson(String str) => ChatUser.fromJson(json.decode(str));

  ///Method that converts the User's data into a character string in JSON format
  String toRawJson() => json.encode(toJson());

  ///Method that assigns the JSON value to each User's attribute
  ///JSON -> User
  ChatUser.fromJson(Map<String, dynamic> json) {
    id = json['id']!;
    name = json["name"];
    email = json["email"];
    type = json["type"];
    career = json["career"];
    departament = json["departament"];
    emailVerified = json["emailVerified"];
    subject = json["subject"];
    publicKey = RSAPublicKey(
      BigInt.parse(json["publicKeyModulus"]), 
      BigInt.parse(json["publicKeyExponent"])
    );
    privateKey = PrivateKeyString(
      modulus: json["privateKeyModulus"], 
      privateExponent: json["privateKeyPrivateExponent"], 
      p: json["privateKeyP"], 
      q: json["privateKeyQ"]
    );
  }

  ///Method that converts the User's data into JSON
  ///User -> JSON
  Map<String, dynamic> toJson() {
    return {
        'id' : id,
        'name' : name,
        'email' : email,
        'type' : type,
        'career' : career,
        'departament' : departament,
        'emailVerified' : emailVerified,
        'subject' : subject,
        'publicKeyModulus' : publicKey!.modulus, 
        'publicKeyExponent' : publicKey!.exponent,
        'privateKeyModulus' : privateKey!.modulus,
        'privateKeyPrivateExponent' : privateKey!.privateExponent,
        'privateKeyP' : privateKey!.p, 
        'privateKeyQ': privateKey!.q,
      };
  }

}
