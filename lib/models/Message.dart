import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  String userId = "";
  String? userName;
  String? type;
  String? message;
  Timestamp? hour;

  Message.builderWithID(
    this.userId,
    this.userName,
    this.type,
    this.message,
    this.hour,
  );

  Message.builderWithoutID(
    this.userId,
    this.userName,
    this.type,
    this.message,
    this.hour,
  );

  Message.builderEmpty();

  ///Method that convert a string to JSON
  factory Message.fromRawJson(String str) => Message.fromJson(json.decode(str));

  ///Method that converts the Message's data into a character string in JSON format
  String toRawJson() => json.encode(toJson());

  ///Method that assigns the JSON value to each Message's attribute
  ///JSON -> Message
  Message.fromJson(Map<String, dynamic> json) {
    userId = json['userID'];
    userName = json['userName'];
    type = json['type'];
    message = json['message'];
    hour = json['hour'];
  }

  ///Method that converts the Message's data into JSON
  ///Message -> JSON
  Map<String, dynamic> toJson() {
    return {
        'userID' : userId,
        'userName' : userName,
        'type' : type,
        'message' : message,
        'hour' : hour,
      };
  }
}
