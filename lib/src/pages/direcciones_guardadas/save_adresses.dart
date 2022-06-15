import 'package:flutter/material.dart';

class SaveAdressPage extends StatelessWidget {
  const SaveAdressPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Direcciones Guardadas'),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Container());
  }
}
