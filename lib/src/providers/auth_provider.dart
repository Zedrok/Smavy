import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthProvider {
  late FirebaseAuth _firebaseAuth;

  AuthProvider() {
    _firebaseAuth = FirebaseAuth.instance;
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  DocumentReference<Map<String, dynamic>> getUserData(String id) {
    return FirebaseFirestore.instance.collection('AppUsers').doc(id);
  }

  void checkIfUserIsLogged(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // ignore: avoid_print
        print('El usuario está logeado de antes');
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, 'mainMap', (route) => false);
        });
        // Navigator.pushNamed(context, 'login');
      } else {
        // ignore: avoid_print
        print('El usuario no está logeado');
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      }
    });
  }

  Future<bool> login(String email, String password) async {
    String errorMessage;

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      // ignore: avoid_print
      print(error);
      // CORREO INVALIDO
      // PASSWORD INCORRECTO
      // NO HAY CONEXION A INTERNET
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }

    return true;
  }

  Future<bool> register(String email, String password) async {
    String errorMessage;

    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (error) {
      // ignore: avoid_print
      print(error);
      // CORREO INVALIDO
      // PASSWORD INCORRECTO
      // NO HAY CONEXION A INTERNET
      errorMessage = error.hashCode as String;
      return Future.error(errorMessage);
    }

    return true;
  }
}
