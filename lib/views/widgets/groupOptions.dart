import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:ccchat/services/GroupServiceFirebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import '../../models/Group.dart';
import '../../models/User.dart';
import '../styles/responsive.dart';
import '../styles/styles.dart';
import 'components/UserListWidget.dart';
import 'package:excel/excel.dart';

class GroupOptions extends StatefulWidget {
  Group? group;
  final ChatUser user;

  final Function? onExitSelected;

  GroupOptions({super.key, required this.group, required this.user, this.onExitSelected});

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  String? selectedUserType, selectedCareerType;

  final List<String> userTypeOptions = [
    'Todos los usuarios',
    'Alumno',
    'Delegado',
    'Subdelegado',
    'Profesor',
    'Administrativo',
  ];
  final List<String> careerTypeOptions = [
    'Grado en Ingeniería Informática en Tecnologías de la Información',
    'Grado en Ingeniería Telemática en Telecomunicaciones',
    'Doble Grado en Ingeniería Informática y Telemática',
    'Grado en Ingeniería en Diseño Industrial y Desarrollo de Producto',
    'Grado en Enfermería',
  ];

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Uint8List? imageBytes;

    Future<void> _pickImage() async {
      imageBytes = await ImagePickerWeb.getImageAsBytes();
    }

    List<String> getColumnList(List<List<Data?>> rows, int columnIndex, String columnName) {
      return rows
          .where((row) =>
              !row[columnIndex].isNull &&
              row[columnIndex]?.value != null &&
              row[columnIndex]?.value.toString() != columnName)
          .map((row) => row[columnIndex]!.value.toString())
          .toList();
    }

    int? lookForIndexes(List<List<Data?>> rows, String columnName) {
      int rowIndex = -1;
      int columnIndex = -1;

      for (int i = 0; i < rows.length; i++) {
        List<Data?> columnList = rows[i];
        for (int j = 0; j < columnList.length; j++) {
          if (columnList[j]?.value.toString() == columnName) {
            rowIndex = i;
            columnIndex = j;
            break;
          }
        }

        if (rowIndex != -1) {
          break;
        }
      }

      if (rowIndex != -1) {
        return columnIndex == -1 ? null : columnIndex;
      } else {
        print("'Nombre' no se encontró en ninguna lista.");
        return null;
      }
    }
    
