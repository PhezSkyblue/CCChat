import 'package:ccchat/models/IndividualChat.dart';
import 'package:ccchat/models/User.dart';
import 'package:ccchat/services/IndividualChatServiceFirebase.dart';
import 'package:ccchat/views/styles/responsive.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/Group.dart';
import '../../services/GroupServiceFirebase.dart';

class Chat extends StatefulWidget {
  final ChatUser? userU1, userU2;
  final IndividualChat? chat;
  final Group? group;
  
  const Chat({Key? key, required this.userU1, required this.userU2, required this.chat, required this.group}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController sendMessageController= TextEditingController();

  @override
  Widget build(BuildContext context) {
    print("Chat: " + widget.chat.toString());
    print("User: " + widget.userU2.toString());
    print("Group: " + widget.group.toString());
    var size = MediaQuery.of(context).size;
    return 
    Padding(
      padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          color: MyColors.background2,
        ),
        width: size.width * 0.4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: Responsive.isMobile(context) ? BorderRadius.zero : const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                color: MyColors.background3,
              ),
              child: Padding(
                padding: Responsive.isMobile(context) ? const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 20.0, right: 20.0) : const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Responsive.isMobile(context)
                      ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SizedBox(
                            width: 40,
                            child: Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: SvgPicture.asset('../assets/icons/Atras.svg'),
                            ),
                          ),
                        ),
                      )

                      : Container(),

                    widget.userU2 == null && widget.chat == null && widget.group == null
                      ? Container()
                      : const CircleAvatar(backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 15.0, minRadius: 15.0),
                    
                    const Padding(padding: EdgeInsets.all(5.0)),
                     
                    widget.userU2 == null && widget.chat == null && widget.group == null
                      ? Container()
                      : (widget.userU2 != null && widget.group == null)
                        ? Text(widget.userU2!.name!, style: nameGroups(), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)
                        : (widget.group != null)
                          ? Text(widget.group!.name!, style: nameGroups(), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)
                          : Text(
                            IndividualChatServiceFirebase().isCreatedByMe(widget.chat!, widget.userU1!) == true
                              ? widget.chat!.nameU2!
                              : widget.chat!.nameU1!,
                            style: nameGroups(), 
                            textAlign: TextAlign.center, 
                            overflow: TextOverflow.ellipsis
                          ),
                  ],
                ),
              ),
            ),
            
            Container(),

            Padding(
              padding: Responsive.isMobile(context) ? const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 20.0, right: 20.0) : const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
              child: Material(
                borderRadius: BorderRadius.circular(15.0),
                color: MyColors.background3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: TextField(
                          controller: sendMessageController,
                          decoration: InputDecoration(
                            hintText: 'Escribe aquí...',
                            hintStyle: messagesGroup(),
                            hintMaxLines: 1,
                            filled: true,
                            fillColor: MyColors.background3,
                            enabledBorder: themeTextField(),
                            focusedBorder: themeTextField(),
                            errorBorder: themeTextField(),
                            disabledBorder: themeTextField(),
                            focusedErrorBorder: themeTextField(),
                          )
                          ,
                          style: messagesGroup2(),
                          textAlignVertical: TextAlignVertical.center,

                          onSubmitted: (value) async {
                            if (!Responsive.isMobile(context)) {
                              if (widget.group != null) {
                                await GroupServiceFirebase().sendMessage(sendMessageController.text, widget.userU1, widget.group);
                              } else {
                                await IndividualChatServiceFirebase().sendMessage(sendMessageController.text, widget.userU1, widget.userU2, widget.chat);
                              }
                              sendMessageController.clear();
                            }
                          },
                        ),
                      ),

                      const Padding(padding: EdgeInsets.only(left: 5.0)),

                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: MyColors.yellow,
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async { 
                              if (widget.group != null) {
                                await GroupServiceFirebase().sendMessage(sendMessageController.text, widget.userU1, widget.group);
                              } else {
                                await IndividualChatServiceFirebase().sendMessage(sendMessageController.text, widget.userU1, widget.userU2, widget.chat);
                              }
                              sendMessageController.clear();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset('../assets/icons/Enviar.svg'),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}