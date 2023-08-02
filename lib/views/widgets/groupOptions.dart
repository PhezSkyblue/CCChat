import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../models/Group.dart';
import '../../models/User.dart';
import '../styles/responsive.dart';
import '../styles/styles.dart';
import 'components/UserListWidget.dart';

class GroupOptions extends StatefulWidget {
  final Group? group;
  final ChatUser user;

  const GroupOptions({super.key, required this.group, required this.user});

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Container(
      color: MyColors.background2,
      padding: const EdgeInsets.all(30.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: Responsive.isMobile(context) ? const BorderRadius.all(Radius.zero) : const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          color: MyColors.background2,
        ),
        width: size.width * 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  if (Responsive.isMobile(context)) {
                    Navigator.pop(context);
                  } else {

                  }
                },
                child: SizedBox(
                  width: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SvgPicture.asset('../assets/icons/Cerrar.svg'),
                  ),
                ),
              ),
            ),

            const Padding(padding: EdgeInsets.only(bottom: 30.0)),

            isUserU1Admin()
              ? Text("Hola")
              : Container(),
          
            Text("Lista de integrantes", style: title()),

            const Padding(padding: EdgeInsets.only(bottom: 30.0)),
          
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.group?.members!.length,
                itemBuilder: (context, index) {
                  return UserListWidget(
                    group: widget.group,
                    idUser: widget.group?.members![index]['id']!,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  bool isUserU1Admin() {
      bool isMemberUserU1 = widget.group!.members!.any((member) => member['id'] == widget.user.id);
      bool isAdminMemberUserU1 = widget.group!.members!.any((member) => member['id'] == widget.user.id && member['type'] == 'Admin');
      return isMemberUserU1 && isAdminMemberUserU1;
  }
}