    return Padding(
      padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 0) : const EdgeInsets.only(top: 30.0),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          color: MyColors.background2,
        ),
        width: Responsive.isMobile(context) ? size.width : size.width * 0.4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: Responsive.isMobile(context) ? const BorderRadius.only(bottomLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0)) : const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                color: MyColors.background3,
              ),
              child: Padding(
                padding: Responsive.isMobile(context) ? const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 20.0, right: 20.0) : const EdgeInsets.only(bottom: 15.0, top: 15.0, left: 50.0, right: 50.0),
                child: Row(
                  children: [
                    widget.group!.image != null
                      ? CircleAvatar(
                        backgroundImage: MemoryImage(widget.group!.image!),
                        maxRadius: 15.0,
                        minRadius: 15.0)
                      : const CircleAvatar(
                        backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'),
                        maxRadius: 15.0,
                        minRadius: 15.0),
                        
                    const Padding(padding: EdgeInsets.only(left: 10.0)),

                    Text(widget.group!.name!, style: nameGroups()),
                  
                    const Spacer(),
                  
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          if (Responsive.isMobile(context)) {
                            Navigator.pop(context);
                          } else {
                            widget.onExitSelected!();
                          }
                        },
                        child: SizedBox(
                          width: 40,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: SvgPicture.asset('../assets/icons/Cerrar.svg'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    
            Expanded(
              child: Padding(
                padding: Responsive.isMobile(context) ? const EdgeInsets.only(top: 20.0, bottom: 10.0, left: 30.0, right: 30.0) : const EdgeInsets.only(top: 30.0, bottom: 30.0, left: 60.0, right: 60.0),
                child: ListView(
                  children: [
                    isUserU1Admin()
                      ? Column(
                          children: [
                            Text("Añadir integrantes", style: title()),
            
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                              child: Material(
                                child: ExpansionTile(
                                  title: Text("Añadir por email", style: searcher()),
                                  iconColor: MyColors.grey,
                                  collapsedIconColor: MyColors.grey,
                                  backgroundColor: MyColors.background2,
                                  collapsedBackgroundColor: MyColors.background2,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                      child: Row(
                                        children: [                   
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 20.0),
                                              child: TextFormField(
                                                controller: emailController,
                                                style: searcher(),
                                                cursorColor: MyColors.green,
                                                decoration: InputDecoration(
                                                  hintText: 'Introduzca el email',
                                                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                                  filled: true,
                                                  fillColor: MyColors.background3,
                                                  enabledBorder: themeTextField(),
                                                  focusedBorder: themeTextField(),
                                                  errorBorder: themeTextField(),
                                                  disabledBorder: themeTextField(),
                                                  focusedErrorBorder: themeTextField(),
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
                                              var updatedGroup = await GroupServiceFirebase().addUserToMembersWithEmail(widget.group!, widget.user, emailController.text, context);
                                              if (updatedGroup != null) {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15.0),
                                                      ),
                                                      backgroundColor: MyColors.background3,
                                                      title: const Text('Añadido correctamente', style: TextStyle(color: MyColors.white)),
                                                      content: const Text('Se han añadido los usuarios registrados con los email introducidos. Si algún usuario no es introducido es por no existir en la base de datos.', style: TextStyle(color: MyColors.white)),
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
                                                  widget.group = updatedGroup;
                                                });
                                              }
                                            },
                                            child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
            
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Material(
                                child: ExpansionTile(
                                  title: Text("Añadir por archivo excel", style: searcher()),
                                  iconColor: MyColors.grey,
                                  collapsedIconColor: MyColors.grey,
                                  backgroundColor: MyColors.background2,
                                  collapsedBackgroundColor: MyColors.background2,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                      child: Row(
                                        children: [                   
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: 20.0),
                                              child: ElevatedButton(
                                                style: ButtonStyle( 
                                                  padding: MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                                                  backgroundColor: MaterialStateProperty.all(MyColors.green),
                                                  shape: MaterialStateProperty.all(
                                                    RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(15),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                    type: FileType.custom,
                                                    allowedExtensions: ['xls', 'xlsx'],
                                                  );

                                                  if (result != null) {
                                                    var bytes = result.files.single.bytes;
                                                    var excelFile = Excel.decodeBytes(bytes!);
                                                    const addressCell = "Dirección de correo";
                                                    List<String> addressList = [];

                                                    var table = excelFile.sheets[excelFile.sheets.keys.first];

                                                    if (table != null) {
                                                      int? columnIndex = lookForIndexes(table.rows, addressCell);
                                                      if (columnIndex != null) {
                                                        addressList = getColumnList(table.rows, columnIndex, addressCell);
                                                      }

                                                      var updatedGroup;
                                                      for (var email in addressList) {
                                                        updatedGroup =
                                                            await GroupServiceFirebase().addUserToMembersWithExcel(widget.group!, widget.user, email, context);
                                                      }

                                                      if (updatedGroup != null) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15.0),
                                                              ),
                                                              backgroundColor: MyColors.background3,
                                                              title: const Text('Añadido correctamente', style: TextStyle(color: MyColors.white)),
                                                              content: const Text('Se han añadido los usuarios registrados con los email introducidos. Si algún usuario no es introducido es por no existir en la base de datos.', style: TextStyle(color: MyColors.white)),
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
                                                          widget.group = updatedGroup;
                                                        });
                                                      }
                                                    }
                                                  }
                                                },
                                                child: Text('Seleccionar archivo', style: title2().copyWith(fontSize: 14.0)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
            
                            widget.group!.type == "Grupos difusión"
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Material(
                                    child: ExpansionTile(
                                      title: Text("Añadir por tipo de usuario", style: searcher()),
                                      iconColor: MyColors.grey,
                                      collapsedIconColor: MyColors.grey,
                                      backgroundColor: MyColors.background2,
                                      collapsedBackgroundColor: MyColors.background2,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                          child: Row(
                                            children: [                   
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 20.0),
                                                  child: DropdownButtonFormField<String>(
                                                    value: selectedUserType,
                                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                                    dropdownColor: MyColors.background3,
                                                    decoration: InputDecoration(
                                                      hintText: 'Seleccione el tipo de usuario',
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
                                                        selectedUserType = newValue;
                                                      });
                                                    },
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
                                                  var updatedGroup = await GroupServiceFirebase().addUserToMembersForType(widget.group!, widget.user, selectedUserType.toString(), context);
                                                 
                                                  if (updatedGroup != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15.0),
                                                          ),
                                                          backgroundColor: MyColors.background3,
                                                          title: const Text('Añadido correctamente', style: TextStyle(color: MyColors.white)),
                                                          content: const Text('Se han añadido los usuarios registrados con los email introducidos. Si algún usuario no es introducido es por no existir en la base de datos.', style: TextStyle(color: MyColors.white)),
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
                                                      widget.group = updatedGroup;
                                                    });
                                                  }
                                                },
                                                child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),
            
                              widget.group!.type == "Grupos difusión"
                              ? Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Material(
                                    child: ExpansionTile(
                                      title: Text("Añadir alumnos por grado", style: searcher()),
                                      iconColor: MyColors.grey,
                                      collapsedIconColor: MyColors.grey,
                                      backgroundColor: MyColors.background2,
                                      collapsedBackgroundColor: MyColors.background2,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                          child: Row(
                                            children: [                   
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets.only(right: 20.0),
                                                  child: DropdownButtonFormField<String>(
                                                    value: selectedCareerType,
                                                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                                                    dropdownColor: MyColors.background3,
                                                    decoration: InputDecoration(
                                                      hintText: 'Seleccione el grado',
                                                      hintStyle: const TextStyle(color: MyColors.grey),
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
                                                    onChanged: (String? newValue) {
                                                      setState(() {
                                                        selectedCareerType = newValue;
                                                      });
                                                    },
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
                                                  var updatedGroup = await GroupServiceFirebase().addUserToMembersForCareer(widget.group!, widget.user, selectedCareerType.toString(), context);
                                                  if (updatedGroup != null) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15.0),
                                                          ),
                                                          backgroundColor: MyColors.background3,
                                                          title: const Text('Añadido correctamente', style: TextStyle(color: MyColors.white)),
                                                          content: const Text('Se han añadido los usuarios correctamente.', style: TextStyle(color: MyColors.white)),
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
                                                      widget.group = updatedGroup;
                                                    });
                                                  }
                                                },
                                                child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container(),

                              Text("Opciones del grupo", style: title()),
            
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                                child: Material(
                                  child: ExpansionTile(
                                    title: Text("Modificar nombre de grupo", style: searcher()),
                                    iconColor: MyColors.grey,
                                    collapsedIconColor: MyColors.grey,
                                    backgroundColor: MyColors.background2,
                                    collapsedBackgroundColor: MyColors.background2,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                        child: Row(
                                          children: [                   
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20.0),
                                                child: TextFormField(
                                                  controller: nameController,
                                                  style: searcher(),
                                                  cursorColor: MyColors.green,
                                                  decoration: InputDecoration(
                                                    hintText: 'Introduzca nuevo nombre',
                                                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                                                    filled: true,
                                                    fillColor: MyColors.background3,
                                                    enabledBorder: themeTextField(),
                                                    focusedBorder: themeTextField(),
                                                    errorBorder: themeTextField(),
                                                    disabledBorder: themeTextField(),
                                                    focusedErrorBorder: themeTextField(),
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
                                                if (nameController.text.isNotEmpty) {
                                                  var updated = await GroupServiceFirebase().updateNameGroup(widget.group!.id, nameController.text, widget.group!.type!);
                                                  if (updated) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15.0),
                                                          ),
                                                          backgroundColor: MyColors.background3,
                                                          title: const Text('Modificado correctamente', style: TextStyle(color: MyColors.white)),
                                                          content: const Text('Se ha modificado correctamente.', style: TextStyle(color: MyColors.white)),
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
                                                      widget.group!.name = nameController.text;
                                                    });
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
                                                        title: const Text('Error al modificar el nombre', style: TextStyle(color: MyColors.white)),
                                                        content: const Text('El nombre que ha introducido está vacío.', style: TextStyle(color: MyColors.white)),
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
                                              child: Text('Enviar', style: title2().copyWith(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
              
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Material(
                                  child: ExpansionTile(
                                    title: Text("Modificar avatar del grupo", style: searcher()),
                                    iconColor: MyColors.grey,
                                    collapsedIconColor: MyColors.grey,
                                    backgroundColor: MyColors.background2,
                                    collapsedBackgroundColor: MyColors.background2,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
                                        child: Row(
                                          children: [                   
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(right: 20.0),
                                                child: ElevatedButton(
                                                  style: ButtonStyle(
                                                    padding: MaterialStateProperty.all(const EdgeInsets.all(15.0)),
                                                    backgroundColor: MaterialStateProperty.all(MyColors.green),
                                                    shape: MaterialStateProperty.all(
                                                      RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(15),
                                                      ),
                                                    ),
                                                  ),
                                                  onPressed: () async {
                                                    await _pickImage();

                                                    if (imageBytes != null) {
                                                      String stringImage = String.fromCharCodes(imageBytes!);
                                                      imageBytes = Uint8List.fromList(stringImage.codeUnits);
                                                      var updated = await GroupServiceFirebase().updateImageGroup(widget.group!.id, imageBytes, widget.group!.type!);
                                                      
                                                      if (updated) {
                                                        showDialog(
                                                          context: context,
                                                          builder: (BuildContext context) {
                                                            return AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(15.0),
                                                              ),
                                                              backgroundColor: MyColors.background3,
                                                              title: const Text('Modificado correctamente', style: TextStyle(color: MyColors.white)),
                                                              content: const Text('Se ha modificado correctamente.', style: TextStyle(color: MyColors.white)),
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
                                                          widget.group!.image = imageBytes;
                                                        });
                                                      }
                                                    }
                                                  },
                                                  child: Text('Seleccionar foto', style: title2().copyWith(fontSize: 14.0)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Material(
                                  child: ExpansionTile(
                                    title: Text("Eliminar grupo", style: searcher()),
                                    iconColor: MyColors.grey,
                                    collapsedIconColor: MyColors.grey,
                                    backgroundColor: MyColors.background2,
                                    collapsedBackgroundColor: MyColors.background2,
                                    children: [
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
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(15.0),
                                                ),
                                                backgroundColor: MyColors.background4,
                                                title: Text('Eliminar grupo', style: title().copyWith(color: MyColors.white, fontWeight: FontWeight.bold)),
                                                content: const Text('¿Está seguro que desea eliminar el grupo? Perderá todos los mensajes.', style: TextStyle(color: MyColors.white)),
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
                                                        GroupServiceFirebase deleteGroup = GroupServiceFirebase();
                                                        Future<bool> group = deleteGroup.deleteGroup(widget.group!.id, widget.group!.type!);
                                                        
                                                        if(group == false) {
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
                                                                content: const Text('Se ha eliminado correctamente el grupo.', style: TextStyle(color: MyColors.white)),
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
                                        child: Text('Eliminar grupo', style: title2().copyWith(fontWeight: FontWeight.bold, fontSize: 14.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            
                          ],
                        )
                      : Container(),
                  
                    Center(child: Text("Lista de integrantes", style: title())),
                      
                    const Padding(padding: EdgeInsets.only(bottom: 30.0)),
                  
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.group?.members!.length,
                      itemBuilder: (context, index) {
                        return UserListWidget(
                          groupReturn: (group) {
                            setState(() {
                              widget.group = group;
                            });
                          },
                          group: widget.group,
                          idUser: widget.group?.members![index]['id']!,
                          isAdmin: isUserU1Admin(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ) 
          ],
        ),
      ),
    );
  }
  
  bool isUserU1Admin() {
      bool isMemberUserU1 = widget.group!.members!.any((member) => member['id'] == widget.user.id);
      bool isAdminMemberUserU1 = widget.group!.members!.any((member) => member['id'] == widget.user.id && member['type'] == 'Admin');
      return isMemberUserU1 && isAdminMemberUserU1;
  }

  OutlineInputBorder themeTextField() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(15)),
      borderSide: BorderSide(width: 0.01, color: MyColors.background3),
    );
  }
}