import 'dart:typed_data';

import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/controllers/UserController.dart';
import 'package:ccchat/models/IndividualChat.dart';
import 'package:ccchat/services/IndividualChatServiceFirebase.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class IndividualChatController {
  Future<IndividualChat?> createChatIndividual(String idUser, String idOtherUser, String message, Timestamp hour) async {
    try {
      ChatUser? userU1 = await UserController().getUserByID(idUser);
      ChatUser? userU2 = await UserController().getUserByID(idOtherUser);

      if (userU1 == null || userU2 == null) {
        print('Uno de los usuarios no existe.');
        return null;
      }

      IndividualChat? existsChat = await IndividualChatServiceFirebase().getExistsChatIndividual(userU1, userU2);
      if (existsChat != null) {
        return existsChat;
      }

      String chatKey = AESController().generateRandomKey(32);
      String encryptedChatkeyU1 = RSAController().encryption(chatKey, userU1.publicKey!);
      String encryptedChatkeyU2 = RSAController().encryption(chatKey, userU2.publicKey!);

      return IndividualChatServiceFirebase().createChatIndividual(userU1, userU2, chatKey, encryptedChatkeyU1, encryptedChatkeyU2, message, hour);
    } catch (e) {
      print('Error al crear el chat individual: $e');
      return null;
    }
  }

  Future<IndividualChat?> getExistsChatIndividual(ChatUser userU1, ChatUser userU2) async {    
    return IndividualChatServiceFirebase().getExistsChatIndividual(userU1, userU2);
  }

  Future<IndividualChat?> getChatByID(String id) async {
    return IndividualChatServiceFirebase().getChatByID(id);
  }

  Future<List<IndividualChat>> getListOfChats(String id) async {
    return IndividualChatServiceFirebase().getListOfChats(id);
  }

  Future<bool> updateNameUser(String id, String? name) async {
    return IndividualChatServiceFirebase().updateNameUser(id, name);
  }

  Future<bool> updateImageUser(String id, Uint8List image) async {
    return IndividualChatServiceFirebase().updateImageUser(id, image);
  }

  Future<bool> updateTypeUser(String id, String type) async {
   return IndividualChatServiceFirebase().updateTypeUser(id, type);
  }

  Future<IndividualChat> sendMessage(String message, ChatUser? userU1, ChatUser? userU2, IndividualChat? chat) async {
    return IndividualChatServiceFirebase().sendMessage(message, userU1, userU2, chat);
  }

  Stream<List<Message>> getChatMessagesStream(IndividualChat? chat, ChatUser user) {
    return IndividualChatServiceFirebase().getChatMessagesStream(chat, user);
  }

  Stream<List<IndividualChat>> listenToListOfChats(String userId) {
    return IndividualChatServiceFirebase().listenToListOfChats(userId);
  }

  bool isCreatedByMe(IndividualChat chat, ChatUser user) {
    try {
      List members = chat.members!;
      if (members.isNotEmpty) {
        if (members[0].toString() == user.id) {
          return true;
        } else if (members[1].toString() == user.id) {
          return false;
        }
      }
    return true;

    } catch (e) {
      print('Error al verificar si fue creado por mí: $e');
      return false;
    }
  }

  String readTimestamp(Timestamp? timestamp) {
    var now = DateTime.now();
    var date = timestamp!.toDate();
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = DateFormat('HH:mm').format(date);
    } else if (diff.inDays == 1) {
      time = 'Ayer';
    } else {
      time = DateFormat('dd/MM/yyyy').format(date);
    }

    return time;
  }

  String readDay(Timestamp? timestamp) {
    var now = DateTime.now();
    var date = timestamp!.toDate();
    var diff = now.difference(date);
    var time = '';

    if (diff.inSeconds <= 0 || diff.inSeconds > 0 && diff.inMinutes == 0 || diff.inMinutes > 0 && diff.inHours == 0 || diff.inHours > 0 && diff.inDays == 0) {
      time = 'Hoy';
    } else if (diff.inDays == 1) {
      time = 'Ayer';
    } else {
      time = DateFormat('dd/MM/yyyy').format(date);
    }

    return time;
  }

  bool areTheSameDate(Timestamp? actualTimestamp, Timestamp? nextTimestamp) {
    return readDay(actualTimestamp) == readDay(nextTimestamp);
  }

  String readHour(Timestamp? timestamp) {
    var date = timestamp!.toDate();
    return DateFormat('HH:mm').format(date);
  }

  Message decryptMessage (Message message, IndividualChat chat, ChatUser user) {
    bool createdByMe = isCreatedByMe(chat, user);

    message.message = AESController().decrypt(
      createdByMe ? chat.keyU1! : chat.keyU2!,
      message.message!, 
      HASHController().generateHash(createdByMe ? chat.keyU1! : chat.keyU2!) 
    );

    return message;
  }
}
