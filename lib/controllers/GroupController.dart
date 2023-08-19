import 'dart:typed_data';
import 'package:ccchat/controllers/UserController.dart';
import 'package:ccchat/models/Group.dart';
import 'package:ccchat/services/GroupServiceFirebase.dart';
import 'package:flutter/material.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/styles/styles.dart';

class GroupController {
  Future<bool> createGroup(ChatUser user, String name, String type) async {
    return GroupServiceFirebase().createGroup(user, name, type);
  }

  Future<Group?> getGroupByID(String id) async {
    return GroupServiceFirebase().getGroupByID(id);
  }

  Future<List<Group>> getListOfGroups(String id, String type) async {
    return GroupServiceFirebase().getListOfGroups(id, type);
  }

  Future<bool> updateNameGroup(String id, String? name, String type) async {
    return GroupServiceFirebase().updateNameGroup(id, name, type);
  }

  Future<bool> updateImageGroup(String id, Uint8List? image, String type) async {
    return GroupServiceFirebase().updateImageGroup(id, image, type);
  }

  Future<bool> updateTypeGroup(String idGroup, String idUser, String type, String groupType) async {
    return GroupServiceFirebase().updateTypeGroup(idGroup, idUser, type, groupType);
  }

  Future<Group?> addUserToMembers(
      Group group, ChatUser user, ChatUser userAdmin, String type, BuildContext context) async {
    return GroupServiceFirebase().addUserToMembers(group, user, userAdmin, type, context);
  }

  Future<bool> deleteGroup(String id, String type) async {
    return GroupServiceFirebase().deleteGroup(id, type);
  }

  Future<List<Group?>> getGroupsContainsString(String search, ChatUser user, String type) async {
    return GroupServiceFirebase().getGroupsContainsString(search, user, type);
  }

  Future<bool> sendMessage(String message, ChatUser? user, Group? group, BuildContext context) async {
    return GroupServiceFirebase().sendMessage(message, user, group, context);
  }

  Stream<List<Message>> getChatMessagesStream(Group group, ChatUser user) {
    return GroupServiceFirebase().getChatMessagesStream(group, user);
  }

  Stream<List<Group>> listenToListOfGroups(String userId, String type) {
    return GroupServiceFirebase().listenToListOfGroups(userId, type);
  }

  Future<Group?> addUserToMembersWithEmail(Group group, ChatUser userAdmin, String email, BuildContext context) async {
    ChatUser? user = await UserController().getUserByEmail(email);

    if (user != null) {
      // ignore: use_build_context_synchronously
      return await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, user.type!, context);
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuario', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con el email introducido.',
                style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  Future<Group?> addUserToMembersWithExcel(Group group, ChatUser userAdmin, String email, BuildContext context) async {
    ChatUser? user = await UserController().getUserByEmail(email);

    if (user != null) {
      // ignore: use_build_context_synchronously
      return await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, user.type!, context);
    }

    return null;
  }

  Future<Group?> addUserToMembersForType(Group group, ChatUser userAdmin, String typeUser, BuildContext context) async {
    CollectionReference<Object?> users = UserController().getListOfUsers();
    bool userWithTypeFound = false;

    QuerySnapshot<Object?> snapshot = await users.get();

    for (var userDoc in snapshot.docs) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      ChatUser user = ChatUser.fromJson(userData);

      if (userData['type'] == typeUser && typeUser != "Profesor") {
        // ignore: use_build_context_synchronously
        group = (await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, userData['type'], context))!;
        userWithTypeFound = true;
      }

      if (typeUser == "Todos los usuarios") {
        // ignore: use_build_context_synchronously
        group = (await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, userData['type'], context))!;
        userWithTypeFound = true;
      }

      if (typeUser == "Profesor" &&
          (userData['type'] != "Alumno" &&
              userData['type'] != "Delegado" &&
              userData['type'] != "Subdelegado" &&
              userData['type'] != "Administrativo")) {
        // ignore: use_build_context_synchronously
        group = (await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, userData['type'], context))!;
        userWithTypeFound = true;
      }
    }

    if (userWithTypeFound == true) {
      return group;
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuarios', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con ese tipo.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  Future<Group?> addUserToMembersForCareer(
      Group group, ChatUser userAdmin, String careerUser, BuildContext context) async {
    CollectionReference<Object?> users = UserController().getListOfUsers();
    bool userWithTypeFound = false;

    QuerySnapshot<Object?> snapshot = await users.get();

    for (var userDoc in snapshot.docs) {
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      ChatUser user = ChatUser.fromJson(userData);

      if (userData['career'] == careerUser) {
        // ignore: use_build_context_synchronously
        group = (await GroupServiceFirebase().addUserToMembers(group, user, userAdmin, userData['type'], context))!;
        userWithTypeFound = true;
      }
    }

    if (userWithTypeFound == true) {
      return group;
    } else {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuarios', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con ese tipo.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  Future<Group?> userPermission(Group group, String idUser, bool permission) async {
    return GroupServiceFirebase().userPermission(group, idUser, permission);
  }

  Future<Group?> userAdmin(Group group, String idUser, bool admin) async {
    return GroupServiceFirebase().userAdmin(group, idUser, admin);
  }

  Future<Group?> deleteUser(Group group, String idUser) async {
    return GroupServiceFirebase().deleteUser(group, idUser);
  }
}
