import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/components/individualChatWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/IndividualChat.dart';
import '../../models/User.dart';
import '../../services/IndividualChatServiceFirebase.dart';
import '../../services/UserServiceFirebase.dart';
import '../styles/responsive.dart';
import 'chat.dart';

class ListChats extends StatefulWidget {
  final String list;
  final ChatUser user;
  
  final Function(IndividualChat)? onChatSelected;
  final Function(ChatUser)? onUserSelected;

  const ListChats({Key? key, required this.list, required this.user, this.onChatSelected, this.onUserSelected}) : super(key: key);

  @override
  State<ListChats> createState() => _ListChatsState();
}

class _ListChatsState extends State<ListChats> {
  TextEditingController searchController = TextEditingController();
  bool isTextFieldEmpty = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(textFieldListener);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void textFieldListener() {
    setState(() {
      isTextFieldEmpty = searchController.text.isEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
      child: SizedBox(
        width: size.width * 0.2,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (widget.list == 'Chats individuales')
                    buildIndividualChatsListItem(),
                  if (widget.list == 'Grupos difusión')
                    buildGroupListItem("Difusión"),
                  if (widget.list == 'Grupos de asignaturas con profesores')
                    buildGroupListItem("Profesores"),
                  if (widget.list == 'Grupos de asignaturas solo alumnos')
                    buildGroupListItem("Alumnos"),
                  if (widget.list == 'Grupo de departamento')
                    buildGroupListItem("Departamento"),
                  if (widget.list != 'Chats individuales' &&
                      widget.list != 'Grupos difusión' &&
                      widget.list != 'Grupos de asignaturas con profesores' &&
                      widget.list != 'Grupos de asignaturas solo alumnos' &&
                      widget.list != 'Grupo de departamento')
                    Container(),
                ],
              ),
            ),
            
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
          ],
        )
      ),
    );
  }

  void _selectChat(IndividualChat chat) {
    setState(() {
      widget.onChatSelected!(chat);
    });
  }

  void _selectUser(ChatUser user) {
    setState(() {
      widget.onUserSelected!(user);
    });
  }

  Widget buildIndividualChatsListItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: MyColors.background3,
          ),

          child: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SvgPicture.asset('../assets/icons/Buscar.svg'),
                  ),
                ),

                const Padding(padding: EdgeInsets.only(left: 5.0)),
                
                Flexible(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      hintStyle: searcher(),
                      filled: true,
                      fillColor: MyColors.background3,
                      enabledBorder: themeTextField(),
                      focusedBorder: themeTextField(),
                      errorBorder: themeTextField(),
                      disabledBorder: themeTextField(),
                      focusedErrorBorder: themeTextField(),
                    ), 
                    style: searcher2(),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const Padding(padding: EdgeInsets.only(top: 10.0, bottom: 20.0)),

        Text(widget.list, style: title()),

        isTextFieldEmpty
        ? FutureBuilder<List<IndividualChat>>(
          future: IndividualChatServiceFirebase().getListOfChats(widget.user.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<IndividualChat> individualChats = snapshot.data!;
              return SingleChildScrollView(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: individualChats.length,
                  itemBuilder: (context, index) {
                    IndividualChat individualChat = individualChats[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            overlayColor: MaterialStateProperty.all(Colors.transparent),
                            onTap: () => Responsive.isMobile(context)
                            ? Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return Chat(userU1: widget.user, userU2: null, chat: individualChat);
                                })
                              )
                            : _selectChat(individualChat),
                        
                            child: IndividualChatWidget(
                              name: IndividualChatServiceFirebase().isCreatedByMe(individualChat, widget.user) ? individualChat.nameU2 : individualChat.nameU1,
                              type: IndividualChatServiceFirebase().isCreatedByMe(individualChat, widget.user) ? individualChat.typeU2 : individualChat.typeU1,
                              hour: individualChat.hour,
                              message: individualChat.lastMessage,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Container();
            }
          },
        )

        : SingleChildScrollView(
            child: FutureBuilder<List<ChatUser?>>(
              future: UserServiceFirebase().getUsersContainsString(searchController.text, widget.user.id),
              builder: (context, snapshot) {
                
                if (snapshot.hasData) {
                  List<ChatUser?> users = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      ChatUser? user = users[index];

                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Responsive.isMobile(context)
                            ? Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return Chat(userU1: widget.user, userU2: user!, chat: null);
                                })
                              )
                            : _selectUser(user!),

                            child: IndividualChatWidget(
                              name: user?.name,
                              type: user?.type,
                              hour: Timestamp.fromDate(DateTime(1970, 1, 1, 0, 0)),
                              message: " ",
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Container(); // Mostrar un indicador de carga o un mensaje de que no hay datos.
                }
              },
            ),
          )
      ],
    );
  }

  Widget buildGroupListItem(String type) {
    return FutureBuilder<List<IndividualChat>>(
      future: IndividualChatServiceFirebase().getListOfChats(widget.user.id),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<IndividualChat> individualChats = snapshot.data!;
          return SingleChildScrollView(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: individualChats.length,
              itemBuilder: (context, index) {
                IndividualChat individualChat = individualChats[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => Container(),
                      child: IndividualChatWidget(
                        name: IndividualChatServiceFirebase().isCreatedByMe(individualChat, widget.user) ? individualChat.nameU2 : individualChat.nameU1,
                        type: IndividualChatServiceFirebase().isCreatedByMe(individualChat, widget.user) ? individualChat.typeU2 : individualChat.typeU1,
                        hour: individualChat.hour,
                        message: individualChat.lastMessage,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}