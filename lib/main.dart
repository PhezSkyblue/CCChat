import 'package:ccchat/controllers/UserController.dart';
import 'package:ccchat/views/HomeView.dart';
import 'package:ccchat/views/SignView.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'models/User.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  UserController user = UserController();
  ChatUser? cacheUser;

  if (kIsWeb) {
    cacheUser = await user.getUserFromSharedPreferences();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
  } else {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    cacheUser = await user.getUserFromSharedPreferences();
  }

  runApp(MaterialApp(
    theme: ThemeData(primaryColor: MyColors.background4),
    color: MyColors.background4,
    title: 'CCChat',
    home: (cacheUser != null) ? HomeView(user: cacheUser) : const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SignView();
  }
}
