import 'package:ccchat/models/IndividualChat.dart';
import 'package:ccchat/models/User.dart';
import 'package:ccchat/views/styles/responsive.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/groupOptions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import '../../controllers/GroupController.dart';
import '../../controllers/IndividualChatController.dart';
import '../../models/Group.dart';
import '../../models/Message.dart';
import 'components/MyMessageWidget.dart';
import 'components/OtherMessageWidget.dart';

// ignore: must_be_immutable
class Chat extends StatefulWidget {
  ChatUser? userU1, userU2;
  IndividualChat? chat;
  Group? group;

  final Function(Group)? onOptionsGroupSelected;

  Chat(
      {Key? key,
      required this.userU1,
      required this.userU2,
      required this.chat,
      required this.group,
      this.onOptionsGroupSelected})
      : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController sendMessageController = TextEditingController();
  IndividualChatController individualChat = IndividualChatController();
  GroupController group = GroupController();

  AsyncSnapshot<Object?>? auxSnapshot;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 30.0),
      child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
            color: MyColors.background2,
          ),
          width: Responsive.isMobile(context) ? size.width : size.width * 0.4,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: Responsive.isMobile(context) ? 85 : 60,
                decoration: BoxDecoration(
                  borderRadius: Responsive.isMobile(context)
                      ? const BorderRadius.only(bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0))
                      : const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                  color: MyColors.background3,
                ),
                child: Padding(
                  padding: Responsive.isMobile(context)
                      ? const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 20.0, right: 20.0)
                      : const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
                  child: Padding(
                    padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 25) : const EdgeInsets.only(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                          child: SvgPicture.asset('assets/icons/Atras.svg'),
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(),
                            Builder(builder: (context) {
                              if (widget.userU2 == null && widget.chat == null && widget.group == null) {
                                return Container();
                              } else if (widget.userU2 != null && widget.group == null) {
                                if (widget.userU2!.image != null) {
                                  return CircleAvatar(
                                      backgroundImage: MemoryImage(widget.userU2!.image!),
                                      maxRadius: 15.0,
                                      minRadius: 15.0);
                                } else {
                                  return const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'),
                                      maxRadius: 15,
                                      minRadius: 15);
                                }
                              } else if (widget.group != null) {
                                if (widget.group!.image != null) {
                                  return CircleAvatar(
                                      backgroundImage: MemoryImage(widget.group!.image!),
                                      maxRadius: 15.0,
                                      minRadius: 15.0);
                                } else {
                                  return const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'),
                                      maxRadius: 15,
                                      minRadius: 15);
                                }
                              } else {
                                if (widget.chat!.imageU1 != null || widget.chat!.imageU2 != null) {
                                  if (individualChat.isCreatedByMe(widget.chat!, widget.userU1!) == true) {
                                    if (widget.chat!.imageU2 != null) {
                                      return CircleAvatar(
                                          backgroundImage: MemoryImage(widget.chat!.imageU2!),
                                          maxRadius: 15.0,
                                          minRadius: 15.0);
                                    } else {
                                      return const CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'),
                                          maxRadius: 15.0,
                                          minRadius: 15.0);
                                    }
                                  } else {
                                    if (widget.chat!.imageU1 != null) {
                                      return CircleAvatar(
                                          backgroundImage: MemoryImage(widget.chat!.imageU1!),
                                          maxRadius: 15.0,
                                          minRadius: 15.0);
                                    } else {
                                      return const CircleAvatar(
                                          backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'),
                                          maxRadius: 15.0,
                                          minRadius: 15.0);
                                    }
                                  }
                                } else {
                                  return const CircleAvatar(
                                      backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'),
                                      maxRadius: 15,
                                      minRadius: 15);
                                }
                              }
                            }),
                          ],
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: (widget.userU2 == null && widget.chat == null && widget.group == null)
                                ? Container()
                                : (widget.userU2 != null && widget.group == null)
                                    ? Text(widget.userU2!.name!, style: nameGroups(), overflow: TextOverflow.ellipsis)
                                    : (widget.group != null)
                                        ? Text(widget.group!.name!,
                                            style: nameGroups(), overflow: TextOverflow.ellipsis)
                                        : Text(
                                            individualChat.isCreatedByMe(widget.chat!, widget.userU1!) == true
                                                ? widget.chat!.nameU2!
                                                : widget.chat!.nameU1!,
                                            style: nameGroups(),
                                            overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: (widget.userU2 == null && widget.chat == null && widget.group == null)
                              ? Container()
                              : widget.group != null
                                  ? MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (Responsive.isMobile(context)) {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                              return GroupOptions(
                                                onExitChat: () {
                                                  setState(() {
                                                    widget.group = null;
                                                  });
                                                },
                                                group: widget.group,
                                                user: widget.userU1!,
                                                onSubjectChange: (subjectList, newName) {
                                                  setState(() {
                                                    widget.userU1!.subject = subjectList;
                                                    widget.group!.name = newName;
                                                  });
                                                },
                                              );
                                            }));
                                          } else {
                                            widget.onOptionsGroupSelected!(widget.group!);
                                          }
                                        },
                                        child: SizedBox(
                                          width: 40,
                                          child: Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: SvgPicture.asset('assets/icons/Mas.svg'),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              widget.userU2 == null && widget.chat == null && widget.group == null
                  ? Container()
                  : widget.userU2 != null && widget.chat == null && widget.group == null
                      ? FutureBuilder(
                          future: individualChat.getExistsChatIndividual(widget.userU1!, widget.userU2!),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data == null) {
                                //return Container(alignment: Alignment.center, child: const CircularProgressIndicator());
                                return MessageListWidget(
                                  chat: widget.chat,
                                  group: widget.group,
                                  userU1: widget.userU1,
                                  userU2: widget.userU2,
                                  futureBuilderSnapshot: auxSnapshot,
                                );
                              } else {
                                auxSnapshot = snapshot;
                                return MessageListWidget(
                                  chat: widget.chat,
                                  group: widget.group,
                                  userU1: widget.userU1,
                                  userU2: widget.userU2,
                                  futureBuilderSnapshot: snapshot,
                                );
                              }
                            } else {
                              return Container();
                            }
                          },
                        )
                      : MessageListWidget(
                          chat: widget.chat, group: widget.group, userU1: widget.userU1, userU2: widget.userU2),
              Padding(
                padding: Responsive.isMobile(context)
                    ? const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 20.0, right: 20.0)
                    : const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
                child: Material(
                  borderRadius: BorderRadius.circular(15.0),
                  color: MyColors.background3,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: RawKeyboardListener(
                            focusNode: FocusNode(),
                            onKey: (RawKeyEvent event) async {
                              if (!Responsive.isMobile(context)) {
                                if (event is RawKeyDownEvent &&
                                    event.logicalKey == LogicalKeyboardKey.enter &&
                                    !event.isShiftPressed) {
                                  String message = sendMessageController.text.trim();

                                  if (message.isNotEmpty) {
                                    if (widget.group != null) {
                                      await group.sendMessage(message, widget.userU1, widget.group, context);
                                    } else {
                                      IndividualChat newChat = await individualChat.sendMessage(
                                          message, widget.userU1, widget.userU2, widget.chat, context);
                                      if (newChat.id != "") {
                                        if (newChat.hashCode != widget.chat.hashCode) {
                                          setState(() {
                                            widget.userU2 = null;
                                            widget.chat = newChat;
                                          });
                                        }
                                      }
                                    }
                                  }

                                  sendMessageController.clear();
                                  setState(() {});
                                }
                              }
                            },
                            child: TextField(
                              controller: sendMessageController,
                              cursorColor: MyColors.green,
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
                              ),
                              style: messagesGroup2(),
                              textAlignVertical: TextAlignVertical.center,
                              maxLines: 5,
                              minLines: 1,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                          child: Container(
                            width: 40,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              color: MyColors.yellow,
                            ),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  onTap: () async {
                                    if (widget.group != null) {
                                      await group.sendMessage(
                                          sendMessageController.text, widget.userU1, widget.group, context);
                                    } else {
                                      IndividualChat newChat = await individualChat.sendMessage(
                                          sendMessageController.text,
                                          widget.userU1,
                                          widget.userU2,
                                          widget.chat,
                                          context);
                                      if (newChat.id != "") {
                                        if (newChat.hashCode != widget.chat.hashCode) {
                                          setState(() {
                                            widget.userU2 = null;
                                            widget.chat = newChat;
                                          });
                                        }
                                      }
                                    }

                                    sendMessageController.clear();
                                    setState(() {});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SvgPicture.asset('assets/icons/Enviar.svg'),
                                  ),
                                ),
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
          )),
    );
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}

