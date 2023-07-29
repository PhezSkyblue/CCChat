import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  String id = "";
  String? name;
  String? type;
  String? lastMessage;
  Timestamp? hour;
  List<Map<String, dynamic>>? members;

  Group.builderWithID(
    this.id,
    this.name,
    this.type,
    this.lastMessage,
    this.hour,
    this.members,
  );

  Group.builderWithoutID(
    this.name,
    this.type,
    this.lastMessage,
    this.hour,
    this.members,
  );

  Group.builderEmpty();

  ///Method that convert a string to JSON
  factory Group.fromRawJson(String str) => Group.fromJson(json.decode(str));

  ///Method that converts the Group's data into a character string in JSON format
  String toRawJson() => json.encode(toJson());

  ///Method that assigns the JSON value to each Group's attribute
  ///JSON -> Group
  Group.fromJson(Map<String, dynamic> json) {
    id = json['id']!;
    name = json["name"];
    type = json["type"];
    lastMessage = json["lastMessage"];
    hour = json["hour"];
    if (json['members'] != null) {
      members = List<Map<String, String>>.from(json['members'].map((m) => {
        'id': m['id'],
        'type': m['type'],
        'writePermission': m['writePermission'],
      }));
    } else {
      members = null;
    }
  }


  ///Method that converts the Group's data into JSON
  ///Group -> JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'lastMessage': lastMessage,
      'hour': hour,
      'members': members?.map((m) => {
        'id': m['id'],
        'type': m['type'],
        'writePermission': m['writePermission'],
      }).toList(),
    };
  }
}
