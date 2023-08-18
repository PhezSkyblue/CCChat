import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


class MobileMenu extends StatefulWidget {
  const MobileMenu({Key? key, required this.onItemSelected}) : super(key: key);

  final Function(String) onItemSelected;

  @override
  State<MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<MobileMenu> {
  String selectedButton = "Chats individuales";

  @override
  Widget build(BuildContext context) {
    //var size = MediaQuery.of(context).size;

    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0), 
            topRight: Radius.circular(15.0)),
          color: MyColors.background3),
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MenuButton(
              icon: '../assets/icons/Perfil.svg',
              page: () {
                _selectButton('Perfil');
              },
              isSelected: selectedButton == 'Perfil',
            ),
            MenuButton(
              icon: '../assets/icons/Chats_Individuales.svg',
              page: () {
                _selectButton('Chats individuales');
              },
              isSelected: selectedButton == 'Chats individuales',
            ),
            MenuButton(
              icon: '../assets/icons/Grupos_Difusion.svg',
              page: () {
                _selectButton('Grupos difusión');
              },
              isSelected: selectedButton == 'Grupos difusión',
            ),
            MenuButton(
              icon: '../assets/icons/Grupos_Profesores.svg',
              page: () {
                _selectButton('Grupos de asignaturas con profesores');
              },
              isSelected: selectedButton == 'Grupos de asignaturas con profesores',
            ),
            MenuButton(
              icon: '../assets/icons/Grupos_Alumnos.svg',
              page: () {
                _selectButton('Grupos de asignaturas solo alumnos');
              },
              isSelected: selectedButton == 'Grupos de asignaturas solo alumnos',
            ),
            MenuButton(
              icon: '../assets/icons/Ajustes.svg',
              page: () {
                _selectButton('Ajustes');
              },
              isSelected: selectedButton == 'Ajustes',
            )
          ],
        ),
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
  final String icon;
  final Function page;
  final bool isSelected;

  const MenuButton({Key? key, required this.icon, required this.page, required this.isSelected,}) : super(key: key);

  @override
  State<MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 55,
        height: 55,
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
                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0, left: 5.0, right: 5.0),
                child: SvgPicture.asset(widget.icon, colorFilter: ColorFilter.mode(widget.isSelected ? MyColors.background3 : MyColors.grey, BlendMode.srcIn)),
              ),
            ),
          ),
        ),
    );
  }
}