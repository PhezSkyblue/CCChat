import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/Group.dart';
import '../../../models/User.dart';
import '../../../services/UserServiceFirebase.dart';

class UserListWidget extends StatefulWidget {
  final String idUser;
  final Group? group;
  final bool isAdmin;

  const UserListWidget({Key? key, required this.idUser, required this.group, required this.isAdmin}) : super(key: key);

  @override
  State<UserListWidget> createState() => _UserListWidgetState();
}

class _UserListWidgetState extends State<UserListWidget> {
  late Future<ChatUser?> userFuture;

  @override
  void initState() {
    super.initState();
    userFuture = UserServiceFirebase().getUserByID(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 21, minRadius: 21),
      
          const Padding(padding: EdgeInsets.only(right: 10.0)),
      
          Expanded(
            child: FutureBuilder<ChatUser?>(
              future: userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasData) {
                  ChatUser? user = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: nameGroups(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  
                      Text(
                        widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['type'] ?? '', 
                        style: widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['type'] == 'Alumno' 
                            || widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['type'] == "Delegado" 
                            || widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['type'] == "Subdelegado" 
                          ? studentChat() 
                          : teacherChat()
                      ),
                    ],
                  );
                } else {
                  return Text('Error obteniendo información del usuario');
                }
              },
            ),
          ),

          const Padding(padding: EdgeInsets.only(right: 15.0)),

          widget.isAdmin == true
            ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Material(
                child: PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0)),
                  itemBuilder: (BuildContext context) {
                    return [
                      widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['writePermission'] == true
                        ? PopupMenuItem<String>(
                            value: 'silenciar',
                            child: Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10.0))),
                              child: Text('Silenciar usuario', style: messagesChat1()),
                            ),
                          )
                        : PopupMenuItem<String>(
                            value: 'desilenciar',
                            child: Container(
                              decoration: const BoxDecoration(borderRadius: BorderRadius.all( Radius.circular(10.0))),
                              child: Text('Desilenciar usuario', style: messagesChat1()),
                            ),
                          ),
                      
                      PopupMenuItem<String>(
                        value: 'admin',
                        child: Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          child: Text('Convertir en admin', style: messagesChat1()),
                        ),
                      ),

                      PopupMenuItem<String>(
                        value: 'eliminar',
                        child: Container(
                          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          child: Text('Eliminar usuario', style: messagesChat1()),
                        ),
                      ),
                    ];
                  },

                  onSelected: (value) {
                    if (value == "silenciar") {}

                    if (value == "desilenciar") {}

                    if (value == "admin") {}

                    if (value == "eliminar") {}
                  },

                  color: MyColors.background4,
                  child: Container(
                    width: 40,
                    color: MyColors.background2,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: SvgPicture.asset('../assets/icons/Mas.svg', color: MyColors.grey),
                    ),
                  ),
                ),
              ))
            : Container(),
        ],
      ),
    );
  }
}
