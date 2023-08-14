import 'dart:convert';
import 'dart:typed_data';

import 'package:ccchat/models/Group.dart';
import 'package:ccchat/services/UserServiceFirebase.dart';
import 'package:flutter/material.dart';
import '../controllers/AESController.dart';
import '../controllers/HASHController.dart';
import '../controllers/RSAController.dart';
import '../models/Message.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../views/styles/styles.dart';
import 'GroupService.dart';


class GroupServiceFirebase implements GroupService {

  @override
  Future<bool> createGroup(ChatUser user, String name, String type) async {
     try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference groupRef = firestore.collection('Group').doc();

      String groupKey = AESController().generateRandomKey(32);
      print("Key original al crearla " + groupKey);
      String encryptedGroupkey = RSAController().encryption(groupKey, user.publicKey!);

      await groupRef.set({
        "id": groupRef.id,
        'name': name,
        'type': type,
        'hour' : Timestamp.now(),
        'lastMessage': AESController().encrypt(groupKey, "Se ha creado un nuevo grupo", HASHController().generateHash(groupKey)),
      });

      CollectionReference membersRef = groupRef.collection('Members');

      await membersRef.doc(user.id).set({
        'id': user.id,
        'key': encryptedGroupkey,
        'writePermission': true,
        'type': 'Admin',
      });

      if (type == "Grupos de asignaturas con profesores") {
        DocumentReference groupRef2 = firestore.collection('Group').doc();

        await groupRef2.set({
          "id": groupRef2.id,
          'name': name,
          'type': "Grupos de asignaturas solo alumnos",
          'hour' : Timestamp.now(),
          'lastMessage': AESController().encrypt(groupKey, "Se ha creado un nuevo grupo", HASHController().generateHash(groupKey)),
          'idTeacherGroup' : groupRef.id
        });

        if (user.type != "Administrativo") {
          List<String>? subjects = user.subject?.cast<String>();

          if (subjects == null) {
            subjects = [];
          }

          subjects.add(name);
          UserServiceFirebase().updateUser(user: user, subject: subjects);
        }
      }

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
  Future<bool> updateNameGroup(String id, String? name, String type) async {
    try {
      DocumentSnapshot groupSnapshot =
      await FirebaseFirestore.instance.collection('Group').doc(id).get();
      Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?;
      String? originalName = groupData?['name'];

      await FirebaseFirestore.instance
          .collection('Group')
          .doc(id)
          .update({'name': name});

      if (type == "Grupos de asignaturas con profesores") {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Group')
          .where("idTeacherGroup", isEqualTo: id)
          .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          DocumentReference documentReference = documentSnapshot.reference;

          await documentReference.update({'name': name});

          QuerySnapshot membersSnapshot =
              await groupSnapshot.reference.collection('Members').get();

          for (DocumentSnapshot memberSnapshot in membersSnapshot.docs) {
            String memberId = memberSnapshot.id;
            var userRef = await FirebaseFirestore.instance.collection('User').doc(memberSnapshot.id).get();
            var userData = userRef.data();
            var subjects = userData == null
              ? []
              : userData["subject"];

            if (subjects.contains(originalName)) {
              int index = subjects.indexOf(originalName!);
              subjects[index] = name!;
              await FirebaseFirestore.instance
                  .collection('User')
                  .doc(memberId)
                  .update({'subject': subjects});
            }
          }
        }
      }

      return true;
    } catch (e) {
      print('Error actualizando el nombre del grupo: $e');
      return false;
    }
  }

