import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/controllers/UserController.dart';
import 'package:ccchat/models/RSAKeyPair.dart';
import '../models/PrivateKeyString.dart';
import '../models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'UserService.dart';

class UserServiceFirebase implements UserService {
  @override
  Future<ChatUser?> register(
    String name,
    String email,
    String type,
    String password,
    String career
  ) async {
    try {
      ChatUser? existingUser = await getUserByEmail(email);

      if (existingUser != null) {
        if (existingUser.emailVerified == true) {
          print('El email $email ya ha sido registrado.');
          return null;
        } else {
          await UserController().deleteUser(id: existingUser.id);
        }
      }

      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userID = userCredential.user!.uid;

      RSAKeyPair keyPair = RSAController().generateRSAKeys();
      String hash = HASHController().generateHash(password);
      
      PrivateKeyString encryptedPrivateKey = AESController()
        .privateKeyEncryption(hash, keyPair.publicKey, keyPair.privateKey);

      await FirebaseFirestore.instance.collection('User').doc(userID).set({
        'id': userID,
        'name': name,
        'email': email,
        'type': type,
        'image': null,
        'emailVerified': false,
        'publicKeyModulus' : keyPair.publicKey.modulus.toString(), 
        'publicKeyExponent' : keyPair.publicKey.exponent.toString(),
        'privateKeyModulus' : encryptedPrivateKey.modulus.toString(),
        'privateKeyPrivateExponent' : encryptedPrivateKey.privateExponent.toString(),
        'privateKeyP' : encryptedPrivateKey.p.toString(), 
        'privateKeyQ' : encryptedPrivateKey.q.toString(),
        'subject' : List<String>.empty()
      });

      if(type == "Alumno") {
        await FirebaseFirestore.instance.collection('User').doc(userID).update({
          'career': career,
        });
      }

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
        ChatUser u = ChatUser.fromJson(data);
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
    CollectionReference notesItemCollection = FirebaseFirestore.instance.collection('User');
    return notesItemCollection;
  }
}
