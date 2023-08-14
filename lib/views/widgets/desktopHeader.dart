import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';

import '../../models/User.dart';

class DesktopHeader extends StatefulWidget {
  final ChatUser user;

  const DesktopHeader({Key? key, required this.user})
      : super(key: key);

  @override
  State<DesktopHeader> createState() => _DesktopHeaderState();
}

class _DesktopHeaderState extends State<DesktopHeader> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      color: MyColors.background4,
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 45.0, right: 30.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                const Image(image: AssetImage('../assets/images/Logo.png'), width: 60),
                const Padding(padding: EdgeInsets.only(left: 15.0)),
                Text('CCChat', style: appName())
              ],
            ),

            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.user.name!, style: userName()),
                    Text(widget.user.type!, style: widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado" ? studentType() : teacherType()),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(left: 15.0)),
                widget.user.image != null
                  ? CircleAvatar(backgroundImage: MemoryImage(widget.user.image!))
                  : const CircleAvatar(backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
