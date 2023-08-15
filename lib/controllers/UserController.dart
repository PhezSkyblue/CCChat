import 'dart:convert';

import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/services/UserServiceFirebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Group.dart';
import '../models/PrivateKeyString.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../views/styles/styles.dart';
import 'GroupController.dart';
import 'IndividualChatController.dart';

class UserController {
  Future<ChatUser?> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
    
      if (firebaseUser != null) {
        ChatUser? chatUser = await getUserByEmail(email);
        
        String hash = HASHController().generateHash(password);
        PrivateKeyString decryptedPrivateKey = AESController()
          .privateKeyDecryption(hash, chatUser!.publicKey!, chatUser.privateKey!);

          chatUser.privateKey = decryptedPrivateKey;

        if (chatUser != null && (chatUser.type == "Admin" || firebaseUser.emailVerified)) {
          updateUser(user: chatUser, emailVerified: true);

          if (kIsWeb) {
            saveUserToWebStorage(chatUser); //Navegator
          } else {
            await saveUserToSharedPreferences(chatUser); //Mobile
          }
        
          return chatUser;
        }
        
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              backgroundColor: MyColors.background3,
              title: Text('Verifica tu correo electrónico', style: TextStyle(color: MyColors.white)),
              content: Text('Por favor, verifica tu correo electrónico antes de iniciar sesión.', style: TextStyle(color: MyColors.white)),
              actions: <Widget>[
                TextButton(
                  child: Text('Cerrar', style: TextStyle(color: MyColors.yellow)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        return null;
      }
    } catch (e) {
      print('Los datos introduccidos son incorrectos: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            backgroundColor: MyColors.background3,
            title: const Text('Error de inicio de sesión', style: TextStyle(color: MyColors.white)),
            content: const Text('Los datos introducidos no son correctos.', style: TextStyle(color: MyColors.white)),
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

    return null;
  }

  Future<ChatUser?> register(
    String name,
    String email,
    String type,
    String password,
    String career,
  ) async {
    return UserServiceFirebase().register(name, email, type, password, career);
  }

  Future<ChatUser?> getUserByEmail(String email) async {
    return UserServiceFirebase().getUserByEmail(email);
  }

  Future<ChatUser?> getUserByID(String id) async {
    return UserServiceFirebase().getUserByID(id);
  }

  CollectionReference getListOfUsers() {
    return UserServiceFirebase().getListOfUsers();
  }

  Future<ChatUser?> updateUser({
    ChatUser? user,
    String? name,
    String? type,
    Uint8List? image,
    String? password,
    String? departament,
    bool? emailVerified,
    List<String>? subject,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('User').doc(user?.id);

      Map<String, dynamic> updateData = {};

      if (name != null) {
        updateData['name'] = name;
        IndividualChatController().updateNameUser(user!.id, name);
      }

      if (type != null) {
        updateData['type'] = type;
        IndividualChatController().updateTypeUser(user!.id, type);

        List<Group> listGroup = await GroupController().getListOfGroups(user.id, "Grupos difusión");

        for (Group group in listGroup) {
          GroupController().updateTypeGroup(group.id, user.id, type, group.type!);
        }

        listGroup = await GroupController().getListOfGroups(user.id, "Grupos de departamentos");

        for (Group group in listGroup) {
          GroupController().updateTypeGroup(group.id, user.id, type, group.type!);
        }

        listGroup = await GroupController().getListOfGroups(user.id, "Grupos de asignaturas con profesores");

        for (Group group in listGroup) {
          GroupController().updateTypeGroup(group.id, user.id, type, group.type!);
        }
      }

      if (image != null) {
        if(base64Encode(image).length >= 1048487) {
          return null;
        } else {
          updateData['image'] = base64Encode(image);
          user?.image = image;
          IndividualChatController().updateImageUser(user!.id, image);
        }
      }

      if (password != null) {
        RSAPrivateKey key = RSAController().getRSAPrivateKey(user!.privateKey!);
        String hash = HASHController().generateHash(password);
        
        PrivateKeyString encryptedPrivateKey = AESController()
          .privateKeyEncryption(hash, user.publicKey!, key);

        await FirebaseFirestore.instance.collection('User').doc(user.id).update({
          'privateKeyModulus' : encryptedPrivateKey.modulus.toString(),
          'privateKeyPrivateExponent' : encryptedPrivateKey.privateExponent.toString(),
          'privateKeyP' : encryptedPrivateKey.p.toString(), 
          'privateKeyQ': encryptedPrivateKey.q.toString(),
        });

        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          firebaseUser.updatePassword(password);
        }
      }

      if (departament != null) updateData['departament'] = departament;
      if (emailVerified != null) updateData['emailVerified'] = emailVerified;
      if (subject != null) updateData['subject'] = subject;

      userRef.update(updateData);

      return user;
    } catch (e) {
      print('Error al actualizar el usuario: $e');
      return null;
    }
  }
  
  Future<bool> deleteUser({required String id}) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference usersCollection = firestore.collection('User');
      DocumentReference userRef = usersCollection.doc(id);

      await userRef.delete();
      
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        IndividualChatController().updateNameUser(id, "Usuario eliminado");

        List<Group> listGroup = await GroupController().getListOfGroups(id, "Grupos difusión");

        for (Group group in listGroup) {
          GroupController().deleteUser(group, id);
        }

        listGroup = await GroupController().getListOfGroups(id, "Grupos de departamentos");

        for (Group group in listGroup) {
          GroupController().deleteUser(group, id);
        }

        listGroup = await GroupController().getListOfGroups(id, "Grupos de asignaturas con profesores");

        for (Group group in listGroup) {
          GroupController().deleteUser(group, id);
        }
      
        await currentUser.delete();
      }
      return true;
    } catch (e) {
      print('Error al eliminar el usuario: $e');
      return false;
    }
  }

  String removeAccents(String? input) {
    if (input != null) {
      final Map<String, String> accentMap = {
        'á': 'a',
        'é': 'e',
        'í': 'i',
        'ó': 'o',
        'ú': 'u',
        'Á': 'A',
        'É': 'E',
        'Í': 'I',
        'Ó': 'O',
        'Ú': 'U',
        'ñ': 'n',
        'Ñ': 'N'
      };

      String result = input;

      accentMap.forEach((key, value) {
        result = result.replaceAll(key, value);
      });

      return result;
    } else {
      return "";
    }
  }

  Future<List<ChatUser?>> getUsersContainsString(String search, String id) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('User').get();

      final List<ChatUser?> users = querySnapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) =>
              (removeAccents(user.name?.toUpperCase()).contains(removeAccents(search.toUpperCase())) == true ||
                  removeAccents(user.email?.toUpperCase()).contains(removeAccents(search.toUpperCase())) == true) &&
              user.id != id)
          .toList();

      return users;
    } catch (e) {
      print('Error buscando usuarios: $e');
      return [];
    }
  }

  // Save user to browser storage
  void saveUserToWebStorage(ChatUser user) {
    html.window.localStorage['user_email'] = user.email!;
    html.window.localStorage['public_key_m'] = user.publicKey!.modulus.toString();
    html.window.localStorage['public_key_e'] = user.publicKey!.exponent.toString();
    html.window.localStorage['key_m'] = user.privateKey!.modulus;
    html.window.localStorage['key_e'] = user.privateKey!.privateExponent;
    html.window.localStorage['key_p'] = user.privateKey!.p;
    html.window.localStorage['key_q'] = user.privateKey!.q;
  }

  // Get user from browser storage
  Future<ChatUser?> getUserFromWebStorage() async {
    String? userEmail = html.window.localStorage['user_email'];
    
    if (userEmail != null) {
      ChatUser? user = await getUserByEmail(userEmail);
      RSAPublicKey publicKey = RSAPublicKey(
        BigInt.parse(html.window.localStorage['public_key_m']!), 
        BigInt.parse(html.window.localStorage['public_key_e']!));

      if (user?.publicKey == publicKey) {
        user?.privateKey?.modulus = html.window.localStorage['key_m']!;
        user?.privateKey?.privateExponent = html.window.localStorage['key_e']!;
        user?.privateKey?.p = html.window.localStorage['key_p']!;
        user?.privateKey?.q = html.window.localStorage['key_q']!;

        return user;
      } else {
        return null;
      }   
    } else {
      return null;
    }
  }

  void clearWebStorage() {
    html.window.localStorage.remove('user_email');
  }

  // Save user in SharedPreferences
  Future<void> saveUserToSharedPreferences(ChatUser user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', user.email!);
    prefs.setString('public_key_m', user.publicKey!.modulus.toString());
    prefs.setString('public_key_e', user.publicKey!.exponent.toString());
    prefs.setString('key_m', user.privateKey!.modulus);
    prefs.setString('key_e', user.privateKey!.privateExponent);
    prefs.setString('key_p', user.privateKey!.p);
    prefs.setString('key_q', user.privateKey!.q);
  }

  // Get user from SharedPreferences
  Future<ChatUser?> getUserFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');
    
    if (userEmail != null) {
      ChatUser? user = await getUserByEmail(userEmail);
      RSAPublicKey publicKey = RSAPublicKey(
        BigInt.parse(prefs.getString('public_key_m')!), 
        BigInt.parse(prefs.getString('public_key_e')!));

      if (user?.publicKey == publicKey) {
        user?.privateKey?.modulus = prefs.getString('key_m')!;
        user?.privateKey?.privateExponent = prefs.getString('key_e')!;
        user?.privateKey?.p = prefs.getString('key_p')!;
        user?.privateKey?.q = prefs.getString('key_q')!;

        return user;
      } else {
        return null;
      }   
    } else {
      return null;
    }
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_email');
  }

}
