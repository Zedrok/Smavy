import 'package:flutter/material.dart';

class PerfilPage extends StatelessWidget {
  const PerfilPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView(
        children: const [
          ListTile(
            title: Text('Item 1'),
            subtitle: Text('xd'),
          ),
          ListTile(
            title: Text('Item 2'),
            subtitle: Text('xd'),
          ),
          ListTile(
            title: Text('Item 3'),
            subtitle: Text('xd'),
          )
        ],
      ),
    );
  }
}
