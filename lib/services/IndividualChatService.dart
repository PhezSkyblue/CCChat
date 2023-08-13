import 'dart:typed_data';

import 'package:ccchat/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/IndividualChat.dart';
import '../models/Message.dart';

abstract class IndividualChatService {
  Future<IndividualChat?> createChatIndividual(String idUser, String idOtherUser, String message, Timestamp hour);

  Future<IndividualChat?> getChatByID(String id);

  Future<List<IndividualChat>> getListOfChats(String id);

  Future<bool> updateNameUser(String id, String? name);

  Future<bool> updateImageUser(String id, Uint8List image);

  Future<IndividualChat> sendMessage(String message, ChatUser? userU1, ChatUser? userU2, IndividualChat? chat);

  Stream<List<Message>> getChatMessagesStream(IndividualChat chat, ChatUser user);
}
