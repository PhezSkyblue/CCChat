import 'dart:collection';

import 'package:ccchat/models/Group.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'GroupService.dart';


class GroupServiceFirebase implements GroupService {

  @override
  Future<bool> createGroup(ChatUser user, String name, String type) async {
     try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference groupRef = firestore.collection('Group').doc();

      await groupRef.set({
        "id":groupRef.id,
        'name': name,
        'type': type,
        'hour' : Timestamp.now(),
        'lastMessage': "Se ha creado un nuevo grupo"
      });

      CollectionReference membersRef = groupRef.collection('Members');

      await membersRef.doc(user.id).set({
        'id': user.id,
        'writePermission': true,
        'type': 'Admin',
      });

      return true;
    } catch (e) {
      print('Error al crear el grupo: $e');
      return false;
    }
  }

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
          .where('type', isEqualTo: type)
          .get();

      for (var document in querySnapshot.docs) {
        CollectionReference membersRef = document.reference.collection('Members');
        var userDoc = await membersRef.doc(id).get();
        if (userDoc.exists) {
          Group group = Group.fromJson(document.data() as Map<String, dynamic>);
          chatGroup.add(group);
        }
      }

      return chatGroup;
    } catch (e) {
      print('Error al obtener la lista de grupos: $e');
      return [];
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
      final membersRef = FirebaseFirestore.instance
        .collection('Group')
        .doc(idGroup)
        .collection('Members');

      await membersRef.doc(idUser).set({
        'id': idUser,
        'writePermission': true,
        'type': 'Admin',
      });

      return true;
    } catch (e) {
      print('Error añadiendo un usuario al grupo: $e');
      return false;
    }
  }


  @override
  Future<List<Group?>> getGroupsContainsString(String search, String id, String type) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Group')
          .where('type', isEqualTo: type)
          .get();

      final List<Group?> groups = querySnapshot.docs
          .map((doc) => Group.fromJson(doc.data() as Map<String, dynamic>))
          .where((group) =>
              group.name?.toUpperCase().contains(search.toUpperCase()) == true &&
              group.members?.contains(id) == true)
          .toList();
          
      return groups;
    } catch (e) {
      print('Error buscando grupos: $e');
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
      print("okay3");
      return true;
    } catch (e) {
      print('Error al enviar el mensaje: $e');
      return false;
    }
  }

  @override
  Stream<List<Message>> getChatMessagesStream(Group chat) {
    return FirebaseFirestore.instance
        .collection('Group')
        .doc(chat.id)
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
                  return Message.builderWithID(
                    userId,
                    userName,
                    type,
                    data['message'],
                    data['hour'],
                  );
                } else {
                  return Message.builderWithID(
                    userId,
                    "Usuario eliminado",
                    "Alumno",
                    data['message'],
                    data['hour'],
                  );
                }
              });
            }).toList())
        .asyncMap((futures) => Future.wait(futures))
        .map((messages) => messages.whereType<Message>().toList());
  }

  Stream<List<Group>> listenToListOfGroups(String userId, String type) {
    return FirebaseFirestore.instance
        .collection('Group')
        .where('type', isEqualTo: type)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Group> groups = [];

          for (var doc in snapshot.docs) {
            CollectionReference membersRef = doc.reference.collection('Members');
            List<Map<String, dynamic>> memberList = List<Map<String, dynamic>>.empty(growable: true);
            
            var userDoc = await membersRef.doc(userId).get();

            if (userDoc.exists) {
              Group group = Group.fromJson(doc.data());

              try {
                // Obtenemos la colección de documentos mediante el Future<QuerySnapshot<Object?>>.
                QuerySnapshot<Object?> querySnapshot = await membersRef.get();

                // Recorremos cada DocumentSnapshot en la colección.
                for (DocumentSnapshot<Object?> document in querySnapshot.docs) {
                  // Verificamos si el documento existe.
                  if (document.exists) {
                    // Accedemos a los datos dentro del DocumentSnapshot.
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    memberList.add(data);
                    // Haces lo que necesites con los datos del documento actual.
                  } else {
                    print('El documento no existe.');
                  }
                }
              } catch (e) {
                // Manejo de errores si ocurre algún problema al leer la colección.
                print('Error al leer la colección de Members: $e');
              }

              group.members = memberList;
              //group.members = List<Map<String, String>>.from(userDoc['members'] ?? []);
              groups.add(group);
            }
          }

          return groups;
        });
  }

}
