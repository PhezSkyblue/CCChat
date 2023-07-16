import 'package:ccchat/views/styles/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/IndividualChatServiceFirebase.dart';
import '../../styles/responsive.dart';

class OtherMessageWidget extends StatefulWidget {
  final String? name, message, type;
  final Timestamp? hour;

  const OtherMessageWidget({Key? key, required this.name, 
  required this.hour, required this.message, required this.type}) : super(key: key);

  @override
  State<OtherMessageWidget> createState() => _OtherMessageWidgetState();
}

class _OtherMessageWidgetState extends State<OtherMessageWidget> {
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0) : const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 52.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300, minWidth: 75), 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name!,
                  style: widget.type == "Alumno" ? studentChat() : teacherChat(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
      
                const Padding(padding: EdgeInsets.only(right: 10.0)),
      
                Text(
                  IndividualChatServiceFirebase().readTimestamp(widget.hour),
                  style: hour(),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
      
            const Padding(padding: EdgeInsets.only(bottom: 10.0)),
      
            Container(
              constraints: const BoxConstraints(maxWidth: 300, minWidth: 75),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: MyColors.background3, 
                  borderRadius: BorderRadius.only(topRight: Radius.circular(15.0), bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15.0, right: 15.0),
                  child: Text(
                    widget.message!,
                    style: messagesChat1(),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}