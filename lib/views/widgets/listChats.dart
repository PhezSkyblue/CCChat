import 'dart:async';

import 'package:ccchat/controllers/AESController.dart';
import 'package:ccchat/controllers/HASHController.dart';
import 'package:ccchat/controllers/RSAController.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/components/IndividualChatWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../controllers/GroupController.dart';
import '../../controllers/IndividualChatController.dart';
import '../../controllers/UserController.dart';
import '../../models/Group.dart';
import '../../models/IndividualChat.dart';
import '../../models/User.dart';
import '../styles/responsive.dart';
import 'chat.dart';
import 'components/GroupWidget.dart';

class ListChats extends StatefulWidget {
  final String list;
  final ChatUser user;

  final Function(IndividualChat)? onChatSelected;
  final Function(ChatUser)? onUserSelected;
  final Function(Group)? onGroupSelected;

  const ListChats(
      {Key? key,
      required this.list,
      required this.user,
      this.onChatSelected,
      this.onUserSelected,
      this.onGroupSelected})
      : super(key: key);

  @override
  State<ListChats> createState() => _ListChatsState();
}

class _ListChatsState extends State<ListChats> {
  TextEditingController searchController = TextEditingController();
  IndividualChatController individualChat = IndividualChatController();
  GroupController group = GroupController();
  UserController user = UserController();

  bool isTextFieldEmpty = true;
  StreamSubscription<List<IndividualChat>>? _chatSubscription;
  StreamSubscription<List<Group>>? _groupSubscription;
  List<IndividualChat> _chatList = [];
  List<Group> _allGroupsList = [];
  List<Group> _currentGroupList = [];
  bool loading_chats = true;
  bool loading_groups = true;

  @override
  void initState() {
    super.initState();
    searchController.addListener(textFieldListener);
    _subscribeToList();
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

    if (oldWidget.list != widget.list && widget.list != "Chats individuales") {
      _currentGroupList = _allGroupsList.where((group) {
        return group.type == widget.list;
      }).toList();
    }
  }

  void _subscribeToList() {
    _chatSubscription?.cancel();
    _chatSubscription = null;
    _chatSubscription = individualChat.listenToListOfChats(widget.user.id).listen((newChatList) {
      if (mounted) {
        newChatList = decryptIndividualChatPrivateKeys(newChatList);
        if (!newChatList.every((newChat) =>
            _chatList.any((oldChat) => oldChat.id == newChat.id && oldChat.lastMessage == newChat.lastMessage))) {
          _chatList = newChatList;
          _chatList.sort((b, a) => a.hour!.compareTo(b.hour!));
        }

        setState(() {
          loading_chats = false;
        });
      }
    });

    _groupSubscription?.cancel();
    _groupSubscription = null;
    _groupSubscription = group.listenToListOfGroups(widget.user.id, widget.list).listen((newGroupList) {
      if (mounted) {
        List<Group> newGroups = [];
        List<Group> oldGroups = [];

        for (var oldGroup in _allGroupsList) {
          bool idExistsInNew = newGroupList.any((newGroup) => newGroup.id == oldGroup.id);
          bool hourMatchesInNew =
              newGroupList.any((newGroup) => newGroup.id == oldGroup.id && newGroup.hour == oldGroup.hour);
          bool nameMatchesInNew =
              newGroupList.any((newGroup) => newGroup.id == oldGroup.id && newGroup.name == oldGroup.name);
          bool imageMatchesInNew =
              newGroupList.any((newGroup) => newGroup.id == oldGroup.id && newGroup.image == oldGroup.image);

          if (idExistsInNew && hourMatchesInNew && nameMatchesInNew && imageMatchesInNew) {
            oldGroups.add(oldGroup);
          }
        }

        for (var newGroup in newGroupList) {
          bool idExistsInOld = _allGroupsList.any((oldGroup) => oldGroup.id == newGroup.id);
          bool hourMatchesInOld =
              _allGroupsList.any((oldGroup) => oldGroup.id == newGroup.id && oldGroup.hour == newGroup.hour);
          bool nameMatchesInOld =
              _allGroupsList.any((oldGroup) => oldGroup.id == newGroup.id && oldGroup.name == newGroup.name);
          bool imageMatchesInNew =
              _allGroupsList.any((oldGroup) => oldGroup.id == newGroup.id && oldGroup.image == newGroup.image);

          if (!idExistsInOld || !hourMatchesInOld || !nameMatchesInOld || !imageMatchesInNew) {
            newGroups.add(newGroup);
          }
        }

        decryptGroupPrivateKeys(newGroups).forEach((element) {
          oldGroups.add(element);
        });

        _allGroupsList = oldGroups;

        _allGroupsList.sort((b, a) => a.hour!.compareTo(b.hour!));

        if (widget.list != "Chats individuales") {
          _currentGroupList = _allGroupsList.where((group) {
            return group.type == widget.list;
          }).toList();
        }

        setState(() {
          loading_groups = false;
        });
      }
    });
  }

