import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class IndividualChat {
  String id = "";
  String? nameU1;
  String? nameU2;
  String? typeU1;
  String? typeU2;
  String? lastMessage;
  Timestamp? hour;
  List<dynamic>? members;

  IndividualChat.builderWithID(
    this.id,
    this.nameU1,
    this.nameU2,
    this.typeU1,
    this.typeU2,
    this.lastMessage,
    this.hour,
    this.members,
  );

  IndividualChat.builderWithoutID(
    this.nameU1,
    this.nameU2,
    this.typeU1,
    this.typeU2,
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
    typeU1 = json["typeU1"];
    typeU2 = json["typeU2"];
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
        'typeU1' : typeU1,
        'typeU2' : typeU2,
        'lastMessage' : lastMessage,
        'hour' : hour,
        'members' : members,
      };
  }

}
