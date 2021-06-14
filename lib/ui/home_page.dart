import 'dart:io';

import 'package:flutter/material.dart';
import 'package:phone_contacts/helper/contact_helper.dart';
import 'package:phone_contacts/ui/contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {
  ORDER_AZ, ORDER_ZA
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  ContactHelper contactHelper = ContactHelper();

  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();

    _getAllContacts();
  }

  void _getAllContacts() {
    contactHelper.geAllContacts().then((data) {
      setState(() {
        contacts = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contacts"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton(itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(child: Text("Ordenar A-Z"), value: OrderOptions.ORDER_AZ,),
            const PopupMenuItem<OrderOptions>(child: Text("Ordenar Z-A"), value: OrderOptions.ORDER_ZA,),
          ],
            onSelected: _orderList,
          )],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
            child: Padding(padding: EdgeInsets.all(10.0),
              child: Row(children: [
                Container(width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contacts[index].img != null ? FileImage(
                              File(contacts[index].img)) : AssetImage(
                              "images/person.png"))),),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contacts[index].name ?? "", style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold),),
                      Text(contacts[index].email ?? "",
                        style: TextStyle(fontSize: 18.0),),
                      Text(contacts[index].phone ?? "", style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold),)
                    ],
                  ),
                )
              ],),)
        ),
      onTap: () {
        _showOptions(context, index);
      },
    );
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.ORDER_AZ:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.ORDER_ZA:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
  }

  void _showContactPage({ Contact contact }) async {
    // retorno da outra tela
    final recContact = await Navigator.push(context,
      MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null) {
      if(contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton(
                        child: Text("Excluír", style: TextStyle(color: Colors.red, fontSize: 20.0)),
                        onPressed: () {
                          contactHelper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
                      ),
                    )
                  ],
              ),
            );
          },
        );
      }
    );
  }
}
