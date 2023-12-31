import 'dart:typed_data';

import 'package:ccchat/models/User.dart';
import 'package:flutter/material.dart';
import '../models/Group.dart';
import '../models/Message.dart';

abstract class GroupService {
  Future<bool> createGroup(ChatUser user, String name, String type);

  Future<Group?> getGroupByID(String id);

  Future<List<Group>> getListOfGroups(String id, String type);

  Future<bool> updateNameGroup(String id, String? name, String type);

  Future<bool> updateImageGroup(String id, Uint8List? image, String type);

  Future<bool> updateTypeGroup(String idGroup, String idUser, String type, String groupType);

  Future<Group?> addUserToMembers(Group group, ChatUser user, ChatUser userTeacher, String type, BuildContext context);

  Future<bool> deleteGroup(String id, String type);

  Future<bool> sendMessage(String message, ChatUser? user, Group? group, BuildContext context);

  Future<List<Group?>> getGroupsContainsString(String search, ChatUser user, String type);

  Stream<List<Message>> getChatMessagesStream(Group chat, ChatUser user);

  Stream<List<Group>> listenToListOfGroups(String userId, String type);
}
