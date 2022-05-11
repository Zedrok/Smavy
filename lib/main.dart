import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smavy/src/pages/home/home_page.dart';
import 'package:smavy/src/pages/login/login_page.dart';
import 'package:smavy/src/pages/register/register_page.dart';

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
        appBarTheme: const AppBarTheme(elevation: 0)
      ),
      initialRoute: 'login',
      routes: {
        'home': (BuildContext context) => const HomePage(),
        'login': (BuildContext context) => const LoginPage(),
        'register': (BuildContext context) => const RegisterPage(), 
      },
    );
  }
}
