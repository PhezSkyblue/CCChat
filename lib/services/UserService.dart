import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/User.dart';

abstract class UserService {
  Future<ChatUser?> register(
    String name,
    String email,
    String type,
    String password,
    String career,
  ); 

  Future<ChatUser?> getUserByEmail(String email);

  Future<ChatUser?> getUserByID(String id);

  CollectionReference getListOfUsers();
}
