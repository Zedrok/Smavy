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
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: ListView(
          children: [
            SizedBox(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                    SizedBox(width: 40,child: Icon(Icons.whatsapp)),
                      Text(
                        'WhatsApp',
                        style: TextStyle(fontSize: 28),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      Text(
                        ' +56931260191',
                        style: TextStyle(fontSize: 24),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10,)
                ],
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 10,
              endIndent: 10,
              color: Colors.grey,
              height: 5.0,
            ),
            Column(
              children: [
                Row(
                  children: const [
                    SizedBox(width: 40,child: Icon(Icons.mail_outline)),
                    Text(
                      'Correo',
                      style: TextStyle(fontSize: 28),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                  child: Text(
                    'contacto.smavy@gmail.com',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
