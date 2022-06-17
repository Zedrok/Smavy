import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TyCcontroller {
  late BuildContext context;
  late Function refresh;
  late String textFromFile;
  final String ruta = 'assets/textfiles/Terms_and_conditions.txt';

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    textFromFile = await getText();
    refresh();
  }

  Future<String> getText() async {
    String response;

    response = await rootBundle.loadString(ruta);

    return response;
  }
}
