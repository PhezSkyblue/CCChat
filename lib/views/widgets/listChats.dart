import 'dart:async';

import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/components/IndividualChatWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/Group.dart';
import '../../models/IndividualChat.dart';
import '../../models/User.dart';
import '../../services/GroupServiceFirebase.dart';
import '../../services/IndividualChatServiceFirebase.dart';

import '../../services/UserServiceFirebase.dart';
import '../styles/responsive.dart';
import 'chat.dart';
import 'components/GroupWidget.dart';

class ListChats extends StatefulWidget {
  final String list;
  final ChatUser user;
  
  final Function(IndividualChat)? onChatSelected;
  final Function(ChatUser)? onUserSelected;
  final Function(Group)? onGroupSelected;

  const ListChats({Key? key, required this.list, required this.user, this.onChatSelected, this.onUserSelected, this.onGroupSelected}) : super(key: key);

  @override
  State<ListChats> createState() => _ListChatsState();
}

class _ListChatsState extends State<ListChats> {
  TextEditingController searchController = TextEditingController();
  IndividualChatServiceFirebase individualChat = IndividualChatServiceFirebase();
  GroupServiceFirebase group = GroupServiceFirebase();
  UserServiceFirebase user = UserServiceFirebase();

  bool isTextFieldEmpty = true;
  StreamSubscription<List<IndividualChat>>? _chatSubscription;
  StreamSubscription<List<Group>>? _groupSubscription;
  List<IndividualChat> _chatList = [];
  List<Group> _groupList = [];

  @override
  void initState() {
    super.initState();
    searchController.addListener(textFieldListener);
    _chatSubscription = individualChat
      .listenToListOfChats(widget.user.id)
      .listen((chats) {
        setState(() {
          _chatList = chats;
          _chatList.sort((b, a) => a.hour!.compareTo(b.hour!));
        });
      });

    _subscribeToGroupList();
  }

  @override
  void dispose() {
    _chatSubscription?.cancel();
    _groupSubscription?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void textFieldListener() {
    setState(() {
      isTextFieldEmpty = searchController.text.isEmpty;
    });
  }

  @override
  void didUpdateWidget(ListChats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.list != oldWidget.list) {
      _groupSubscription?.cancel();
      _subscribeToGroupList();
    }
  }

  void _subscribeToGroupList() {
    _groupSubscription = group
      .listenToListOfGroups(widget.user.id, widget.list)
      .listen((groups) {
        setState(() {
          _groupList = groups;
          _groupList.sort((b, a) => a.hour!.compareTo(b.hour!));
        });
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
                    buildGroupListItem(widget.list),
                  if (widget.list == 'Grupos de asignaturas con profesores')
                    buildGroupListItem(widget.list),
                  if (widget.list == 'Grupos de asignaturas solo alumnos')
                    buildGroupListItem(widget.list),
                  if (widget.list == 'Grupo de departamento')
                    buildGroupListItem(widget.list),
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

    void _selectGroup(Group group) {
    setState(() {
      widget.onGroupSelected!(group);
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
        ? ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _chatList.length,
            itemBuilder: (context, index) {
              IndividualChat individualChat = _chatList[index];
              return IndividualChatList(
                user: widget.user,
                individualChat: individualChat,
                selectChat: _selectChat,
              );
            },
          )

        : SingleChildScrollView(
            child: FutureBuilder<List<ChatUser?>>(
              future: user.getUsersContainsString(searchController.text, widget.user.id),
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
                                  return Chat(userU1: widget.user, userU2: user!, chat: null, group: null);
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
                  return Container(); 
                }
              },
            ),
          )
      ],
    );
  }

  Widget buildGroupListItem(String type) {
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
        ? ListView.builder(
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
            itemCount: _groupList.length,
            itemBuilder: (context, index) {
              Group group = _groupList[index];
              return GroupList(
                user: widget.user,
                group: group,
                selectGroup: _selectGroup,
              );
            },
          )

        : SingleChildScrollView(
            child: FutureBuilder<List<Group?>>(
              future: group.getGroupsContainsString(searchController.text, widget.user.id, type),
              builder: (context, snapshot) {
                
                if (snapshot.hasData) {
                  List<Group?> groups = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      Group? group = groups[index];

                      return Padding(
                        padding: const EdgeInsets.only(top: 15.0),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Responsive.isMobile(context)
                            ? Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return Chat(userU1: widget.user, userU2: null, chat: null, group: group);
                                })
                              )
                            : _selectGroup(group!),

                            child: GroupWidget(
                              name: group!.name,
                              hour: group.hour,
                              message: group.lastMessage,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Container(); 
                }
              },
            ),
          )
      ],
    );
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}

class IndividualChatList extends StatefulWidget {
  final ChatUser user;
  final IndividualChat individualChat;
  final Function(IndividualChat) selectChat;


  const IndividualChatList({super.key, required this.user, required this.individualChat, required this.selectChat});

  @override
  State<IndividualChatList> createState() => _IndividualChatListState();
}

class _IndividualChatListState extends State<IndividualChatList> {

  @override
  Widget build(BuildContext context) {
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
                  return Chat(userU1: widget.user, userU2: null, chat: widget.individualChat, group: null);
                })
              )
            : widget.selectChat(widget.individualChat),
        
            child: IndividualChatWidget(
              name: IndividualChatServiceFirebase().isCreatedByMe(widget.individualChat, widget.user) ? widget.individualChat.nameU2 : widget.individualChat.nameU1,
              type: IndividualChatServiceFirebase().isCreatedByMe(widget.individualChat, widget.user) ? widget.individualChat.typeU2 : widget.individualChat.typeU1,
              hour: widget.individualChat.hour,
              message: widget.individualChat.lastMessage,
            ),
          ),
        ),
      ),
    );
  }
}

class GroupList extends StatefulWidget {
  final ChatUser user;
  final Group group;
  final Function(Group) selectGroup;


  const GroupList({super.key, required this.user, required this.group, required this.selectGroup});

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {

  @override
  Widget build(BuildContext context) {
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
                  return Chat(userU1: widget.user, group: widget.group, chat: null, userU2: null);
                })
              )
            : widget.selectGroup(widget.group),
        
            child: GroupWidget(
              name: widget.group.name,
              hour: widget.group.hour,
              message: widget.group.lastMessage,
            ),
          ),
        ),
      ),
    );
  }
}