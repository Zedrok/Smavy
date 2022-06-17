import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/models/app_user.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/providers/user_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';

class RegisterController {
  late BuildContext context;

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  late AuthProvider _authProvider;
  late UserProvider _userProvider;
  late ProgressDialog _progressDialog;
  bool isCheck = false;

  Future? init(BuildContext context) {
    this.context = context;
    _authProvider = AuthProvider();
    _userProvider = UserProvider();
    _progressDialog =
        MyProgressDialog.createProgressDialog(context, 'Espere un momento...');
    return null;
  }

  void goToLogin() {
    Navigator.pushNamed(context, 'login');
  }

  void register() async {
    String username = usernameController.text;
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // ignore: avoid_print
    print('Email: $email');
    // ignore: avoid_print
    print('Password: $password');

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      String msgError = 'Por favor, ingrese todos los campos.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (confirmPassword != password) {
      String msgError = 'Las contraseñas no coinciden.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (password.length < 6) {
      String msgError = 'La contraseña debe tener al menos 6 caracteres.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (!email.isValidEmail()) {
      String msgError = 'Por favor, ingrese un email válido.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError);
      return;
    }

    if (isCheck == false) {
      String msgError =
          'Por favor, lea los Terminos de condiciones y servicios.';
      Snackbar.showSnackbar(context, msgError);
      return;
    }
    try {
      _progressDialog.show();

      bool isRegister = await _authProvider.register(email, password);

      if (isRegister) {
        AppUser appUser = AppUser(
          id: _authProvider.getUser()!.uid,
          username: username,
          email: _authProvider.getUser()!.email!,
          password: password,
          image: 'image',
        );

        await _userProvider.create(appUser);
        // ignore: avoid_print
        Snackbar.showSnackbar(context, 'Usuario registrado con exito', true);
        _progressDialog.hide();
        goToLogin();
      } else {
        // ignore: avoid_print
        Snackbar.showSnackbar(context, 'Error al registrar usuario');
      }
    } catch (error) {
      // ignore: avoid_print
      print('Error: $error');
      Snackbar.showSnackbar(context, 'El usuario ya se encuentra registrado');
    } finally {
      _progressDialog.hide();
    }
  }
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }
}
