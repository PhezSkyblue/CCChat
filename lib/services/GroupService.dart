import 'package:ccchat/models/User.dart';
import 'package:flutter/material.dart';
import '../models/Group.dart';
import '../models/Message.dart';

abstract class GroupService {
  Future<bool> createGroup(ChatUser user, String name, String type);

  Future<Group?> getGrouptByID(String id);

  Future<List<Group>> getListOfGroups(String id, String type);

  Future<bool> updateNameGroup(String id, String? name, String type);

  Future<Group?> addUserToMembers(Group group, String idUser, String type, BuildContext context);

  Future<bool> deleteGroup(String id, String type);

  Future<bool> sendMessage(String message, ChatUser? user, Group? group, BuildContext context);

  Future<List<Group?>> getGroupsContainsString(String search, String id, String type);

  Stream<List<Message>> getChatMessagesStream(Group chat, ChatUser user);

  Stream<List<Group>> listenToListOfGroups(String userId, String type);

  Future<Group?> addUserToMembersWithEmail(Group group, String email, BuildContext context);

  Future<Group?> addUserToMembersWithExcel(Group group, String email, BuildContext context);

  Future<Group?> addUserToMembersForType(Group group, String typeUser, BuildContext context);

  Future<Group?> addUserToMembersForCareer(Group group, String careerUser, BuildContext context);
}
