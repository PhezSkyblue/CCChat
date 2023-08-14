import 'dart:convert';
import 'dart:typed_data';

import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/models/IndividualChat.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'IndividualChatService.dart';
import 'UserServiceFirebase.dart';
import 'package:intl/intl.dart';


class IndividualChatServiceFirebase implements IndividualChatService {

  @override
  Future<IndividualChat?> createChatIndividual(String idUser, String idOtherUser, String message, Timestamp hour) async {
    try {
      ChatUser? userU1 = await UserServiceFirebase().getUserByID(idUser);
      ChatUser? userU2 = await UserServiceFirebase().getUserByID(idOtherUser);

      if (userU1 == null || userU2 == null) {
        print('Uno de los usuarios no existe.');
        return null;
      }

      IndividualChat? existsChat = await getExistsChatIndividual(userU1, userU2);
      if (existsChat != null) {
        return existsChat;
      }

      DocumentReference newChat = FirebaseFirestore.instance.collection('IndividualChat').doc();

      String chatKey = AESController().generateRandomKey(32);
      String encryptedChatkeyU1 = RSAController().encryption(chatKey, userU1.publicKey!);
      String encryptedChatkeyU2 = RSAController().encryption(chatKey, userU2.publicKey!);

      await newChat.set({
        'id': newChat.id,
        'nameU1': userU1.name,
        'nameU2': userU2.name,
        'imageU1': base64Encode(userU1.image!),
        'imageU2': base64Encode(userU2.image!),
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
      
      chat!.keyU1 = RSAController().decryption(
        chat.keyU1!,
        RSAController().getRSAPrivateKey(userU1.privateKey!)
      );

      return chat;
    } else if (existingChats2.docs.isNotEmpty) {
      IndividualChat? chat = await getChatByID(existingChats2.docs.first.id);
      
      chat!.keyU2 = RSAController().decryption(
        chat.keyU2!,
        RSAController().getRSAPrivateKey(userU1.privateKey!)
      );

      return chat;
    } else {
      return null;
    }
  }

  @override
  Future<IndividualChat?> getChatByID(String id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot = await firestore
          .collection('IndividualChat')
          .doc(id)
          .get();

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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('IndividualChat')
          .where('members', arrayContains: id)
          .get();
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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('IndividualChat')
          .where('members', arrayContains: id)
          .get();

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
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('IndividualChat')
          .where('members', arrayContains: id)
          .get();

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
  Future<IndividualChat> sendMessage(String message, ChatUser? userU1, ChatUser? userU2, IndividualChat? chat) async {
    try {
      final Timestamp currentTimestamp = Timestamp.now();

      if (userU2 != null) {
        chat = await createChatIndividual(userU1!.id, userU2.id, message, currentTimestamp);
        if(chat != null){
          bool createdByMe = isCreatedByMe(chat, userU1);

          if (createdByMe) {
            chat.keyU1 = RSAController().decryption(
              chat.keyU1!,
              RSAController().getRSAPrivateKey(userU1.privateKey!)
            );
          } else {
            chat.keyU2 = RSAController().decryption(
              chat.keyU2!,
              RSAController().getRSAPrivateKey(userU1.privateKey!)
            );
          }
        }
      }

      if(chat != null) {
        final individualChat = FirebaseFirestore.instance.collection('IndividualChat').doc(chat.id);
        final messageCollection = individualChat.collection('Message');

        final chatSnapshot = await individualChat.get();
        if (chatSnapshot.exists) {
          final chatData = chatSnapshot.data();
          if (chatData != null) {
            bool createdByMe = isCreatedByMe(chat, userU1!);
            
            String encryptedMessage = AESController().encrypt(
              createdByMe ? chat.keyU1! : chat.keyU2!,
              message, 
              HASHController().generateHash(createdByMe ? chat.keyU1! : chat.keyU2!)
            ); 
                
            await messageCollection.add({
              'message': encryptedMessage,
              'hour': currentTimestamp,
              'userID': userU1.id,
            });

            await individualChat.update({
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

              return FirebaseFirestore.instance
                  .collection('User')
                  .doc(userId)
                  .get()
                  .then((userSnapshot) {
                if (userSnapshot.exists) {
                  String userName = userSnapshot['name'];
                  String type = userSnapshot['type'];
                  return decryptMessage(
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
                  return decryptMessage(
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
