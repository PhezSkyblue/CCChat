import 'package:ccchat/models/IndividualChat.dart';
import 'package:ccchat/views/widgets/chat.dart';
import 'package:ccchat/views/widgets/listChats.dart';
import 'package:ccchat/views/widgets/mobileMenu.dart';
import 'package:ccchat/views/widgets/profile.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/Group.dart';
import 'styles/responsive.dart';
import 'widgets/desktopMenu.dart';
import 'widgets/desktopHeader.dart';
import 'package:ccchat/models/User.dart';

class HomeView extends StatefulWidget {
  final ChatUser user;

  const HomeView({Key? key, required this.user}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String selectedList = "Chats individuales";
  IndividualChat? selectedChat = null;
  ChatUser? selectedUser = null;
  Group? selectedGroup = null;
  bool recargar = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    if (Responsive.isDesktop(context) || Responsive.isTablet(context)) {
      return Scaffold(
        backgroundColor: MyColors.background4,
        body: Column(
          children: [
            DesktopHeader(user: widget.user),
            Container(
              color: MyColors.background3,
              width: size.width,
              height: 2.0,
            ),
            Expanded(
              child: Row(
                children: [
                  DesktopMenu(
                    onItemSelected: (list) {
                      setState(() {
                        selectedList = list;
                      });
                    }, 
                    user: widget.user,
                  ),

                  if (selectedList == 'Chats individuales' ||
                      selectedList == 'Grupos difusión' ||
                      selectedList == 'Grupos de asignaturas con profesores' ||
                      selectedList == 'Grupos de asignaturas solo alumnos')
                    SizedBox(
                      child: ListChats(
                        user: widget.user,
                        list: selectedList,
                        onChatSelected: (chat) {
                          setState(() {
                            selectedChat = chat;
                            selectedUser = null;
                            selectedGroup = null;
                          });
                        }, 
                        onUserSelected: (user) {
                          setState(() {
                            selectedUser = user;
                            selectedChat = null;
                            selectedGroup = null;
                          });
                        },
                        onGroupSelected: (group) {
                          setState(() {
                            selectedUser = null;
                            selectedChat = null;
                            selectedGroup = group;
                          });
                        },
                      ),
                    ),

                  if (selectedList == 'Ajustes')
                    Settings(user: widget.user),

                  if (selectedList != 'Perfil' &&
                      selectedList != 'Chats individuales' &&
                      selectedList != 'Grupos difusión' &&
                      selectedList != 'Grupos de asignaturas con profesores' &&
                      selectedList != 'Grupos de asignaturas solo alumnos' &&
                      selectedList != 'Ajustes')
                    SizedBox(
                      height: size.height - 90,
                      child: Container(),
                    ),

                  Expanded(
                    child: Chat(
                      userU1: widget.user, 
                      userU2: selectedUser, 
                      chat: selectedChat, 
                      group: selectedGroup,
                    )
                  ),
                  
                  Profile(user: widget.user)
                ],
              ),
            )
          ],
        )
      );
    } else {
      return Scaffold(
        backgroundColor: MyColors.background4,
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  if (selectedList == 'Perfil')
                    SizedBox(
                      height: size.height - 90,
                      child: Profile(user: widget.user)
                      ),
                  if (selectedList == 'Chats individuales' ||
                      selectedList == 'Grupos difusión' ||
                      selectedList == 'Grupos de asignaturas con profesores' ||
                      selectedList == 'Grupos de asignaturas solo alumnos')
                    SizedBox(
                      height: size.height - 90,
                      child: ListChats(
                        user: widget.user,
                        list: selectedList,
                        onChatSelected: (chat) {
                          setState(() {
                            selectedChat = chat;
                            selectedUser = null;
                          });
                        }, 
                        onUserSelected: (user) {
                          setState(() {
                            selectedUser = user;
                            selectedChat = null;
                          });
                        },
                      ),
                    ),
                  if (selectedList == 'Ajustes')
                    SizedBox(
                      height: size.height - 90,
                      child: Settings(user: widget.user),
                    ),
                  if (selectedList != 'Perfil' &&
                      selectedList != 'Chats individuales' &&
                      selectedList != 'Grupos difusión' &&
                      selectedList != 'Grupos de asignaturas con profesores' &&
                      selectedList != 'Grupos de asignaturas solo alumnos' &&
                      selectedList != 'Ajustes')
                    SizedBox(
                      height: size.height - 90,
                      child: Container(),
                    ),
                ],
              ),
            ),

            MobileMenu(
              onItemSelected: (list) {
                setState(() {
                  selectedList = list;
                });
              }
            ),
          ],
        )
      );
    }
  }
}
