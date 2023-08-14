import 'package:ccchat/services/IndividualChatServiceFirebase.dart';
import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:html' as html;
import '../../models/User.dart';
import '../../services/UserServiceFirebase.dart';
import '../SignView.dart';
import '../styles/responsive.dart';

class Settings extends StatefulWidget {
  final ChatUser user;

  const Settings({Key? key, required this.user})
      : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    TextEditingController nameController = TextEditingController();
    TextEditingController emailSController = TextEditingController();
    TextEditingController emailTController = TextEditingController();
    TextEditingController typeController = TextEditingController();
    TextEditingController passwordController = TextEditingController();
    TextEditingController passwordController2 = TextEditingController();

    String? selectedStudentType;

    final List<String> userTypeOptions = [
      'Alumno',
      'Delegado',
      'Subdelegado',
    ];

    Uint8List? imageBytes;

    Future<void> _pickImage() async {
      imageBytes = await ImagePickerWeb.getImageAsBytes();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, left: 20.0, right: 20.0),
      child: SizedBox(
        width: Responsive.isDesktop(context) ? size.width * 0.2 : size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(bottom: 20.0)),

            widget.user.type == "Admin" 
              ? MouseRegion(
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
                            title: Text('Modificar tipo de alumno', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: emailSController,
                                  style: title(),
                                  cursorColor: MyColors.green,
                                  decoration: InputDecoration(
                                    hintText: 'Introduzca el email',
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

                                const Padding(padding: EdgeInsets.only(bottom: 20.0)),

                                DropdownButtonFormField<String>(
                                  value: selectedStudentType,
                                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                                  dropdownColor: MyColors.background3,
                                  decoration: InputDecoration(
                                    hintText: 'Seleccione el tipo',
                                    hintStyle: const TextStyle(color: MyColors.grey),
                                    filled: true,
                                    fillColor: MyColors.background3,
                                    enabledBorder: themeTextField(),
                                    focusedBorder: themeTextField(),
                                    errorBorder: themeTextField(),
                                    disabledBorder: themeTextField(),
                                    focusedErrorBorder: themeTextField(),
                                  ),
                                  items: userTypeOptions.map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      selectedStudentType = newValue;
                                    });
                                  }
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
                                    if(emailSController.text.isNotEmpty && selectedStudentType!.isNotEmpty) {
                                      UserServiceFirebase changeType = UserServiceFirebase();
                                      ChatUser? userObject = await changeType.getUserByEmail(emailSController.text);

                                      Future<ChatUser?>? user;
                                      if(userObject!.type == "Alumno" || userObject.type == "Delegado" || userObject.type == "Subdelegado") {
                                        user = changeType.updateUser(user: userObject, type: selectedStudentType.toString());
                                      }

                                      if(user == null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              backgroundColor: MyColors.background3,
                                              title: const Text('Error con la modificación', style: TextStyle(color: MyColors.white)),
                                              content: const Text('No se ha podido modificar el tipo.', style: TextStyle(color: MyColors.white)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                              content: const Text('Se ha modificado correctamente el tipo.', style: TextStyle(color: MyColors.white)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                        SnackBar(content: Text('Por favor, ingresa un email y tipo.')),
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
                        text: '- Modificar tipo de alumno.',
                        style: title(),
                      ),
                    ),
                  ),
                )
              : Container(),

            const Padding(padding: EdgeInsets.only(bottom: 20.0)),

            widget.user.type == "Admin" 
              ? MouseRegion(
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
                            title: Text('Modificar tipo de alumno', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: emailTController,
                                  style: title(),
                                  cursorColor: MyColors.green,
                                  decoration: InputDecoration(
                                    hintText: 'Introduzca el email',
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

                                const Padding(padding: EdgeInsets.only(bottom: 20.0)),

                                TextFormField(
                                  controller: typeController,
                                  style: title(),
                                  cursorColor: MyColors.green,
                                  decoration: InputDecoration(
                                    hintText: 'Introduzca el tipo',
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
                                    if(emailTController.text.isNotEmpty && typeController.text.isNotEmpty) {
                                      UserServiceFirebase changeType = UserServiceFirebase();
                                      ChatUser? userObject = await changeType.getUserByEmail(emailTController.text);
                                      Future<ChatUser?>? user;
                                      if(userObject!.type != "Alumno" && userObject.type != "Delegado" && userObject.type != "Subdelegado") {
                                        user = changeType.updateUser(user: userObject, type: typeController.text);
                                      }
                                      
                                      if(user == null) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              backgroundColor: MyColors.background3,
                                              title: const Text('Error con la modificación', style: TextStyle(color: MyColors.white)),
                                              content: const Text('No se ha podido modificar el tipo.', style: TextStyle(color: MyColors.white)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                              content: const Text('Se ha modificado correctamente el tipo.', style: TextStyle(color: MyColors.white)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
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
                                        SnackBar(content: Text('Por favor, ingresa un email y tipo.')),
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
                        text: '- Modificar tipo de profesor.',
                        style: title(),
                      ),
                    ),
                  ),
                )
              : Container(),

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
                                  Future<ChatUser?> user = changeName.updateUser(user: widget.user, name: nameController.text);
                                  
                                  if(user == null) {
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
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('OK', style: TextStyle(color: MyColors.yellow)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    setState(() {
                                      widget.user.name = nameController.text;
                                    });
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
                  await _pickImage();

                  if (imageBytes != null) {
                    String stringImage = String.fromCharCodes(imageBytes!);
                    imageBytes = Uint8List.fromList(stringImage.codeUnits);
                    var updatedUser = await UserServiceFirebase().updateUser(user: widget.user, image: imageBytes);
                    if (updatedUser != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            backgroundColor: MyColors.background3,
                            title: const Text('Modificado correctamente', style: TextStyle(color: MyColors.white)),
                            content: const Text('Se ha modificado correctamente la imagen de perfil.', style: TextStyle(color: MyColors.white)),
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
                      setState(() {
                        widget.user.image = updatedUser.image;
                      });
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
                            content: const Text('No se ha podido modificar la imagen por ser demasiado grande.', style: TextStyle(color: MyColors.white)),
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
                  }
                },
            
                child: RichText(
                  text: TextSpan(
                    text: '- Cambiar foto de perfil.',
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
                                  Future<ChatUser?> user = changePassword.updateUser(user: widget.user, password: passwordController.text);
                                  
                                  if(user == null) {
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