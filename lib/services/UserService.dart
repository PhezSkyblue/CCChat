import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/User.dart';

abstract class UserService {
  Future<ChatUser?> login(String email, String password, BuildContext context);

  Future<ChatUser?> register(
    String name,
    String email,
    String type,
    String password,
    String career,
  ); 

  Future<ChatUser?> getUserByEmail(String email);

  Future<ChatUser?> getUserByID(String id);

  Future<List<ChatUser?>> getUsersContainsString(String search, String id);

  CollectionReference getListOfUsers();

   Future<ChatUser?> updateUser({
    ChatUser? user,
    String? name,
    String? departament,
    List<String>? subject,
  });

  Future<bool> deleteUser({required String id});
}
