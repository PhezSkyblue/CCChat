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
      decoration: TextDecoration.none
    );

TextStyle messagesGroup() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

TextStyle messagesGroup2() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: MyColors.white,
      decoration: TextDecoration.none
    );

TextStyle notificationGroup() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: MyColors.background4,
      decoration: TextDecoration.none
    );

TextStyle hour() => GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

// Titles' Styles

TextStyle title() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

TextStyle title2() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: MyColors.background3,
      decoration: TextDecoration.none
    );

// Banner's Styles

TextStyle userName() => GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: MyColors.white,
      decoration: TextDecoration.none
    );

TextStyle studentType() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MyColors.yellow,
      decoration: TextDecoration.none
    );

TextStyle teacherType() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: MyColors.green,
      decoration: TextDecoration.none
    );

TextStyle searcher() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

TextStyle searcher2() => GoogleFonts.poppins(
      fontSize: 14,
      fontStyle: FontStyle.normal,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

// Chats' Styles

TextStyle messagesChat1() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

TextStyle messagesChat2() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.background4,
      decoration: TextDecoration.none
    );

TextStyle studentChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.yellow,
      decoration: TextDecoration.none
    );

TextStyle teacherChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: MyColors.green,
      decoration: TextDecoration.none
    );

TextStyle sendChat() => GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: MyColors.grey,
      decoration: TextDecoration.none
    );

// App name

TextStyle appName() => GoogleFonts.poppins(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: MyColors.white,
      decoration: TextDecoration.none
    );
