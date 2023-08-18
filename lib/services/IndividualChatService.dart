import 'dart:typed_data';

import 'package:ccchat/models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/IndividualChat.dart';
import '../models/Message.dart';

abstract class IndividualChatService {
  Future<IndividualChat?> createChatIndividual(
    ChatUser userU1,
    ChatUser userU2,
    String chatKey,
    String encryptedChatkeyU1,
    String encryptedChatkeyU2,
    String message, 
    Timestamp hour
  );

  Future<IndividualChat?> getChatByID(String id);

  Future<List<IndividualChat>> getListOfChats(String id);

  Future<bool> updateNameUser(String id, String? name);

  Future<bool> updateImageUser(String id, Uint8List image);

  Future<bool> updateTypeUser(String id, String type);

  Future<IndividualChat> sendMessage(
    String message, 
    ChatUser? userU1, 
    ChatUser? userU2, 
    IndividualChat? chat,
    BuildContext context,
  );

  Stream<List<Message>> getChatMessagesStream(IndividualChat chat, ChatUser user);
}
