import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Acerca de Smavy'),
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
        padding: EdgeInsets.zero,
        children: const [
          SizedBox(height: 10),
          ListTile(
            title: Text('item 1'),
          ),
          Divider(
            thickness: 1,
            indent: 10,
            endIndent: 10,
            color: Colors.grey,
            height: 5.0,
          ),
          ListTile(
            title: Text('item 2'),
          ),
        ],
      ),
    );
  }
}
