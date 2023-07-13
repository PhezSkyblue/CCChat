import 'package:ccchat/models/IndividualChat.dart';
import 'package:ccchat/models/User.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Chat extends StatefulWidget {
  final ChatUser? userU1, userU2;
  final IndividualChat?
   chat;
  
  const Chat({Key? key, required this.userU1, required this.userU2, required this.chat}) : super(key: key);

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
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
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                color: MyColors.background3,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 15.0, minRadius: 15.0),
                    const Padding(padding: EdgeInsets.all(5.0)),
                    Text('Asignatura', style: nameGroups(), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
            
            Container(),

            Padding(
              padding: const EdgeInsets.only(bottom: 25.0, top: 15.0, left: 50.0, right: 50.0),
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  color: MyColors.background3,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 40.0, right: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Escribe aquí...',
                              hintStyle: messagesGroup(),
                              hintMaxLines: 1,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ), 
                            style: messagesGroup2(),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),

                      Container(
                        width: 40,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          color: MyColors.yellow
                        ),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => Container(),
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
            )
          ],
        )
      ),
    );
  }
}