import 'package:ccchat/views/styles/styles.dart';
import 'package:ccchat/views/widgets/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../controllers/UserController.dart';
import '../../models/User.dart';
import '../HomeView.dart';
import '../styles/responsive.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPasswordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController emailRecController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final _passwordKey = GlobalKey<FormFieldState>();
  final _formKey = GlobalKey<FormState>();

  UserController userService = UserController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Material(
      color: MyColors.background4,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Responsive.isMobile(context)
            ? Align(
              alignment: Alignment.topLeft,
              child: Image(
                image: const AssetImage('../assets/images/mobileLoginHeader.png'),
                height: size.height / 2 - 60,
              ),
            )
            : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image(
                  image: const AssetImage('../assets/images/desktopLoginHeader.png'),
                  height: size.height / 2,
                ),
            ),
          
            Padding(
              padding: Responsive.isMobile(context) ? const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0) : const EdgeInsets.only(left: 80.0, right: 80.0, top: 40.0),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        style: title(),
                        controller: emailController,
                        autofillHints: const [AutofillHints.email],
                        autocorrect: false,
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
                            return 'El correo introducido es incorrecto.';
                          }
                          return null;
                        },

                        onFieldSubmitted: (value) async {
                          if (_formKey.currentState!.validate() &&
                              _passwordKey.currentState!.validate()) {
                            UserController userLogin = UserController();
                            ChatUser? user = await userLogin.login(
                                emailController.text,
                                passwordController.text,
                                context);

                            if (user != null) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return HomeView(user: user);
                              }));
                            }
                          }
                        },
                      ),
                        
                      const Padding(padding: EdgeInsets.only(top: 20.0)),
                        
                      TextFormField(
                        style: title(),
                        controller: passwordController,
                        key: _passwordKey,
                        autofillHints: const [AutofillHints.password],
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
                          }
                          return null;
                        },

                        onFieldSubmitted: (value) async {
                          if (_formKey.currentState!.validate() &&
                              _passwordKey.currentState!.validate()) {
                            UserController userLogin = UserController();
                            ChatUser? user = await userLogin.login(
                                emailController.text,
                                passwordController.text,
                                context);

                            if (user != null) {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return HomeView(user: user);
                              }));
                            }
                          }
                        },
                      ),
                    
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            emailController.clear();
                            passwordController.clear();
                            _formKey.currentState?.reset();
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: MyColors.background4,
                                  title: Text('Recuperar contraseña', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                                  content: TextFormField(
                                    controller: emailRecController,
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Introduzca un correo electrónico válido.';
                                      } else if (!value.contains("@")) {
                                        return 'El correo introducido es incorrecto.';
                                      }
                                      return null;
                                    },
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
                                        onPressed: () {
                                            FirebaseAuth.instance.sendPasswordResetEmail(email: emailRecController.text)
                                                .then((value) {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                    ),
                                                    backgroundColor: MyColors.background3,
                                                    title: const Text('Recuperación de contraseña', style: TextStyle(color: MyColors.white)),
                                                    content: Text('Se ha enviado un correo electrónico a ${emailRecController.text} para restablecer tu contraseña.',
                                                        style: const TextStyle(color: MyColors.white)),
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
                                            }).catchError((error) {
                                              Navigator.pop(context);
                                              showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15.0),
                                                    ),
                                                    backgroundColor: MyColors.background3,
                                                    title: const Text('Error', style: TextStyle(color: MyColors.white)),
                                                    content: const Text('No se pudo enviar el correo de recuperación de contraseña.',
                                                        style: TextStyle(color: MyColors.white)),
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
                                            });
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
                      
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: RichText(
                              text: TextSpan(
                                text: '¿Olvidaste la contraseña?',
                                style: title(),
                              ),
                            ),
                          ),
                        ),
                      ),
                        
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
                          if (_formKey.currentState!.validate() && _passwordKey.currentState!.validate()) {
                            UserController userLogin = UserController();
                            ChatUser? user = await userLogin.login(emailController.text, passwordController.text, context);
                            
                            if(user != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return HomeView(user: user);
                                })
                              );
                            }
                          }
                        },
                        child: Text('Iniciar sesión', style: title2().copyWith(fontWeight: FontWeight.bold)),
                      ),
                    
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            emailController.clear();
                            passwordController.clear();
                            _formKey.currentState?.reset();
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return Signup();
                              })
                            );
                          },
                      
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: RichText(
                              text: TextSpan(
                                text: '¿Aún no tienes una cuenta? ',
                                style: title(),
                                children: [
                                  TextSpan(
                                    text: "Registrate aquí",
                                    style: title().copyWith(color: MyColors.green, decoration: TextDecoration.underline),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
