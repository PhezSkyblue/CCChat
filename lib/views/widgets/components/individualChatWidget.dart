import 'dart:typed_data';

import 'package:ccchat/views/styles/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../controllers/IndividualChatController.dart';

class IndividualChatWidget extends StatefulWidget {
  final String? name, type, message;
  final Timestamp? hour;
  final Uint8List? image;

  const IndividualChatWidget(
      {Key? key,
      required this.name,
      required this.type,
      required this.hour,
      required this.message,
      required this.image})
      : super(key: key);

  @override
  State<IndividualChatWidget> createState() => _IndividualChatWidgetState();
}

class _IndividualChatWidgetState extends State<IndividualChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        widget.image != null
            ? CircleAvatar(backgroundImage: MemoryImage(widget.image!), maxRadius: 28, minRadius: 28)
            : const CircleAvatar(
                backgroundImage: AssetImage('assets/images/DefaultAvatar.jpg'), maxRadius: 28, minRadius: 28),
        const Padding(padding: EdgeInsets.only(right: 10.0)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: Text(
                      widget.name!,
                      style: nameGroups(),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(right: 10.0)),
                  Text(
                    widget.hour != Timestamp.fromDate(DateTime(1970, 1, 1, 0, 0))
                        ? IndividualChatController().readTimestamp(widget.hour)
                        : "",
                    style: hour(),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Text(widget.type!,
                  style: widget.type == "Alumno" || widget.type == "Delegado" || widget.type == "Subdelegado"
                      ? studentChat()
                      : teacherChat()),
              Text(
                widget.message!,
                style: messagesGroup(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
