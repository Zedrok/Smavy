import 'package:flutter/material.dart';

class AjustesPage extends StatelessWidget {
  const AjustesPage({Key? key}) : super(key: key);

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
          ListTile(
            title: const Text('Sobre nosotros'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('about_page');
            },
          ),
          ListTile(
            title: const Text('Contacto'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              Navigator.of(context).pushNamed('contactos_page');
            },
          ),
        ],
      ),
    );
  }
}
