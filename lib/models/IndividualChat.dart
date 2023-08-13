import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualChat {
  String id = "";
  String? nameU1;
  String? nameU2;
  Uint8List? imageU1;
  Uint8List? imageU2;
  String? typeU1;
  String? typeU2;
  String? keyU1;
  String? keyU2;
  String? lastMessage;
  Timestamp? hour;
  List<dynamic>? members;

  IndividualChat.builderWithID(
    this.id,
    this.nameU1,
    this.nameU2,
    this.typeU1,
    this.typeU2,
    this.keyU1,
    this.keyU2,
    this.lastMessage,
    this.hour,
    this.members,
  );

  IndividualChat.builderWithoutID(
    this.nameU1,
    this.nameU2,
    this.typeU1,
    this.typeU2,
    this.keyU1,
    this.keyU2,
    this.lastMessage,
    this.hour,
    this.members,
  );

  IndividualChat.builderEmpty();

  ///Method that convert a string to JSON
  factory IndividualChat.fromRawJson(String str) => IndividualChat.fromJson(json.decode(str));

  ///Method that converts the Individual Chat's data into a character string in JSON format
  String toRawJson() => json.encode(toJson());

  ///Method that assigns the JSON value to each Individual Chat's attribute
  ///JSON -> Individual Chat
  IndividualChat.fromJson(Map<String, dynamic> json) {
    id = json['id']!;
    nameU1 = json["nameU1"];
    nameU2 = json["nameU2"];
    imageU1 = json["imageU1"] != null ? base64Decode(json["imageU1"]) : null;
    imageU2 = json["imageU2"] != null ? base64Decode(json["imageU2"]) : null;
    typeU1 = json["typeU1"];
    typeU2 = json["typeU2"];
    keyU1 = json["keyU1"];
    keyU2 = json["keyU2"];
    lastMessage = json["lastMessage"];
    hour = json["hour"];
    members = json["members"];
  }

  ///Method that converts the Individual Chat's data into JSON
  ///Individual Chat -> JSON
  Map<String, dynamic> toJson() {
    return {
        'id' : id,
        'nameU1' : nameU1,
        'nameU2' : nameU2,
        'imageU1' : imageU1 != null ? base64Encode(imageU1!) : null,
        'imageU2' : imageU2 != null ? base64Encode(imageU2!) : null,
        'typeU1' : typeU1,
        'typeU2' : typeU2,
        'keyU1' : keyU1,
        'keyU2' : keyU2,
        'lastMessage' : lastMessage,
        'hour' : hour,
        'members' : members,
      };
  }

}
