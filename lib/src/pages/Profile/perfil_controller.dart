import 'package:flutter/cupertino.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/providers/user_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';

class PerfilController {
  late final BuildContext context;

  TextEditingController emailController = TextEditingController();
  TextEditingController providerIdController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  final UserProvider _userProvider = UserProvider();

  ProgressDialog? _progressDialog;

  Future? init(BuildContext context) {
    this.context = context;
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    return null;
  }

  void updateEmail() async {
    String email = emailController.text.trim();
    // ignore: avoid_print
    print('Email: $email');

    verifyEmail(email);

    _progressDialog!.show();

    try {
      bool isUpdate = await _userProvider.updateUserData(1, email);

      if (isUpdate) {
        // ignore: avoid_print
        print('Se ha cambiado el correo');
      } else {
        // ignore: avoid_print
        print('No se cambio el correo');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      Snackbar.showSnackbar(context, 'Error al actualizar Email');
    }
    _progressDialog!.hide();
  }

  void updateProviderId() async {
    String providerId = providerIdController.text.trim();
    String confirmPassword = passwordController.text.trim();
    // ignore: avoid_print
    print('PrviderId: $providerId');

    isValidPass(providerId);

    verifyPass(providerId, confirmPassword);

    _progressDialog!.show();

    try {
      bool isUpdate = await _userProvider.updateUserData(2, providerId);

      if (isUpdate) {
        // ignore: avoid_print
        print('Se ha cambiado la contraseña');
      } else {
        // ignore: avoid_print
        print('No se cambio la contraseña');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      Snackbar.showSnackbar(context, 'Error al actualizar contraseña');
    }
    _progressDialog!.hide();
  }

  void updateDisplayName() async {
    String userName = displayNameController.text.trim();
    // ignore: avoid_print
    print('PrviderId: $userName');

    _progressDialog!.show();

    try {
      bool isUpdate = await _userProvider.updateUserData(0, userName);

      if (isUpdate) {
        // ignore: avoid_print
        print('Se ha cambiado el nombre de usuario');
      } else {
        // ignore: avoid_print
        print('No se cambio el nombre de usuario');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      Snackbar.showSnackbar(context, 'Error al actualizar userName');
    }
    _progressDialog!.hide();
  }

  bool isValidPass(String password) {
    if (password.length < 6) {
      String msgError = 'La contraseña debe tener al menos 6 caracteres.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return true;
    }
    return false;
  }

  bool verifyPass(String password, String confirmPassword) {
    if (confirmPassword != password) {
      String msgError = 'Las contraseñas no coinciden.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return true;
    }
    return false;
  }

  bool verifyEmail(String email) {
    if (!email.isValidEmail()) {
      String msgError = 'Por favor, ingrese un email válido.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return false;
    }
    return true;
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
