import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/styles/styles.dart';
import 'UserService.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final CollectionReference _Collection = _firestore.collection('/User');

class UserServiceFirebase implements UserService {

  @override
  Future<ChatUser?> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = userCredential.user;
    
      if (firebaseUser != null) {
        ChatUser? chatUser = await getUserByEmail(email);

        if(chatUser != null && (chatUser.type == "Admin" || firebaseUser.emailVerified)) {
          if (kIsWeb) {
            saveUserToWebStorage(chatUser!); //Navegator
          } else {
            await saveUserToSharedPreferences(chatUser!); //Mobile
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
      print('Los datos introduccidos son incorrectos');
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
  }

  @override
  Future<ChatUser?> register(
    String name,
    String email,
    String type,
    String password,
  ) async {
    try {
      ChatUser? existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        print('El email $email ya ha sido registrado.');
        return null;
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('User').doc(userID).set({
        'id': userID,
        'name': name,
        'email': email,
        'type': type,
      });

      await userCredential.user!.sendEmailVerification();

      ChatUser chatUser = ChatUser.builderWithID(userID, name, email, type);

      return chatUser;
    } catch (e) {
      print('Error al registrar el usuario: $e');
      return null;
    }
  }

  @override
  Future<ChatUser?> getUserByEmail(String email) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('User')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        ChatUser u = ChatUser.fromJson(data, );
        return u;
      } else {
        print('No se encontró ningún usuario con el email proporcionado.');
        return null;
      }
    } catch (e) {
      print('Error al obtener el usuario por email: $e');
      return null;
    }
  }

  @override
  Future<ChatUser?> getUserByID(String id) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot documentSnapshot = await firestore
          .collection('User')
          .doc(id)
          .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;
        ChatUser u = ChatUser.fromJson(data);
        return u;
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
  CollectionReference getListOfUsers() {
    CollectionReference notesItemCollection = _Collection;
    return notesItemCollection;
  }

  @override
  Future<bool> updateUser({
    String? id,
    String? name,
    String? password,
    String? departament,
    List<String>? subject,
  }) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('User').doc(id);

      Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (password != null) updateData['password'] = password;
      if (departament != null) updateData['departament'] = departament;
      if (subject != null) updateData['subject'] = subject;

      await userRef.update(updateData);

      if (password != null) {
        User? firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null) {
          await firebaseUser.updatePassword(password);
        }
      }

      return true;
    } catch (e) {
      print('Error al actualizar el usuario: $e');
      return false;
    }
  }
  
  @override
  Future<bool> deleteUser({required String id}) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference usersCollection = firestore.collection('User');
      DocumentReference userRef = usersCollection.doc(id);

      await userRef.delete();

      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
      }
      return true;
    } catch (e) {
      print('Error al eliminar el usuario: $e');
      return false;
    }
  }

  @override
  Future<List<ChatUser?>> getUsersContainsString(String search, String id) async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .get();

      final List<ChatUser?> users = querySnapshot.docs
          .map((doc) => ChatUser.fromJson(doc.data() as Map<String, dynamic>))
          .where((user) =>
              (user.name?.toUpperCase().contains(search.toUpperCase()) == true ||
                user.email?.toUpperCase().contains(search.toUpperCase()) == true) &&
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
  }

  // Get user from browser storage
  Future<ChatUser?> getUserFromWebStorage() async {
    String? userEmail = html.window.localStorage['user_email'];
    
    if (userEmail != null) {
      return getUserByEmail(userEmail);
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
  }

  // Get user from SharedPreferences
  Future<ChatUser?> getUserFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userEmail = prefs.getString('user_email');
    
    if (userEmail != null) {
      return getUserByEmail(userEmail);
    } else {
      return null;
    }
  }

  void clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user_email');
  }

}
