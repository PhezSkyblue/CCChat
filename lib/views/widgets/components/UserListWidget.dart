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
              child: GestureDetector(
                onTap: () {
                  Material(
                    child: PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return [
                          widget.group?.members?.firstWhere((element) => element['id'] == widget.idUser)['writePermission'] == true 
                            ? const PopupMenuItem<String>(
                              value: 'silenciar',
                              child: Text('Silenciar usuario'),
                            )
                            : const PopupMenuItem<String>(
                              value: 'desilenciar',
                              child: Text('Desilenciar usuario'),
                            ),
                  
                          const PopupMenuItem<String>(
                            value: 'eliminar',
                            child: Text('Eliminar usuario'),
                          ),
                        ];
                      },
                      onSelected: (String value) {
                        if(value == "silenciar") {
                  
                        }
                  
                        if(value == "desilenciar") {
                          
                        }
                  
                        if(value == "eliminar") {
                          
                        }
                      },
                    ),
                  );
                },
                child: SizedBox(
                  width: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SvgPicture.asset('../assets/icons/Mas.svg'),
                  ),
                ),
              ),
            )
          : Container(),
        ],
      ),
    );
  }
}
