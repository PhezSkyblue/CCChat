import 'dart:convert';
import 'dart:typed_data';

import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/models/IndividualChat.dart';
import 'package:flutter/material.dart';
import '../controllers/IndividualChatController.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'IndividualChatService.dart';

class IndividualChatServiceFirebase implements IndividualChatService {
  @override
  Future<IndividualChat?> createChatIndividual(ChatUser userU1, ChatUser userU2, String chatKey,
      String encryptedChatkeyU1, String encryptedChatkeyU2, String message, Timestamp hour) async {
    try {
      DocumentReference newChat = FirebaseFirestore.instance.collection('IndividualChat').doc();

      await newChat.set({
        'id': newChat.id,
        'nameU1': userU1.name,
        'nameU2': userU2.name,
        'imageU1': userU1.image != null ? base64Encode(userU1.image!) : null,
        'imageU2': userU2.image != null ? base64Encode(userU2.image!) : null,
        'typeU1': userU1.type,
        'typeU2': userU2.type,
        'keyU1': encryptedChatkeyU1,
        'keyU2': encryptedChatkeyU2,
        'lastMessage': AESController().encrypt(chatKey, message, HASHController().generateHash(chatKey)),
        'hour': hour,
        'members': [userU1.id, userU2.id],
      });

      return getChatByID(newChat.id);
    } catch (e) {
      print('Error al crear el chat individual: $e');
      return null;
    }
  }

  Future<IndividualChat?> getExistsChatIndividual(ChatUser userU1, ChatUser userU2) async {
    QuerySnapshot existingChats1 = await FirebaseFirestore.instance
        .collection('IndividualChat')
        .where('members', isEqualTo: [userU1.id, userU2.id])
        .limit(1)
        .get();

    QuerySnapshot existingChats2 = await FirebaseFirestore.instance
        .collection('IndividualChat')
        .where('members', isEqualTo: [userU2.id, userU1.id])
        .limit(1)
        .get();

    if (existingChats1.docs.isNotEmpty) {
      IndividualChat? chat = await getChatByID(existingChats1.docs.first.id);

      chat!.keyU1 = RSAController().decryption(chat.keyU1!, RSAController().getRSAPrivateKey(userU1.privateKey!));

      return chat;
    } else if (existingChats2.docs.isNotEmpty) {
      IndividualChat? chat = await getChatByID(existingChats2.docs.first.id);

      chat!.keyU2 = RSAController().decryption(chat.keyU2!, RSAController().getRSAPrivateKey(userU1.privateKey!));

      return chat;
    } else {
      return null;
    }
  }

