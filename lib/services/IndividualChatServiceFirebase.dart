import 'package:ccchat/models/IndividualChat.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'IndividualChatService.dart';
import 'UserServiceFirebase.dart';
import 'package:intl/intl.dart';


class IndividualChatServiceFirebase implements IndividualChatService {

  @override
  Future<IndividualChat?> createChatIndividual(String idUser, String idOtherUser) async {
    try {
      ChatUser? userU1 = await UserServiceFirebase().getUserByID(idUser);
      ChatUser? userU2 = await UserServiceFirebase().getUserByID(idOtherUser);

      if (userU1 != null || userU2 != null) {
        print('Uno de los usuarios no existe.');
        return null;
      }

      DocumentReference newChat = FirebaseFirestore.instance.collection('IndividualChat').doc();
      
      await newChat.set({
        'id': newChat.id,
        'nameU1': userU1!.name,
        'nameU2': userU2!.name,
        'typeU1': userU1.type,
        'typeU2': userU2.type,
        'lastMessage': "",
        'hour': "",
        'members': [userU1.id, userU2.id],
      });

      return getChatByID(newChat.id);
    } catch (e) {
      print('Error al crear el chat individual: $e');
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
        print('No se encontró ningún usuario con el ID proporcionado.');
        return null;
      }
    } catch (e) {
      print('Error al obtener el usuario por ID: $e');
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

  Future<bool> isCreatedByMe(String idChat, String idUser) async {
    try {
      var chatSnapshot = await FirebaseFirestore.instance
          .collection('IndividualChat')
          .doc(idChat)
          .get();

      if (chatSnapshot.exists) {
        List<String> members = List<String>.from(chatSnapshot.data()?['members']);

        if (members.isNotEmpty) {
          if (members[0] == idUser) {
            return true;
          } else if (members[1] == idUser) {
            return false;
          }
        }
      }

      return false;
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
  
}
