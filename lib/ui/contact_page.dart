import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_contacts/helper/contact_helper.dart';

class ContactPage extends StatefulWidget {
  final Contact contact;

  // contact é opcional
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;
  bool _contactInEdition = false;

  File _image;
  final picker = ImagePicker();

  final _nameFocus = FocusNode();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      nameController.text = _editedContact.name;
      emailController.text = _editedContact.email;
      phoneController.text = _editedContact.phone;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(_editedContact.name ?? "New Contact"),
            backgroundColor: Colors.red,
            centerTitle: true,
          ),
          backgroundColor: Colors.white,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                GestureDetector(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact.img != null
                                ? FileImage(File(_editedContact.img))
                                : AssetImage("images/person.png"))),
                  ),
                  onTap: () {
                    _getImage();
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Name"),
                  controller: nameController,
                  focusNode: _nameFocus,
                  onChanged: (text) {
                    _contactInEdition = true;
                    _editedContact.name = text;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                  onChanged: (text) {
                    _contactInEdition = true;
                    _editedContact.email = text;
                  },
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: (text) {
                    _contactInEdition = true;
                    _editedContact.phone = text;
                  },
                )
              ],
            ),
          )),
    );
  }

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        setState(() {
          _editedContact.img = pickedFile.path;
        });
      } else {
        return;
      }
    });
  }

  Future<bool> _requestPop() {
    if (_contactInEdition) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar as alterações?"),
              content: Text("Se sair as alterações serão perdidas."),
              actions: [
                TextButton(
                    onPressed: () {
                      // remove o dialog
                      Navigator.pop(context);
                    },
                    child: Text("Cancelar")),
                TextButton(
                    onPressed: () {
                      // remove o dialog
                      Navigator.pop(context);
                      // remove a tela de contato
                      Navigator.pop(context);
                    },
                    child: Text("Sim")),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
