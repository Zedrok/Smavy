// ignore_for_file: unused_local_variable

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/models/app_user.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/providers/storage_provider.dart';
import 'package:smavy/src/providers/user_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart' as utils;

class PerfilController {
  late BuildContext context;
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  late Function refresh;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late AuthProvider _authProvider;
  late UserProvider _userProvider;
  late ProgressDialog _progressDialog;
  late StorageProvider _storageProvider;

  late PickedFile? pickedFile;
  late File? imageFile;
  AppUser? user;

  Future? init(BuildContext context, Function refresh) {
    this.context = context;
    this.refresh = refresh;
    imageFile = File('assets/img/profile.png');
    pickedFile = PickedFile('assets/img/profile.png');
    _authProvider = AuthProvider();
    _userProvider = UserProvider();
    _storageProvider = StorageProvider();
    getUserInfo();
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    return null;
  }

  Future<void> getUserInfo() async {
    user = await _userProvider.getbyId(_authProvider.getUser()!.uid);
  }

  void update() async {
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // ignore: avoid_print
    print('Email: $email');
    // ignore: avoid_print
    print('Password: $password');

    _progressDialog.show();

    TaskSnapshot snapshot = await _storageProvider.uploadFile(pickedFile!);
    String imageUrl = await snapshot.ref.getDownloadURL();

    Map<String, dynamic> data = {'image': imageUrl};

    await _userProvider.update(data, _authProvider.getUser()!.uid);

    _progressDialog.hide();

    utils.Snackbar.showSnackbar(
        context, 'Se actualizo la imagen correctamente');

    /*if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      String msgError = 'Por favor, ingrese todos los campos.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return;
    }*/

    if (confirmPassword != password) {
      String msgError = 'Las contraseñas no coinciden.';
      // ignore: avoid_print
      print(msgError);
      utils.Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (password.length < 6) {
      String msgError = 'La contraseña debe tener al menos 6 caracteres.';
      // ignore: avoid_print
      print(msgError);
      utils.Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (!email.isValidEmail()) {
      String msgError = 'Por favor, ingrese un email válido.';
      // ignore: avoid_print
      print(msgError);
      utils.Snackbar.showSnackbar(context, msgError);
      return;
    }

    _progressDialog.show();

    try {
      bool isRegister = await _authProvider.register(email, password);

      if (isRegister) {
        // ignore: avoid_print
        print('El usuario está registrado');
      } else {
        // ignore: avoid_print
        print('El usuario no se pudo registrar');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      utils.Snackbar.showSnackbar(
          context, 'El usuario ya se encuentra registrado');
    }
    _progressDialog.hide();
  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    // ignore: unnecessary_null_comparison
    if (pickedFile != null) {
      imageFile = File(pickedFile!.path);
    } else {
      // ignore: avoid_print
      print('No se selecciono un archivo');
    }
    refresh();
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
