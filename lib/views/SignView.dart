import 'package:ccchat/views/styles/responsive.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/login.dart';
import 'package:ccchat/views/widgets/welcome.dart';
import 'package:flutter/material.dart';

class SignView extends StatefulWidget {
  const SignView({Key? key}) : super(key: key);

  @override
  State<SignView> createState() => _SignViewState();
}

class _SignViewState extends State<SignView> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
      return Scaffold(
        backgroundColor: MyColors.background4,
        body: Row(
          children: [
            const Expanded(
              child: Welcome(),
            ),
            Container(
              color: MyColors.yellow,
              height: size.height,
              width: 2.0,
            ),
            const Expanded(
              child: Login(),
            )
          ],
        )
      );
    } else {
      return const Scaffold(
        backgroundColor: MyColors.background4,
        body: Row(
          children: [
            Expanded(
              child: Welcome(),
            )
          ],
        )
      );
    }
  }
}