  List<IndividualChat> decryptIndividualChatPrivateKeys(List<IndividualChat> lista) {
    for (int i = 0; i < lista.length; i++) {
      bool isCreatedByMe = IndividualChatController().isCreatedByMe(lista[i], widget.user);
      if (isCreatedByMe) {
        lista[i].keyU1 =
            RSAController().decryption(lista[i].keyU1!, RSAController().getRSAPrivateKey(widget.user.privateKey!));
      } else {
        lista[i].keyU2 =
            RSAController().decryption(lista[i].keyU2!, RSAController().getRSAPrivateKey(widget.user.privateKey!));
      }

      lista[i].lastMessage = AESController().decrypt(isCreatedByMe ? lista[i].keyU1! : lista[i].keyU2!,
          lista[i].lastMessage!, HASHController().generateHash(isCreatedByMe ? lista[i].keyU1! : lista[i].keyU2!));
    }

    return lista;
  }

  List<Group> decryptGroupPrivateKeys(List<Group> lista) {
    for (int i = 0; i < lista.length; i++) {
      var member = lista[i].members!.firstWhere((element) => element["id"] == widget.user.id);

      member["key"] =
          RSAController().decryption(member["key"], RSAController().getRSAPrivateKey(widget.user.privateKey!));

      lista[i].lastMessage =
          AESController().decrypt(member["key"], lista[i].lastMessage!, HASHController().generateHash(member["key"]));
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
      child: SizedBox(
        width: size.width * 0.2,
        child: widget.list == 'Chats individuales' ? buildIndividualChatsListItem() : buildGroupListItem(widget.list),
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
                    child: SvgPicture.asset('assets/icons/Buscar.svg'),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 5.0)),
                Flexible(
                  child: TextField(
                    controller: searchController,
                    cursorColor: MyColors.green,
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
            ? loading_chats
                ? const Center(child: CircularProgressIndicator(color: MyColors.yellow))
                : ListView.builder(
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  onTap: () => Responsive.isMobile(context)
                                      ? Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                          return Chat(userU1: widget.user, userU2: user!, chat: null, group: null);
                                        }))
                                      : _selectUser(user!),
                                  child: IndividualChatWidget(
                                    name: user?.name,
                                    type: user?.type,
                                    image: user?.image,
                                    hour: Timestamp.fromDate(DateTime(1970, 1, 1, 0, 0)),
                                    message: " ",
                                  ),
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
              ),
        const Padding(padding: EdgeInsets.only(bottom: 20.0)),
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
                    child: SvgPicture.asset('assets/icons/Buscar.svg'),
                  ),
                ),
                const Padding(padding: EdgeInsets.only(left: 5.0)),
                Flexible(
                  child: TextField(
                    controller: searchController,
                    cursorColor: MyColors.green,
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                  type == "Grupos de asignaturas con profesores" &&
                          (widget.user.type != "Alumno" &&
                              widget.user.type != "Delegado" &&
                              widget.user.type != "Subdelegado")
                      ? "Grupos de asignaturas con alumnos"
                      : widget.list,
                  style: title()),
            ),
            widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                ? Container()
                : widget.user.type == "Admin"
                    ? AddButton(list: widget.list, user: widget.user)
                    : widget.user.type == "Administrativo" && type == "Grupos de departamentos"
                        ? Container()
                        : type == "Grupos de asignaturas con profesores"
                            ? AddButton(list: "Grupos de asignaturas con profesores", user: widget.user)
                            : Container(),
          ],
        ),
        isTextFieldEmpty
            ? loading_groups
                ? const Center(child: CircularProgressIndicator(color: MyColors.yellow))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _currentGroupList.length,
                    itemBuilder: (context, index) {
                      Group group = _currentGroupList[index];
                      return GroupList(
                        user: widget.user,
                        group: group,
                        selectGroup: _selectGroup,
                      );
                    },
                  )
            : SingleChildScrollView(
                child: FutureBuilder<List<Group?>>(
                  future: group.getGroupsContainsString(searchController.text, widget.user, type),
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
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  overlayColor: MaterialStateProperty.all(Colors.transparent),
                                  onTap: () => Responsive.isMobile(context)
                                      ? Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                                          return Chat(userU1: widget.user, userU2: null, chat: null, group: group);
                                        }))
                                      : _selectGroup(group!),
                                  child: GroupWidget(
                                    name: group!.name,
                                    hour: group.hour,
                                    image: group.image,
                                    message: group.lastMessage,
                                  ),
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
              ),
        const Padding(padding: EdgeInsets.only(bottom: 20.0)),
      ],
    );
  }

  OutlineInputBorder themeTextField() {
    return const OutlineInputBorder(
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
                ? Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return Chat(userU1: widget.user, userU2: null, chat: widget.individualChat, group: null);
                  }))
                : widget.selectChat(widget.individualChat),
            child: IndividualChatWidget(
              name: IndividualChatController().isCreatedByMe(widget.individualChat, widget.user)
                  ? widget.individualChat.nameU2
                  : widget.individualChat.nameU1,
              image: IndividualChatController().isCreatedByMe(widget.individualChat, widget.user)
                  ? widget.individualChat.imageU2
                  : widget.individualChat.imageU1,
              type: IndividualChatController().isCreatedByMe(widget.individualChat, widget.user)
                  ? widget.individualChat.typeU2
                  : widget.individualChat.typeU1,
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
                ? Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                    return Chat(userU1: widget.user, group: widget.group, chat: null, userU2: null);
                  }))
                : widget.selectGroup(widget.group),
            child: GroupWidget(
              name: widget.group.name,
              hour: widget.group.hour,
              image: widget.group.image,
              message: widget.group.lastMessage,
            ),
          ),
        ),
      ),
    );
  }
}

