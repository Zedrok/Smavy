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

  final AuthProvider _authProvider = AuthProvider();
  final UserProvider _userProvider = UserProvider();
  late ProgressDialog _progressDialog;
  final StorageProvider _storageProvider = StorageProvider();

  PickedFile pickedFile = PickedFile('assets/img/profile.png');
  File? imageFile;
  late AppUser user;

  Future init(BuildContext context, Function refresh) async {
    this.context = context;
    this.refresh = refresh;
    await getUser();
    imageFile = File(pickedFile.path);
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
  }

  getUser() async {
    AppUser userAux;

    userAux = await _userProvider.getbyId(_authProvider.getUser()!.uid);

    refresh().setState(() {
      user = userAux;
    });
  }

  void update() async {
    final uid = _authProvider.getUser()!.uid;

    if (!(usernameController.text == _authProvider.getUser()!.displayName)) {
      // ignore: unnecessary_null_comparison
      if (usernameController.text.isNotEmpty) {
        _progressDialog.show();

        String username = usernameController.text;

        Map<String, dynamic> data = {'username': username};

        await _userProvider.update(data, uid);
        await _authProvider.getUser()!.updateDisplayName(username);

        _progressDialog.hide();

        utils.Snackbar.showSnackbar(
            context, 'Se actualizo el username correctamente', true);
      }
    } else {
      utils.Snackbar.showSnackbar(
          context, 'No se puede usar el mismo nombre de usuario', false);
    }

    TaskSnapshot snapshot = await _storageProvider.uploadFile(pickedFile);
    String imageUrl = await snapshot.ref.getDownloadURL();

    Map<String, dynamic> data = {'image': imageUrl};

    _progressDialog.show();

    await _userProvider.update(data, uid);
    await _authProvider.getUser()!.updatePhotoURL(imageUrl);

    _progressDialog.hide();

    utils.Snackbar.showSnackbar(
        context, 'Se actualizo la imagen correctamente', true);
  }

  Future getImageFromGallery() async {
    // ignore: deprecated_member_use
    pickedFile = (await ImagePicker().getImage(source: ImageSource.gallery))!;
    // ignore: unnecessary_null_comparison
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
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
