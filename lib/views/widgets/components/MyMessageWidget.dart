import 'package:ccchat/views/styles/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../services/IndividualChatServiceFirebase.dart';

class MyMessageWidget extends StatefulWidget {
  final String? name, message;
  final Timestamp? hour;

  const MyMessageWidget({Key? key, required this.name, required this.hour, required this.message}) : super(key: key);

  @override
  State<MyMessageWidget> createState() => _MyMessageWidgetState();
}

class _MyMessageWidgetState extends State<MyMessageWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, right: 40.0,),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width), // Establece un ancho máximo
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              IndividualChatServiceFirebase().readTimestamp(widget.hour),
              style: hour(),
              textAlign: TextAlign.right,
            ),
    
            const Padding(padding: EdgeInsets.only(bottom: 5.0)),
            
            Container(
              constraints: const BoxConstraints(maxWidth: 300, minWidth: 75),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: MyColors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 15.0, right: 15.0),
                  child: Text(
                    widget.message!,
                    style: messagesChat2(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}