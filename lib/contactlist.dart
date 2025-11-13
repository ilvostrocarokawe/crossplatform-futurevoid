// lib/contactlist.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Per chiamare
import 'package:share_plus/share_plus.dart';   // Per condividere

/// Modello dati per un contatto (Persona).
class Person {
  String firstName;
  String lastName;
  List<String> phones; // Un contatto può avere più numeri

  Person({
    required this.firstName,
    required this.lastName,
    required this.phones,
  });

  /// Getter per ottenere il nome completo.
  String get fullName => '$firstName $lastName';
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  // Lista di contatti inizializzata con dati di esempio.
  final List<Person> contacts = [
    Person(
        firstName: 'Mario',
        lastName: 'Rossi',
        phones: ['3331112233', '02123456']),
    Person(
        firstName: 'Laura', lastName: 'Bianchi', phones: ['3384455667']),
    Person(
        firstName: 'Giovanni',
        lastName: 'Verdi',
        phones: ['3409988776', '06543210', '3471122334']),
    Person(
        firstName: 'Anna', lastName: 'Neri', phones: ['3391234567']),
  ];

  /// Gestisce la chiamata ad un numero di telefono specifico usando lo schema 'tel:'.
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (!await launchUrl(launchUri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossibile effettuare la chiamata.')),
        );
      }
    }
  }

  /// Gestisce la condivisione dei dettagli di un contatto come testo (Bonus).
  Future<void> _shareContact(Person contact) async {
    final String phoneList = contact.phones.join(', ');
    final String textToShare =
        'Contatto: ${contact.fullName}\nNumeri: $phoneList';
    await Share.share(textToShare);
  }

  /// Mostra una finestra di dialogo per modificare nome e cognome (Bonus).
  void _editContact(Person contact, int index) {
    final TextEditingController firstNameController =
        TextEditingController(text: contact.firstName);
    final TextEditingController lastNameController =
        TextEditingController(text: contact.lastName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica Contatto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Cognome'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annulla'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Salva'),
              onPressed: () {
                // Aggiorna lo stato del contatto e l'interfaccia utente
                setState(() {
                  contacts[index].firstName = firstNameController.text;
                  contacts[index].lastName = lastNameController.text;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Contatti'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final Person contact = contacts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 1,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  contact.firstName[0],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(contact.fullName),
              // Mostra tutti i numeri nel sottotitolo
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contact.phones
                    .map((phone) => Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(phone,
                              style:
                                  const TextStyle(fontStyle: FontStyle.italic)),
                        ))
                    .toList(),
              ),
              trailing: SizedBox(
                width: 150, 
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // Pulsante Modifica (Bonus)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _editContact(contact, index),
                      tooltip: 'Modifica Contatto',
                    ),
                    
                    // Logica di chiamata: pulsante diretto se un numero, menu se multipli
                    if (contact.phones.length == 1)
                      IconButton(
                        icon: const Icon(Icons.call, color: Colors.green),
                        onPressed: () => _makePhoneCall(contact.phones.first),
                        tooltip: 'Chiama',
                      )
                    else
                      //                       PopupMenuButton<String>(
                        icon: const Icon(Icons.call, color: Colors.green),
                        tooltip: 'Chiama...',
                        onSelected: _makePhoneCall,
                        itemBuilder: (BuildContext context) {
                          return contact.phones.map((String phone) {
                            return PopupMenuItem<String>(
                              value: phone,
                              child: Text(phone),
                            );
                          }).toList();
                        },
                      ),
                      
                    // Pulsante Condividi (Bonus)
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.blue),
                      onPressed: () => _shareContact(contact),
                      tooltip: 'Condividi',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}