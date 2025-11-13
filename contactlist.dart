import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

/// Modello dati per un contatto (Person)
class Person {
  String firstName;
  String lastName;
  List<String> phones;

  Person({
    required this.firstName,
    required this.lastName,
    required this.phones,
  });

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  // Lista contatti con dati di esempio
  final List<Person> contacts = [
    Person(
      firstName: 'Mario',
      lastName: 'Rossi',
      phones: ['333-111-2233', '02-123456'],
    ),
    Person(
      firstName: 'Laura',
      lastName: 'Bianchi',
      phones: ['338-445-5667'],
    ),
    Person(
      firstName: 'Giovanni',
      lastName: 'Verdi',
      phones: ['340-998-8776', '06-543210', '347-112-2334'],
    ),
    Person(
      firstName: 'Anna',
      lastName: 'Neri',
      phones: ['339-123-4567'],
    ),
  ];

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEC4899),
      const Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }

  /// Effettua una chiamata telefonica
  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanNumber);

    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Impossibile effettuare la chiamata'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Errore durante la chiamata'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Condivide i dettagli del contatto
  Future<void> _shareContact(Person contact) async {
    final phoneList = contact.phones.join('\n');
    final textToShare = 'Contatto: ${contact.fullName}\n\nNumeri:\n$phoneList';
    await Share.share(textToShare);
  }

  /// Mostra dialog per modificare il contatto
  void _editContact(Person contact, int index) {
    final firstNameController = TextEditingController(text: contact.firstName);
    final lastNameController = TextEditingController(text: contact.lastName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifica Contatto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Cognome',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla'),
            ),
            ElevatedButton(
              onPressed: () {
                if (firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty) {
                  setState(() {
                    contacts[index].firstName = firstNameController.text;
                    contacts[index].lastName = lastNameController.text;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Contatto aggiornato!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Salva'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Lista Contatti'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: contacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nessun contatto',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: _getAvatarColor(index),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                contact.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Nome e telefoni
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  contact.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...contact.phones.map((phone) => Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            phone,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          // Pulsanti azione
                          Column(
                            children: [
                              // Modifica
                              IconButton(
                                onPressed: () => _editContact(contact, index),
                                icon: const Icon(Icons.edit_outlined),
                                color: Colors.grey.shade700,
                                tooltip: 'Modifica',
                              ),
                              // Chiama
                              if (contact.phones.length == 1)
                                IconButton(
                                  onPressed: () =>
                                      _makePhoneCall(contact.phones.first),
                                  icon: const Icon(Icons.call),
                                  color: Colors.green.shade600,
                                  tooltip: 'Chiama',
                                )
                              else
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.call,
                                    color: Colors.green.shade600,
                                  ),
                                  tooltip: 'Chiama',
                                  onSelected: _makePhoneCall,
                                  itemBuilder: (context) {
                                    return contact.phones.map((phone) {
                                      return PopupMenuItem<String>(
                                        value: phone,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.phone, size: 18),
                                            const SizedBox(width: 8),
                                            Text(phone),
                                          ],
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              // Condividi
                              IconButton(
                                onPressed: () => _shareContact(contact),
                                icon: const Icon(Icons.share_outlined),
                                color: Colors.blue.shade600,
                                tooltip: 'Condividi',
                              ),
                            ],
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