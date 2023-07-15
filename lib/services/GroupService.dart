import 'package:ccchat/models/User.dart';
import '../models/Group.dart';
import '../models/Message.dart';

abstract class GroupService {
  //Future<Group?> createGroup(String idUser, String idOtherUser, String message, Timestamp hour);

  Future<Group?> getGrouptByID(String id);

  Future<List<Group>> getListOfGroups(String id, String type);

  Future<bool> updateNameGroup(String id, String? name);

  Future<bool> addUserToMembers(String idGroup, String idUser);

  Future<bool> sendMessage(String message, ChatUser? user, Group? group);

  Future<List<Group?>> getGroupsContainsString(String search, String id, String type);

  Stream<List<Message>> getChatMessagesStream(Group chat);
}
