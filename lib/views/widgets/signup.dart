import 'package:ccchat/views/styles/styles.dart';
import 'package:flutter/material.dart';

import '../../controllers/UserController.dart';
import '../../models/User.dart';
import '../SignView.dart';
import '../styles/responsive.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool isPasswordVisible = false;
  bool isPasswordVisible2 = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController typeController = TextEditingController();

  final _passwordKey = GlobalKey<FormFieldState>();
  final _formKey = GlobalKey<FormState>();

  UserController userService = UserController();

  final List<String> careerTypeOptions = [
    'Grado en Ingeniería Informática en Tecnologías de la Información',
    'Grado en Ingeniería Telemática en Telecomunicaciones',
    'Doble Grado en Ingeniería Informática y Telemática',
    'Grado en Ingeniería en Diseño Industrial y Desarrollo de Producto',
    'Grado en Enfermería',
  ];

  String selectedCareer = 'Grado en Ingeniería Informática en Tecnologías de la Información';


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: MyColors.background4,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: MyColors.background4,
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 45.0, right: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Responsive.isDesktop(context)
                    ? Row(
                      children: [
                        const Image(image: AssetImage('../assets/images/Logo.png'), width: 60),
                        const Padding(padding: EdgeInsets.only(left: 15.0)),
                        Text('CCChat', style: appName()),
                      ],
                    )
                    : const Row(),
      
                    Responsive.isDesktop(context) || Responsive.isTablet(context)
                    ? Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                            
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                                  child: RichText(
                                    text: TextSpan(
                                      text: '¿Ya estás registrado? ',
                                      style: title(),
                                      children: [
                                        TextSpan(
                                          text: "Inicia sesión aquí",
                                          style: title().copyWith(decoration: TextDecoration.underline, color: MyColors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.only(left: 15.0)),
                      ],
                    )
                    : const Row()
                  ],
                ),
              ),
            ),
      
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Text(
                'Registrarse',
                style: appName(),
              ),
            ),
      
            Padding(
            padding: Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0) : EdgeInsets.only(left: size.width / 4, right: size.width / 4, top: 40.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    style: title(),
                    controller: nameController,
                    cursorColor: MyColors.green,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Icon(Icons.person, color: MyColors.white),
                      ),
                      hintText: 'Introduzca su nombre y apellidos',
                      hintStyle: const TextStyle(color: MyColors.grey),
                      filled: true,
                      fillColor: MyColors.background3,
                      enabledBorder: themeTextField(),
                      focusedBorder: themeTextField(),
                      errorBorder: themeTextField(),
                      disabledBorder: themeTextField(),
                      focusedErrorBorder: themeTextField(),
                    ),
                    
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca su nombre y apellidos.';
                      } else if (value.length < 3) {
                        return 'Debe tener al menos 3 carácteres.';
                      }
                      return null;
                    },
                  ),
      
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
      
                  TextFormField(
                    style: title(),
                    controller: emailController,
                    cursorColor: MyColors.green,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Icon(Icons.email, color: MyColors.white),
                      ),
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
                    
                    // The validator receives the text that the user has entered.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca un correo eléctronico.';
                      } else if (value.length < 9) {
                        return 'Debe tener al menos 9 carácteres.';
                      } else if (!value.contains("@")) {
                        return 'Introduzca un correo eléctronico.';
                      } else if (!value.contains("@unex.es") && !value.contains("@alumnos.unex.es")) {
                        return 'Esta aplicación solo está disponible para estudiantes y personal de la UEx, debe introducir un correo asociado.';
                      }
                      return null;
                    },
                  ),
      
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
      
                  TextFormField(
                    style: title(),
                    controller: passwordController,
                    key: _passwordKey,
                    cursorColor: MyColors.green,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Icon(Icons.lock_open, color: MyColors.white),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: IconButton(
                          icon: Icon(
                            color: MyColors.white,
                            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
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
      
                    obscureText: !isPasswordVisible,
      
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca la contraseña.';
                      } else if (value.length < 8) {
                        return 'Debe tener al menos 8 carácteres.';
                      }
                      return null;
                    }
                  ),
      
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
      
                  TextFormField(
                    style: title(),
                    cursorColor: MyColors.green,
                    decoration: InputDecoration(
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Icon(Icons.lock_open, color: MyColors.white),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: IconButton(
                          icon: Icon(
                            color: MyColors.white,
                            isPasswordVisible2 ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible2 = !isPasswordVisible2;
                            });
                          },
                        ),
                      ),
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
      
                    obscureText: !isPasswordVisible2,
      
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Introduzca la contraseña.';
                      } else if (value != passwordController.text) {
                        return 'Las contraseñas introducidas no coinciden.';
                      } else if (value.length < 8) {
                        return 'Debe tener al menos 8 carácteres.';
                      }
                      return null;
                    }
                  ),
      
                  const Padding(padding: EdgeInsets.only(top: 20.0)),
      
                  ListTile(
                    title: Text('Alumno', style: title()),
                    leading: Radio(
                      value: 'Alumno',
                      fillColor: MaterialStateProperty.all(MyColors.white),
                      groupValue: typeController.text,
                      onChanged: (value) {
                        setState(() {
                          typeController.text = value.toString();
                        });
                      },
                    ),
                  ),
      
                  ListTile(
                    title: Text('Profesor', style: title()),
                    leading: Radio(
                      value: 'Profesor',
                      fillColor: MaterialStateProperty.all(MyColors.white),
                      groupValue: typeController.text,
                      onChanged: (value) {
                        setState(() {
                          typeController.text = value.toString();
                        });
                      },
                    ),
                  ),
      
                  ListTile(
                    title: Text('Administrativo', style: title()),
                    leading: Radio(
                      value: 'Administrativo',
                      fillColor: MaterialStateProperty.all(MyColors.white),
                      groupValue: typeController.text,
                      onChanged: (value) {
                        setState(() {
                          typeController.text = value.toString();
                        });
                      },
                    ),
                  ),
      
                  const Padding(padding: EdgeInsets.only(top: 20.0)),

                  typeController.text == 'Alumno'
                    ? DropdownButtonFormField<String>(
                      value: careerTypeOptions[0],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      dropdownColor: MyColors.background3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: MyColors.background3,
                        enabledBorder: themeTextField(),
                        focusedBorder: themeTextField(),
                        errorBorder: themeTextField(),
                        disabledBorder: themeTextField(),
                        focusedErrorBorder: themeTextField(),
                      ),

                      items: careerTypeOptions.map((String option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedCareer = newValue!;
                        });
                      },
                    )

                    : Container(),

                  const Padding(padding: EdgeInsets.only(top: 20.0)),
      
                  ElevatedButton(
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                      backgroundColor: MaterialStateProperty.all(MyColors.yellow),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      if((typeController.text == "Alumno" && emailController.text.contains("@unex.es")) 
                          || ((typeController.text == "Profesor" || typeController.text == "Administrativo") && emailController.text.contains("@alumnos.unex.es"))) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: MyColors.background3,
                                  title: const Text('Error de registro', style: TextStyle(color: MyColors.white)),
                                  content: const Text('El correo introducido no corresponde a ese tipo de usuario.', style: TextStyle(color: MyColors.white)),
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
                      } else if (_formKey.currentState!.validate() && _passwordKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              backgroundColor: MyColors.background3,
                              title: const Text('Registrando...', style: TextStyle(color: MyColors.white)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  const Text('Por favor, espere...', style: TextStyle(color: MyColors.white)),
                                ],
                              ),
                            );
                          },
                        );

                        UserController userRegister = UserController();
                        ChatUser? user = await userRegister.register(nameController.text, emailController.text, typeController.text, passwordController.text, selectedCareer!);
                        
                        if(user == null) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ),
                                backgroundColor: MyColors.background3,
                                title: const Text('Error de registro', style: TextStyle(color: MyColors.white)),
                                content: const Text('El email ya existe.', style: TextStyle(color: MyColors.white)),
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
                                title: const Text('Registrado correctamente', style: TextStyle(color: MyColors.white)),
                                content: const Text('Se ha enviado un correo de verificación al correo introducido, verifique para iniciar sesión. Revise su carpeta de spam de Outlook.', style: TextStyle(color: MyColors.white)),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                          return MaterialApp(
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
                      }
                    },
                    child: Text('Registrarse', style: title2().copyWith(fontWeight: FontWeight.bold)),
                  ),
      
                  Responsive.isMobile(context) 
                    ? MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                      
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: RichText(
                              text: TextSpan(
                                text: '¿Ya estás registrado? ',
                                style: title(),
                                children: [
                                  TextSpan(
                                    text: "Inicia sesión aquí",
                                    style: title().copyWith(decoration: TextDecoration.underline, color: MyColors.green),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : const Row(),
                    
                  const Padding(padding: EdgeInsets.only(left: 15.0, bottom: 40.0)),
                ],
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
