import 'package:flutter/material.dart';

class ContactosPage extends StatelessWidget {
  const ContactosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Ajustes'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: ListView(
        children: [
          const Text('Contactos'),
          Row(
            children: const [
              Text('Telefono :'),
              Text('+56931260191'),
            ],
          ),
          ListTile(
            title: const Text('Terminos y condiciones'),
            leading: const Icon(Icons.perm_device_information_outlined),
            onTap: () {
              Navigator.of(context).pushNamed('terminos_condiciones_page');
            },
            trailing: const Icon(
              Icons.keyboard_arrow_right,
            ),
          ),
        ],
      ),
    );
  }
}
