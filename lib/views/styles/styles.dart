import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyColors {
  static const Color grey = Color(0xff95979D);
  static const Color white = Color(0xffffffff);
  static const Color yellow = Color(0xffF8C962);
  static const Color green = Color(0xff18A096);
  static const Color background = Color(0xff1E1E1E); //No
  static const Color background2 = Color(0xff1D1E24);
  static const Color background3 = Color(0xff16171B);
  static const Color background4 = Color(0xff20232B);

  static const defaultPadding = 16.0;
}

// Groups' Styles

TextStyle nameGroups() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: MyColors.white,
    );

TextStyle messagesGroup() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
    );

TextStyle messagesGroup2() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: MyColors.white,
    );

TextStyle notificationGroup() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: MyColors.background4,
    );

TextStyle hour() => GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
    );

// Titles' Styles

TextStyle title() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
    );

TextStyle title2() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: MyColors.background3,
    );

// Banner's Styles

TextStyle userName() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: MyColors.white,
    );

TextStyle studentType() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MyColors.yellow,
    );

TextStyle teacherType() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MyColors.green,
    );

TextStyle searcher() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
    );

TextStyle searcher2() => GoogleFonts.poppins(
      fontSize: 14,
      fontStyle: FontStyle.normal,
      color: MyColors.grey,
    );

// Chats' Styles

TextStyle messagesChat1() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
    );

TextStyle messagesChat2() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.background4,
    );

TextStyle studentChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.yellow,
    );

TextStyle teacherChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.green,
    );

TextStyle sendChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
    );

// App name

TextStyle appName() => GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: MyColors.white,
    );
