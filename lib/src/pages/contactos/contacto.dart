import 'package:flutter/material.dart';

class ContactosPage extends StatelessWidget {
  const ContactosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Contactos'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )),
      body: Padding(
        padding: const EdgeInsets.only(top: 20, left: 20),
        child: ListView(
          children: [
            const Text(
              'Contactos : ',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: const [
                Text(
                  'Telefono :',
                  style: TextStyle(fontSize: 28),
                ),
                Text(
                  '+56931260191',
                  style: TextStyle(fontSize: 28),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 5,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Correo :',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 5,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'correo1@gmail.com',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 5,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'correo2@gmail.com',
              style: TextStyle(fontSize: 28),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
