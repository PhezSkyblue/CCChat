import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../models/User.dart';

class DesktopMenu extends StatefulWidget {
  final ChatUser user;

  const DesktopMenu({Key? key, required this.onItemSelected, required this.user}) : super(key: key);

  final Function(String) onItemSelected;

  @override
  State<DesktopMenu> createState() => _DesktopMenuState();
}

class _DesktopMenuState extends State<DesktopMenu> {
  String selectedButton = "Chats individuales";

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(bottomRight: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          color: MyColors.background3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(padding: EdgeInsets.only(top: 20.0)),
          MenuButton(
            buttonTitle: "Chats individuales",
            icon: 'assets/icons/Chats_Individuales.svg',
            page: () {
              _selectButton('Chats individuales');
            },
            isSelected: selectedButton == 'Chats individuales',
          ),
          MenuButton(
            buttonTitle: "Grupos difusión",
            icon: 'assets/icons/Grupos_Difusion.svg',
            page: () {
              _selectButton('Grupos difusión');
            },
            isSelected: selectedButton == 'Grupos difusión',
          ),
          MenuButton(
            buttonTitle:
                widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                    ? "Grupos profesores"
                    : "Grupo departamento",
            icon: 'assets/icons/Grupos_Profesores.svg',
            page: () {
              widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                  ? _selectButton('Grupos de asignaturas con profesores')
                  : _selectButton('Grupos de departamentos');
            },
            isSelected:
                widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                    ? selectedButton == 'Grupos de asignaturas con profesores'
                    : selectedButton == 'Grupos de departamentos',
          ),
          MenuButton(
              buttonTitle: "Grupos alumnos",
              icon: 'assets/icons/Grupos_Alumnos.svg',
              page: () {
                widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                    ? _selectButton('Grupos de asignaturas solo alumnos')
                    : _selectButton('Grupos de asignaturas con profesores');
              },
              isSelected:
                  widget.user.type == "Alumno" || widget.user.type == "Delegado" || widget.user.type == "Subdelegado"
                      ? selectedButton == 'Grupos de asignaturas solo alumnos'
                      : selectedButton == 'Grupos de asignaturas con profesores'),
          MenuButton(
            buttonTitle: "Ajustes",
            icon: 'assets/icons/Ajustes.svg',
            page: () {
              _selectButton('Ajustes');
            },
            isSelected: selectedButton == 'Ajustes',
          )
        ],
      ),
    );
  }

  void _selectButton(String buttonTitle) {
    setState(() {
      selectedButton = buttonTitle;
      widget.onItemSelected(buttonTitle);
    });
  }
}

class MenuButton extends StatefulWidget {
  final String? buttonTitle;
  final String icon;
  final Function page;
  final bool isSelected;

  const MenuButton({
    Key? key,
    this.buttonTitle,
    required this.icon,
    required this.page,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 25.0, right: 25.0),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(15.0)),
            color: widget.isSelected ? MyColors.yellow : MyColors.background3),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.transparent,
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              onTap: () {
                widget.page();
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 15.0, right: 0.0),
                child: Row(
                  children: [
                    SvgPicture.asset(widget.icon, color: widget.isSelected ? MyColors.background3 : MyColors.grey),
                    const Padding(padding: EdgeInsets.only(left: 15.0)),
                    Text(
                      widget.buttonTitle.toString(),
                      style: widget.isSelected ? title2() : title(),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
