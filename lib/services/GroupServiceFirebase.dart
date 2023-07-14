import 'package:ccchat/models/Group.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GroupService.dart';


class GroupServiceFirebase implements GroupService {

  @override
  Future<Group?> getGrouptByID(String id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot = await firestore
          .collection('Group')
          .doc(id)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        Group group = Group.fromJson(data);
        return group;
      } else {
        print('No se encontró ningún grupo con el ID proporcionado.');
        return null;
      }
    } catch (e) {
      print('Error al obtener el grupo por ID: $e');
      return null;
    }
  }

  @override
  Future<List<Group>> getListOfGroups(String id, String type) async {
    List<Group> chatGroup = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Group')
          .where('members', arrayContains: id)
          .where('type', isEqualTo: type)
          .get();
            querySnapshot.docs.forEach((DocumentSnapshot document) {
              Group group = Group.fromJson(document.data() as Map<String, dynamic>);
              chatGroup.add(group);
            });
      
      return chatGroup;
    } catch (e) {
      print('Error al obtener la lista de grupos: $e');
      return [];
    }
  }

  @override
  Future<bool> sendMessage(String message, ChatUser? user, Group? group) async {
    try {
      final Timestamp currentTimestamp = Timestamp.now();

      final messageCollection = FirebaseFirestore.instance
          .collection('Group')
          .doc(group!.id)
          .collection('Message');

      await messageCollection.add({
        'message': message,
        'hour': currentTimestamp,
        'userID': user!.id,
      });

      final chatDocument = FirebaseFirestore.instance.collection('Group').doc(group.id);
      await chatDocument.update({
        'lastMessage': message,
        'hour': currentTimestamp,
      });
      
      return true;
    } catch (e) {
      print('Error al enviar el mensaje: $e');
      return false;
    }
  }

  @override
  Future<bool> updateNameGroup(String id, String? name) async {
    try {
      await FirebaseFirestore.instance
          .collection('Group')
          .doc(id)
          .update({'name': name});

      return true;
    } catch (e) {
      print('Error actualizando el nombre del grupo: $e');
      return false;
    }
  }

  @override
  Future<bool> addUserToMembers(String idGroup, String idUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('Group')
          .doc(idGroup)
          .update({
            'members': FieldValue.arrayUnion([idUser])
          });

      return true;
    } catch (e) {
      print('Error añadiendo un usuario al grupo: $e');
      return false;
    }
  }

  Stream<List<Group>> listenToListOfGroups(String userId, String type) {
    return FirebaseFirestore.instance
      .collection('Group')
      .where('members', arrayContains: userId)
      .where('type', isEqualTo: type)
      .snapshots()
      .map((snapshot) {
        print(type);
        return snapshot.docs.map((doc) {
          return Group.fromJson(doc.data());
        }).toList();
      });
  }
}