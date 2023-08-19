import 'package:ccchat/views/widgets/login.dart';
import 'package:flutter/material.dart';

import '../styles/responsive.dart';
import '../styles/styles.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
      return Scaffold(
          backgroundColor: MyColors.background4,
          body: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fondoBienvenida.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: const AssetImage('assets/images/personasBienvenida.png'),
                    height: size.height / 1.6,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0, left: 150.0, right: 150.0),
                    child: Text(
                        textAlign: TextAlign.center,
                        'Empieza la experiencia de comunicarte con tus compañeros de clase y profesores, a solo un CLICK',
                        style: title().copyWith(fontWeight: FontWeight.bold, color: MyColors.white)),
                  ),
                ],
              ),
            ),
          ));
    } else {
      return Scaffold(
          backgroundColor: MyColors.background4,
          body: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/fondoBienvenida.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                        child: Image(
                          image: const AssetImage('assets/images/personasBienvenida.png'),
                          width: size.height / 2.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, top: 60.0, left: 30.0, right: 30.0),
                child: Text(
                    textAlign: TextAlign.center,
                    'Empieza la experiencia de comunicarte con tus compañeros de clase y profesores, a solo un CLICK',
                    style: title().copyWith(fontWeight: FontWeight.bold, color: MyColors.white)),
              ),
              ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                  backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return const Login();
                  }));
                },
                child: Text('Comienza aquí', style: title2().copyWith(fontWeight: FontWeight.bold)),
              ),
            ],
          ));
    }
  }
}
