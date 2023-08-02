import 'package:ccchat/services/UserServiceFirebase.dart';
import 'package:ccchat/views/HomeView.dart';
import 'package:ccchat/views/SignView.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/User.dart';


Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  UserServiceFirebase user = UserServiceFirebase();
  ChatUser? webStoredUser, cacheUser;

  if (kIsWeb) {
    webStoredUser = await user.getUserFromWebStorage();
  } else {
    cacheUser = await user.getUserFromSharedPreferences();
  }


  runApp(MaterialApp(
    title: 'CCChat',
    home: (cacheUser != null || webStoredUser != null) ? HomeView(user: cacheUser ?? webStoredUser!) : const MyApp(),
  ));
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CCChat',
      home: SignView(),
    );
  }
}