class MessageListWidget extends StatefulWidget {
  final IndividualChat? chat;
  final Group? group;
  final ChatUser? userU1;
  final ChatUser? userU2;
  final AsyncSnapshot<Object?>? futureBuilderSnapshot;

  const MessageListWidget(
      {super.key,
      required this.chat,
      required this.group,
      required this.userU1,
      required this.userU2,
      this.futureBuilderSnapshot});

  @override
  State<MessageListWidget> createState() => MessageListWidgetState();
}

class MessageListWidgetState extends State<MessageListWidget> {
  GroupController group = GroupController();
  IndividualChatController individualChat = IndividualChatController();

  @override
  Widget build(BuildContext context) {
    if (widget.userU2 != null && widget.futureBuilderSnapshot == null) {
      return const Center(child: CircularProgressIndicator(color: MyColors.yellow));
    } else {
      return StreamBuilder<List<Message>>(
        stream: (widget.chat == null && widget.group != null) || (widget.userU2 == null && widget.group != null)
            ? group.getChatMessagesStream(widget.group!, widget.userU1!)
            : (widget.userU2 == null && widget.chat != null)
                ? individualChat.getChatMessagesStream(widget.chat!, widget.userU1!)
                : individualChat.getChatMessagesStream(
                    widget.futureBuilderSnapshot?.data as IndividualChat, widget.userU1!),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Error al obtener los mensajes');
          }
          List<Message>? messages = snapshot.data;

          if (messages == null || messages.isEmpty) {
            return Container();
          }

          return Expanded(
            child: ListView.builder(
              reverse: true, // Scroll desde abajo hacia arriba
              itemCount: messages.length,
              itemBuilder: (context, index) {
                Message message = messages[index];
                bool areTheSameDate = false;
                if (index == messages.length - 1) {
                  areTheSameDate = false;
                } else {
                  areTheSameDate = IndividualChatController().areTheSameDate(message.hour, messages[index + 1].hour);
                }

                bool isMyMessage = message.userId == widget.userU1!.id;

                return Column(
                  crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    areTheSameDate
                        ? const SizedBox(height: 0, width: 0)
                        : Padding(
                            padding: Responsive.isMobile(context)
                                ? const EdgeInsets.symmetric(horizontal: 20.0)
                                : const EdgeInsets.symmetric(horizontal: 52.5),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  height: 0.5,
                                  color: MyColors.grey,
                                )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(IndividualChatController().readDay(message.hour), style: hour()),
                                ),
                                Expanded(
                                    child: Container(
                                  height: 0.5,
                                  color: MyColors.grey,
                                ))
                              ],
                            ),
                          ),
                    isMyMessage
                        ? MyMessageWidget(
                            name: message.userName,
                            hour: message.hour,
                            message: message.message,
                          )
                        : OtherMessageWidget(
                            name: message.userName,
                            hour: message.hour,
                            message: message.message,
                            type: message.type,
                          ),
                  ],
                );
              },
            ),
          );
        },
      );
    }
  }
}
