import 'dart:convert';

class ChatUser {
  String id = "";
  String? name;
  String? email;
  String? type;
  String? departament;
  List<String>? subjects;

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
    departament = json["departament"];
    subjects = json["subjects"];
  }

  ///Method that converts the User's data into JSON
  ///User -> JSON
  Map<String, dynamic> toJson() {
    return {
        'id' : id,
        'name' : name,
        'email' : email,
        'type' : type,
        'departament' : departament,
        'subjects' : subjects,
      };
  }

}