  @override
  Future<IndividualChat?> getChatByID(String id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot = await firestore.collection('IndividualChat').doc(id).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        IndividualChat chat = IndividualChat.fromJson(data);
        return chat;
      } else {
        print('No se encontró ningún chat con el ID proporcionado.');
        return null;
      }
    } catch (e) {
      print('Error al obtener el chat por ID: $e');
      return null;
    }
  }

  @override
  Future<List<IndividualChat>> getListOfChats(String id) async {
    List<IndividualChat> chatList = [];

    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('IndividualChat').where('members', arrayContains: id).get();
      querySnapshot.docs.forEach((DocumentSnapshot document) {
        IndividualChat chat = IndividualChat.fromJson(document.data() as Map<String, dynamic>);
        chatList.add(chat);
      });

      return chatList;
    } catch (e) {
      print('Error al obtener la lista de chats: $e');

      return [];
    }
  }

  @override
  Future<bool> updateNameUser(String id, String? name) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('IndividualChat').where('members', arrayContains: id).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        List<String>? members = List<String>.from(data['members']);
        IndividualChat chat = IndividualChat.fromJson(data);

        if (members.contains(id)) {
          if (members.indexOf(id) == 0) {
            chat.nameU1 = name;
          } else if (members.indexOf(id) == 1) {
            chat.nameU2 = name;
          }

          await document.reference.update(chat.toJson());
        }
      }

      return true;
    } catch (e) {
      print('Error al actualizar el nombre del usuario: $e');
      return false;
    }
  }

  @override
  Future<bool> updateImageUser(String id, Uint8List image) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('IndividualChat').where('members', arrayContains: id).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        List<String>? members = List<String>.from(data['members']);
        IndividualChat chat = IndividualChat.fromJson(data);

        if (members.contains(id)) {
          if (members.indexOf(id) == 0) {
            chat.imageU1 = image;
          } else if (members.indexOf(id) == 1) {
            chat.imageU2 = image;
          }

          await document.reference.update(chat.toJson());
        }
      }

      return true;
    } catch (e) {
      print('Error al actualizar la imagen del usuario: $e');
      return false;
    }
  }

  @override
  Future<bool> updateTypeUser(String id, String type) async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('IndividualChat').where('members', arrayContains: id).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        List<String>? members = List<String>.from(data['members']);
        IndividualChat chat = IndividualChat.fromJson(data);

        if (members.contains(id)) {
          if (members.indexOf(id) == 0) {
            chat.typeU1 = type;
          } else if (members.indexOf(id) == 1) {
            chat.typeU2 = type;
          }

          await document.reference.update(chat.toJson());
        }
      }

      return true;
    } catch (e) {
      print('Error al actualizar el tipo del usuario: $e');
      return false;
    }
  }

  @override
  Future<IndividualChat> sendMessage(
      String message, ChatUser? userU1, ChatUser? userU2, IndividualChat? chat, BuildContext context) async {
    try {
      final Timestamp currentTimestamp = Timestamp.now();

      if (userU2 != null) {
        chat = await IndividualChatController().createChatIndividual(userU1!.id, userU2.id, message, currentTimestamp);

        if (chat != null) {
          bool createdByMe = IndividualChatController().isCreatedByMe(chat, userU1);

          if (createdByMe) {
            chat.keyU1 = RSAController().decryption(chat.keyU1!, RSAController().getRSAPrivateKey(userU1.privateKey!));
          } else {
            chat.keyU2 = RSAController().decryption(chat.keyU2!, RSAController().getRSAPrivateKey(userU1.privateKey!));
          }
        }
      }

      if (chat != null) {
        final individualChat = FirebaseFirestore.instance.collection('IndividualChat').doc(chat.id);
        final messageCollection = individualChat.collection('Message');

        final chatSnapshot = await individualChat.get();
        if (chatSnapshot.exists) {
          final chatData = chatSnapshot.data();
          if (chatData != null) {
            bool createdByMe = IndividualChatController().isCreatedByMe(chat, userU1!);

            String encryptedMessage = AESController().encrypt(createdByMe ? chat.keyU1! : chat.keyU2!, message,
                HASHController().generateHash(createdByMe ? chat.keyU1! : chat.keyU2!));

            messageCollection.add({
              'message': encryptedMessage,
              'hour': currentTimestamp,
              'userID': userU1.id,
            });

            individualChat.update({
              'lastMessage': encryptedMessage,
              'hour': currentTimestamp,
            });

            return chat;
          }
        }
      }
      return IndividualChat.builderEmpty();
    } catch (e) {
      print('Error al enviar el mensaje: $e');
      return IndividualChat.builderEmpty();
    }
  }

  @override
  Stream<List<Message>> getChatMessagesStream(IndividualChat? chat, ChatUser user) {
    return FirebaseFirestore.instance
        .collection('IndividualChat')
        .doc(chat!.id)
        .collection('Message')
        .orderBy('hour', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data();
              String userId = data['userID'];

              return FirebaseFirestore.instance.collection('User').doc(userId).get().then((userSnapshot) {
                if (userSnapshot.exists) {
                  String userName = userSnapshot['name'];
                  String type = userSnapshot['type'];
                  return IndividualChatController().decryptMessage(
                      Message.builderWithID(
                        userId,
                        userName,
                        type,
                        data['message'],
                        data['hour'],
                      ),
                      chat,
                      user);
                } else {
                  // Usuario eliminado
                  return IndividualChatController().decryptMessage(
                      Message.builderWithID(
                        userId,
                        "Usuario eliminado",
                        "Alumno",
                        data['message'],
                        data['hour'],
                      ),
                      chat,
                      user);
                }
              });
            }).toList())
        .asyncMap((futures) => Future.wait(futures))
        .map((messages) => messages.whereType<Message>().toList());
  }

  Stream<List<IndividualChat>> listenToListOfChats(String userId) {
    return FirebaseFirestore.instance
        .collection('IndividualChat')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return IndividualChat.fromJson(doc.data());
      }).toList();
    });
  }
}
