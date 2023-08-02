import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import '../../models/User.dart';
import '../../services/UserServiceFirebase.dart';
import '../SignView.dart';
import '../styles/responsive.dart';

class Settings extends StatefulWidget {
  final ChatUser user;

  const Settings({Key? key, required this.user}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    TextEditingController nameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController passwordController2 = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: SizedBox(
        width: Responsive.isDesktop(context) ? size.width * 0.2 : size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
      
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: MyColors.background4,
                        title: Text('Modificar nombre y apellidos', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                        content: TextFormField(
                          controller: nameController,
                          style: title(),
                          cursorColor: MyColors.green,
                          decoration: InputDecoration(
                            hintText: 'Introduzca el nombre y apellidos',
                            hintStyle: const TextStyle(color: MyColors.grey),
                            filled: true,
                            fillColor: MyColors.background3,
                            enabledBorder: themeTextField(),
                            focusedBorder: themeTextField(),
                            errorBorder: themeTextField(),
                            disabledBorder: themeTextField(),
                            focusedErrorBorder: themeTextField(),
                          ),
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar', style: title2().copyWith(color: MyColors.yellow, fontWeight: FontWeight.bold)),
                            ),
                          ),
      
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if(nameController.text.isNotEmpty) {
                                  UserServiceFirebase changeName = UserServiceFirebase();
                                  Future<bool> user = changeName.updateUser(id: widget.user.id, name: nameController.text);
                                  
                                  if(user == false) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          backgroundColor: MyColors.background3,
                                          title: const Text('Error con la modificación', style: TextStyle(color: MyColors.white)),
                                          content: const Text('No se ha podido modificar el nombre.', style: TextStyle(color: MyColors.white)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          backgroundColor: MyColors.background3,
                                          title: const Text('Modificado correctamente', style: TextStyle(color: MyColors.white)),
                                          content: const Text('Se ha modificado correctamente el nombre de usuario.', style: TextStyle(color: MyColors.white)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                html.window.location.reload();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Por favor, ingresa un nombre.')),
                                  );
                                }
                              },
                              child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold)),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Modificar nombre y apellidos.',
                    style: title(),
                  ),
                ),
              ),
            ),
      
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),

            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Cambiar foto de perfil. (NO OPERATIVO AUN)',
                    style: title(),
                  ),
                ),
              ),
            ),

            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
      
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: MyColors.background4,
                        title: Text('Modificar contraseña', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: passwordController,
                              style: title(),
                              cursorColor: MyColors.green, 
                              decoration: InputDecoration(
                                hintText: 'Introduzca la contraseña',
                                hintStyle: const TextStyle(color: MyColors.grey),
                                filled: true,
                                fillColor: MyColors.background3,
                                enabledBorder: themeTextField(),
                                focusedBorder: themeTextField(),
                                errorBorder: themeTextField(),
                                disabledBorder: themeTextField(),
                                focusedErrorBorder: themeTextField(),
                              ),
                        
                              obscureText: true,
                            ),
                        
                            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
                        
                            TextFormField(
                              controller: passwordController2,
                              style: title(),
                              cursorColor: MyColors.green,
                              decoration: InputDecoration(
                                hintText: 'Introduzca de nuevo la contraseña',
                                hintStyle: const TextStyle(color: MyColors.grey),
                                filled: true,
                                fillColor: MyColors.background3,
                                enabledBorder: themeTextField(),
                                focusedBorder: themeTextField(),
                                errorBorder: themeTextField(),
                                disabledBorder: themeTextField(),
                                focusedErrorBorder: themeTextField(),
                              ),
                        
                              obscureText: true,
                            ),
                          ],
                        ),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar', style: title2().copyWith(color: MyColors.yellow, fontWeight: FontWeight.bold)),
                            ),
                          ),
      
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if(passwordController.text.length > 8 && passwordController.text.isNotEmpty && passwordController.text == passwordController2.text) {
                                  UserServiceFirebase changePassword = UserServiceFirebase();
                                  Future<bool> user = changePassword.updateUser(id: widget.user.id, password: passwordController.text);
                                  
                                  if(user == false) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          backgroundColor: MyColors.background3,
                                          title: const Text('Error con la modificación', style: TextStyle(color: MyColors.white)),
                                          content: const Text('No se ha podido modificar la contraseña.', style: TextStyle(color: MyColors.white)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(15.0),
                                          ),
                                          backgroundColor: MyColors.background3,
                                          title: const Text('Modificado correctamente', style: TextStyle(color: MyColors.white)),
                                          content: const Text('Se ha modificado correctamente la contraseña.', style: TextStyle(color: MyColors.white)),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        backgroundColor: MyColors.background3,
                                        title: const Text('Error con la modificación', style: TextStyle(color: MyColors.white)),
                                        content: const Text('Las contraseñas no coinciden o los datos no son correctos.', style: TextStyle(color: MyColors.white)),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold)),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Modificar contraseña.',
                    style: title(),
                  ),
                ),
              ),
            ),
      
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
      
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        backgroundColor: MyColors.background4,
                        title: Text('Eliminar cuenta', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                        content: const Text('¿Está seguro que desea eliminar su cuenta? Perderá todos sus mensajes y contactos.', style: TextStyle(color: MyColors.white)),
                        actions: [
                           Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancelar', style: title2().copyWith(color: MyColors.yellow, fontWeight: FontWeight.bold)),
                            ),
                          ),
      
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0, right: 10.0),
                            child: TextButton(
                              onPressed: () {
                                UserServiceFirebase deleteUser = UserServiceFirebase();
                                Future<bool> user = deleteUser.deleteUser(id: widget.user.id);
                                
                                if(user == false) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        backgroundColor: MyColors.background3,
                                        title: const Text('Error con la eliminación', style: TextStyle(color: MyColors.white)),
                                        content: const Text('No se ha podido eliminar la cuenta.', style: TextStyle(color: MyColors.white)),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(15.0),
                                        ),
                                        backgroundColor: MyColors.background3,
                                        title: const Text('Eliminado correctamente', style: TextStyle(color: MyColors.white)),
                                        content: const Text('Se ha eliminado correctamente el usuario.', style: TextStyle(color: MyColors.white)),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(builder: (context) {
                                                  return const MaterialApp(
                                                    title: 'CCChat',
                                                    home: SignView(),
                                                  );
                                                })
                                              );
                                            },
                                            child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: Text('Aceptar', style: title2().copyWith(fontWeight: FontWeight.bold)),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Eliminar cuenta.',
                    style: title(),
                  ),
                ),
              ),
            ),
      
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),
      
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  UserServiceFirebase user = UserServiceFirebase();
                  
                  if (kIsWeb) {
                    user.clearWebStorage();
                  } else {
                    user.clearSharedPreferences();
                  }

                  html.window.location.reload();
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Cerrar sesión.',
                    style: title(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 1, color: MyColors.background3),
    );
  }
}