  @override
  Future<bool> updateImageGroup(String id, Uint8List? image, String type) async {
    try {
      await FirebaseFirestore.instance
          .collection('Group')
          .doc(id)
          .update({'image': base64Encode(image!)});

      if (type == "Grupos de asignaturas con profesores") {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Group')
          .where("idTeacherGroup", isEqualTo: id)
          .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          DocumentReference documentReference = documentSnapshot.reference;
          await documentReference.update({'image': base64Encode(image)});
        }
      }

      return true;
    } catch (e) {
      print('Error actualizando el nombre del grupo: $e');
      return false;
    }
  }

  @override
  Future<Group?> addUserToMembers(Group group, ChatUser user, ChatUser userAdmin, String type, BuildContext context) async {
    try {
      if (group.type == "Grupos difusión") {
        final membersRef = FirebaseFirestore.instance
          .collection('Group')
          .doc(group.id)
          .collection('Members');

        DocumentSnapshot memberSnapshot = await membersRef.doc(userAdmin.id).get();

        if (memberSnapshot.exists) {
          Map<String, dynamic> currentMember = group.members!.firstWhere((element) => 
            element["id"] == userAdmin.id
          );

          String groupKey = currentMember["key"];

          String encryptedGroupKey = RSAController().encryption(groupKey, user.publicKey!);

          await membersRef.doc(user.id).set({
            'id': user.id,
            'writePermission': false,
            'type': type,
            'key': encryptedGroupKey
          });

          if (group.members == null) {
            group.members = [];
          }

          group.members!.add({
            'id': user.id,
            'writePermission': false,
            'type': type,
            'key': encryptedGroupKey
          });
        }

      } else {
        final membersRef = FirebaseFirestore.instance
          .collection('Group')
          .doc(group.id)
          .collection('Members');

        DocumentSnapshot memberSnapshot = await membersRef.doc(userAdmin.id).get();

        if (memberSnapshot.exists) {
          Map<String, dynamic> currentMember = group.members!.firstWhere((element) => 
            element["id"] == userAdmin.id
          );

          String groupKey = currentMember["key"];

          String encryptedGroupKey = RSAController().encryption(groupKey, user.publicKey!);

          await membersRef.doc(user.id).set({
            'id': user.id,
            'writePermission': true,
            'type': type,
            'key': encryptedGroupKey
          });

          if (group.members == null) {
            group.members = [];
          }

          group.members!.add({
            'id': user.id,
            'writePermission': true,
            'type': type,
            'key': encryptedGroupKey
          });
        }
      }

      if (group.type == "Grupos de asignaturas con profesores") {
        final groupsRef = FirebaseFirestore.instance
          .collection('Group')
          .where('idTeacherGroup', isEqualTo: group.id);

        final querySnapshot = await groupsRef.get();
        final userRef = FirebaseFirestore.instance.collection('User').doc(user.id);
        final userSnapshot = await userRef.get();

        if (querySnapshot.size > 0) {
          final groupDocSnapshot = querySnapshot.docs[0];
          final membersRef = groupDocSnapshot.reference.collection('Members');

          if (userSnapshot.exists) {
            final userData = userSnapshot.data();

            if (userData != null) {
              if (userData['type'] == "Alumno" || userData['type'] == "Delegado" || userData['type'] == "Subdelegado") {
                var member = group.members!.firstWhere((member) => member['id'] == userAdmin.id);
                String memberKey = member["key"];
                String encryptedGroupKey = RSAController().encryption(memberKey, user.publicKey!);

                await membersRef.doc(user.id).set({
                  'id': user.id,
                  'writePermission': true,
                  'type': type,
                  'key': encryptedGroupKey
                });
              }

              if (userData['type'] != "Administrativo") {
                final List<String> subject = userData['subject'] != null
                  ? List<String>.from(userData['subject'])
                  : [];

                if (!subject.contains(group.name)) {
                  subject.add(group.name!);
                  UserServiceFirebase().updateUser(user: user, subject: subject);
                }
              }
            }
          }
        }
      }

      return group;
    } catch (e) {
      print('Error añadiendo un usuario al grupo: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuario', style: TextStyle(color: MyColors.white)),
            content: const Text('No se ha podido añadir el usuario.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );
      return null;
    }
  }

  @override
  Future<bool> deleteGroup(String id, String type) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference groupCollection = firestore.collection('Group');
      DocumentReference groupRef = groupCollection.doc(id);

      await groupRef.delete();

      await groupRef.collection('Members').get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      await groupRef.collection('Message').get().then((snapshot) {
        for (DocumentSnapshot ds in snapshot.docs) {
          ds.reference.delete();
        }
      });

      if (type == "Grupos de asignaturas con profesores") {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Group')
            .where("idTeacherGroup", isEqualTo: id)
            .get();

        for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
          await documentSnapshot.reference.delete();
          
          await documentSnapshot.reference.collection('Members').get().then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
            }
          });

          await documentSnapshot.reference.collection('Message').get().then((snapshot) {
            for (DocumentSnapshot ds in snapshot.docs) {
              ds.reference.delete();
            }
          });

          QuerySnapshot membersSnapshot = await documentSnapshot.reference.collection('Members').get();
          for (DocumentSnapshot memberSnapshot in membersSnapshot.docs) {
            String memberId = memberSnapshot.id;
            Map<String, dynamic>? memberData = memberSnapshot.data() as Map<String, dynamic>?;

            if (memberData != null && memberData['type'] != "Administrativo") {
              List<String> subjects = memberData['subject'] != null
                  ? List<String>.from(memberData['subject'])
                  : [];

              if (subjects.contains(documentSnapshot['name'])) {
                subjects.remove(documentSnapshot['name']);
                await firestore.collection('User').doc(memberId).update({
                  'subject': subjects,
                });
              }
            }
          }
        }
      }

      return true;
    } catch (e) {
      print('Error al eliminar el usuario: $e');
      return false;
    }
  }

  @override
  Future<List<Group?>> getGroupsContainsString(String search, ChatUser user, String type) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Group')
          .where('type', isEqualTo: type)
          .get();

      final List<Group?> groups = [];

      for (var doc in querySnapshot.docs) {
        Group group = Group.fromJson(doc.data() as Map<String, dynamic>);

        CollectionReference membersRef = doc.reference.collection('Members');
        QuerySnapshot membersSnapshot = await membersRef.where('id', isEqualTo: user.id).get();

        if (membersSnapshot.docs.isNotEmpty) {
          
          QuerySnapshot<Object?> members = await membersRef.get();
          group.members = List<Map<String, dynamic>>.empty(growable: true);

          for (var member in members.docs) {
            if(member.exists){
              Map<String, dynamic> data = member.data() as Map<String, dynamic>;
              group.members!.add(data);
            }
          }

          int index = group.members!.indexWhere((member) => member["id"] == user.id);

          group.members![index]["key"] = RSAController().decryption(
            group.members![index]["key"], 
            RSAController().getRSAPrivateKey(user.privateKey!)
          );
          
          group.lastMessage = AESController().decrypt(
            group.members![index]["key"], 
            group.lastMessage!, 
            HASHController().generateHash(group.members![index]["key"])
          );
          
          groups.add(group);
        }
      }

      final filteredGroups = groups.where((group) =>
          group?.name?.toUpperCase().contains(search.toUpperCase()) == true).toList();

      return filteredGroups;
    } catch (e) {
      print('Error buscando grupos: $e');
      return [];
    }
  }


  @override
  Future<bool> sendMessage(String message, ChatUser? user, Group? group, BuildContext context) async {
    try {
      final Timestamp currentTimestamp = Timestamp.now();
      final member = group!.members!.firstWhere((member) => member['id'] == user!.id);

      if (member != null) {
        if (member['writePermission'] == true) {
          String memberKey = member["key"];
        
          final messageCollection = FirebaseFirestore.instance
              .collection('Group')
              .doc(group.id)
              .collection('Message');

          await messageCollection.add({
            'message': AESController().encrypt(memberKey, message, HASHController().generateHash(memberKey)),
            'hour': currentTimestamp,
            'userID': user!.id,
          });

          final chatDocument = FirebaseFirestore.instance.collection('Group').doc(group.id);
          await chatDocument.update({
            'lastMessage': AESController().encrypt(memberKey, message, HASHController().generateHash(memberKey)),
            'hour': currentTimestamp,
          });
          
          return true;
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: MyColors.background3,
                title: const Text('Sin permiso para enviar mensajes', style: TextStyle(color: MyColors.white)),
                content: const Text('No tienes permiso para enviar mensajes en este grupo.', style: TextStyle(color: MyColors.white)),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                  ),
                ],
              );
            },
          );
        }
      }
      return false;
    } catch (e) {
      print('Error al enviar el mensaje: $e');
      return false;
    }
  }

  @override
  Stream<List<Message>> getChatMessagesStream(Group group, ChatUser user) {
    return FirebaseFirestore.instance
      .collection('Group')
      .doc(group.id)
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
            final member = group.members!.firstWhere((member) => member['id'] == user.id);
            String memberKey = member["key"];

            if (userSnapshot.exists) {
              String userName = userSnapshot['name'];
              String type = userSnapshot['type'];

              return Message.builderWithID(
                userId,
                userName,
                type,
                AESController().decrypt(memberKey, data['message'], HASHController().generateHash(memberKey)),
                data['hour'],
              );
            } else {
              return Message.builderWithID(
                userId,
                "Usuario eliminado",
                "Alumno",
                AESController().decrypt(memberKey, data['message'], HASHController().generateHash(memberKey)),
                data['hour'],
              );
            }
          });
        }).toList())
      .asyncMap((futures) => Future.wait(futures))
      .map((messages) => messages.whereType<Message>().toList());
  }

  @override
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
                QuerySnapshot<Object?> querySnapshot = await membersRef.get();
                for (DocumentSnapshot<Object?> document in querySnapshot.docs) {
                  if (document.exists) {
                    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                    memberList.add(data);
                  }
                }
              } catch (e) {
                print('Error al leer la colección de Members: $e');
              }

              group.members = memberList;
              groups.add(group);
            }
          }

          return groups;
        });
  }

  @override
  Future<Group?> addUserToMembersWithEmail(Group group, ChatUser userAdmin, String email, BuildContext context) async {
    ChatUser? user = await UserServiceFirebase().getUserByEmail(email);

    if(user != null) {
      return await addUserToMembers(group, user, userAdmin, user.type!, context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuario', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con el email introducido.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  @override
  Future<Group?> addUserToMembersWithExcel(Group group, ChatUser userAdmin, String email, BuildContext context) async {
    //for recorriendo el excel
    ChatUser? user = await UserServiceFirebase().getUserByEmail(email);

    if(user != null) {
      return await addUserToMembers(group, user, userAdmin, user.type!, context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuario', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con el email introducido.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  @override
  Future<Group?> addUserToMembersForType(Group group, ChatUser userAdmin, String typeUser, BuildContext context) async {
    CollectionReference<Object?> users = UserServiceFirebase().getListOfUsers();
    bool userWithTypeFound = false;

    if(users != null) {
      QuerySnapshot<Object?> snapshot = await users.get();

      for (var userDoc in snapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        ChatUser user = ChatUser.fromJson(userData);

        if (userData['type'] == typeUser && typeUser != "Profesor") {
          group = (await addUserToMembers(group, user, userAdmin, userData['type'], context))!;
          userWithTypeFound = true;
        }

        if (typeUser == "Todos los usuarios") {
          group = (await addUserToMembers(group, user, userAdmin, userData['type'], context))!;
          userWithTypeFound = true;
        }

        if (typeUser == "Profesor" && 
            (userData['type'] != "Alumno" 
            && userData['type'] != "Delegado" 
            && userData['type'] != "Subdelegado" 
            && userData['type'] != "Administrativo")) {
          group = (await addUserToMembers(group, user, userAdmin, userData['type'], context))!;
          userWithTypeFound = true;
        }
      }
    }

    if(users != null && userWithTypeFound == true) {
      return group;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuarios', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con ese tipo.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  @override
  Future<Group?> addUserToMembersForCareer(Group group, ChatUser userAdmin, String careerUser, BuildContext context) async {
    CollectionReference<Object?> users = UserServiceFirebase().getListOfUsers();
    bool userWithTypeFound = false;

    if(users != null) {
      QuerySnapshot<Object?> snapshot = await users.get();

      for (var userDoc in snapshot.docs) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        ChatUser user = ChatUser.fromJson(userData);

        if (userData['career'] == careerUser) {
          group = (await addUserToMembers(group, user, userAdmin, userData['type'], context))!;
          userWithTypeFound = true;
        }
      }
    }

    if(users != null && userWithTypeFound == true) {
      return group;
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error al añadir usuarios', style: TextStyle(color: MyColors.white)),
            content: const Text('No existe ningún usuario con ese tipo.', style: TextStyle(color: MyColors.white)),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
              ),
            ],
          );
        },
      );

      return null;
    }
  }

  Future<Group?> userPermission(Group group, String idUser, bool permission) async {
    try {
      final membersRef = FirebaseFirestore.instance
          .collection('Group')
          .doc(group.id)
          .collection('Members');

      await membersRef.doc(idUser).update({
        'writePermission': permission,
      });

      group.members!.firstWhere((member) => member['id'] == idUser)['writePermission'] = permission;
      
      return group;
    } catch(e) {
      print('Error al dar permisos al usuario: $e');
      return null;
    }
  }

  Future<Group?> userAdmin(Group group, String idUser, bool admin) async {
    try {
      final membersRef = FirebaseFirestore.instance
          .collection('Group')
          .doc(group.id)
          .collection('Members');

      if (admin) {
        await membersRef.doc(idUser).update({
          'type': "Admin",
        });

        group.members!.firstWhere((member) => member['id'] == idUser)['writePermission'] = "Admin";
      } else {
        ChatUser? user = await UserServiceFirebase().getUserByID(idUser);

        await membersRef.doc(idUser).update({
          'type': user?.type,
        });

        group.members!.firstWhere((member) => member['id'] == idUser)['writePermission'] = user?.type;
      }

      userPermission(group, idUser, true);
      
      return group;
    } catch(e) {
      print('Error al dar permisos al usuario: $e');
      return null;
    }
  }

  Future<Group?> deleteUser(Group group, String idUser) async {
    try {
      await FirebaseFirestore.instance
          .collection('Group')
          .doc(group.id)
          .collection('Members')
          .doc(idUser)
          .delete();

      group.members?.removeWhere((member) => member['id'] == idUser);

      if (group.type == "Grupos de asignaturas con profesores") {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Group')
            .where("idTeacherGroup", isEqualTo: group.id)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
          
          await documentSnapshot.reference
              .collection('Members')
              .doc(idUser)
              .delete();
          
          group.members?.removeWhere((member) => member['id'] == idUser);
        }

        List<String> updatedSubjects = [];
        ChatUser? user = await UserServiceFirebase().getUserByID(idUser);

        if (user?.subject != null) {
          updatedSubjects = List<String>.from(user?.subject as Iterable);
          updatedSubjects.remove(group.name);
        }

        await UserServiceFirebase().updateUser(
          user: user,
          subject: updatedSubjects,
        );
      }

      return group;
    } catch (e) { 
      print('Error al eliminar al usuario del grupo: $e');
      return null;
    }
  }
}
