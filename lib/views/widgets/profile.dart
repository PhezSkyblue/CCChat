import 'dart:typed_data';

import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';

import '../../models/User.dart';
import '../styles/responsive.dart';

class Profile extends StatefulWidget {
  final ChatUser user;

  const Profile({Key? key, required this.user}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    if (size.width > 1150 || Responsive.isMobile(context)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 20.0, top: 30.0, left: 20.0, right: 20.0),
        child: Container(
          color: MyColors.background4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  color: widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado" ? MyColors.green : MyColors.yellow),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0, top: 40.0, left: 15.0, right: 15.0),
                    child: SizedBox(
                      width: Responsive.isMobile(context) ? size.width : 210.0,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.user.image != null
                              ? CircleAvatar(
                                backgroundImage: MemoryImage(widget.user.image!),
                                maxRadius: 35.0,
                                minRadius: 35.0)
                              : const CircleAvatar(
                                backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'),
                                maxRadius: 35.0,
                                minRadius: 35.0),
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Text(widget.user.name!, style: userName(), textAlign: TextAlign.center),
                            const Padding(padding: EdgeInsets.all(5.0)),
                            Text(widget.user.type!, style: widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado" ? studentType() : teacherType())
                          ],
                        ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0, top: 25.0, left: 25.0, right: 25.0),
                  child: SizedBox(
                    width: Responsive.isMobile(context) ? size.width - 50 : 160.0,
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: widget.user.subject?.length,
                      itemBuilder: (context, index) {
                        if (widget.user.subject != null) {
                          final subject = widget.user.subject?[index];
                          return Text("- $subject", style: messagesChat1());
                        }
                      },
                    ),
                  ),
                )
            ],
          )
        ),
      );
    } else {
      return const Padding(
        padding: EdgeInsets.only(left: 20.0),
      );
    }
  }
}