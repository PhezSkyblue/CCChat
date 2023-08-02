import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../models/Group.dart';
import '../../../models/User.dart';
import '../../../services/UserServiceFirebase.dart';

class UserListWidget extends StatefulWidget {
  final String idUser;
  final Group? group;

  const UserListWidget({Key? key, required this.idUser, required this.group}) : super(key: key);

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
            backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 28, minRadius: 28),
      
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
      
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
      
              },
              child: SizedBox(
                width: 40,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: SvgPicture.asset('../assets/icons/Mas.svg'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
