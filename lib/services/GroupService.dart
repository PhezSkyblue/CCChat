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

  Future<bool> sendMessage(String message, ChatUser? user, Group? group, BuildContext context);

  Future<List<Group?>> getGroupsContainsString(String search, String id, String type);

  Stream<List<Message>> getChatMessagesStream(Group chat);
}