class AddButton extends StatefulWidget {
  final String list;
  final ChatUser user;

  const AddButton({super.key, required this.list, required this.user});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: MyColors.background4,
                title: Text('Crear Grupo', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                content: TextFormField(
                  controller: _groupNameController,
                  style: title(),
                  cursorColor: MyColors.green,
                  decoration: InputDecoration(
                    hintText: 'Introduzca el nombre del grupo',
                    hintStyle: const TextStyle(color: MyColors.grey),
                    filled: true,
                    fillColor: MyColors.background3,
                    enabledBorder: themeTextField(),
                    focusedBorder: themeTextField(),
                    errorBorder: themeTextField(),
                    disabledBorder: themeTextField(),
                    focusedErrorBorder: themeTextField(),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancelar',
                          style: title2().copyWith(color: MyColors.yellow, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                    child: TextButton(
                      onPressed: () async {
                        String groupName = _groupNameController.text;
                        _groupNameController.clear();
                        if (groupName.isNotEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                backgroundColor: MyColors.background3,
                                title: const Text('Creando grupo...', style: TextStyle(color: MyColors.white)),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Center(child: CircularProgressIndicator(color: MyColors.white)),
                                    SizedBox(height: 16),
                                    Text('Por favor, espere...', style: TextStyle(color: MyColors.white)),
                                  ],
                                ),
                              );
                            },
                          );
                          await GroupController().createGroup(widget.user, groupName, widget.list);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                          setState(() {});
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Por favor, ingresa un nombre para el grupo.')),
                          );
                        }
                      },
                      child: Text('Aceptar', style: title2().copyWith(fontWeight: FontWeight.bold)),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        child: SizedBox(
          width: 40,
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: SvgPicture.asset('assets/icons/Anadir.svg'),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder themeTextField() {
    return const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}
