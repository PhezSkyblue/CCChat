import 'package:ccchat/services/GroupServiceFirebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/Group.dart';
import '../../models/User.dart';
import '../styles/responsive.dart';
import '../styles/styles.dart';
import 'components/UserListWidget.dart';

class GroupOptions extends StatefulWidget {
  final Group? group;
  final ChatUser user;

  final Function? onExitSelected;

  const GroupOptions({super.key, required this.group, required this.user, this.onExitSelected});

  @override
  State<GroupOptions> createState() => _GroupOptionsState();
}

class _GroupOptionsState extends State<GroupOptions> {
  TextEditingController _textEditingController = TextEditingController();
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
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    
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
                    const CircleAvatar(backgroundImage: AssetImage('../assets/images/DefaultAvatar.jpg'), maxRadius: 15.0, minRadius: 15.0),
                    
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
                                                controller: _textEditingController,
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
                                            onPressed: () {
                                              GroupServiceFirebase().addUserToMembersWithEmail(widget.group!, _textEditingController.text, context);

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
                                                    PlatformFile file = result.files.first;
                                                    String filePath = file.path!;
                                                    print('Ruta del archivo: $filePath');
                                                  } else {
                                                    print('Selección de archivo cancelada');
                                                  }
                                                },
                                                child: Text('Seleccionar archivo', style: title2().copyWith(fontSize: 14.0)),
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
                                            onPressed: () {
                                              GroupServiceFirebase().addUserToMembersWithExcel(widget.group!, _textEditingController.text, context);
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
                                                onPressed: () {
                                                  GroupServiceFirebase().addUserToMembersForType(widget.group!, selectedUserType.toString(), context);
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
                                                onPressed: () {
                                                  GroupServiceFirebase().addUserToMembersForCareer(widget.group!, selectedCareerType.toString(), context);
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