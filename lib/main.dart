import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smavy/src/pages/home/home_page.dart';
import 'package:smavy/src/pages/login/login_page.dart';
import 'package:smavy/src/pages/main_map/main_map_page.dart';
import 'package:smavy/src/pages/register/register_page.dart';
import 'package:smavy/src/pages/ajustes/ajustes_page.dart';
import 'package:smavy/src/pages/historial/historial.dart';
import 'package:smavy/src/pages/Profile/perfil.dart';
import 'package:smavy/src/pages/direcciones_guardadas/save_adresses.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smavy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.teal,
          appBarTheme: const AppBarTheme(elevation: 0)),
      initialRoute: 'home',
      routes: {
        'home': (BuildContext context) => const HomePage(),
        'mainMap': (BuildContext context) => const MainMapPage(),
        'login': (BuildContext context) => const LoginPage(),
        'register': (BuildContext context) => const RegisterPage(),
        'perfil': (BuildContext context) => const PerfilPage(),
        'historial': (BuildContext context) => const HistorialPage(),
        'dir_guardadas': (BuildContext context) => const SaveAdressPage(),
        'ajustes_page': (BuildContext context) => const AjustesPage(),
      },
    );
  }
}
