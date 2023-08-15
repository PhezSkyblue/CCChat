import 'dart:typed_data';

import 'package:ccchat/views/styles/styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../controllers/IndividualChatController.dart';

class GroupWidget extends StatefulWidget {
  final String? name, message;
  final Timestamp? hour;
  final Uint8List? image;

  const GroupWidget({Key? key, required this.name, 
  required this.hour, required this.message, required this.image}) : super(key: key);

  @override
  State<GroupWidget> createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  @override
  Widget build(BuildContext context) {

    return Row(
      children: [
        widget.image != null
          ? CircleAvatar(backgroundImage: MemoryImage(widget.image!), maxRadius: 28, minRadius: 28)
          : const CircleAvatar(backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 28, minRadius: 28),

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
                    IndividualChatController().readTimestamp(widget.hour),
                    style: hour(),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),

              Text(widget.message!, style: messagesGroup(), overflow: TextOverflow.ellipsis, maxLines: 1,),
            ],
          ),
        ),
      ],
    );
  }
}