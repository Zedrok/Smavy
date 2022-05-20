import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/utils/my_progress_dialog.dart';
import 'package:smavy/src/utils/snackbar.dart';

class LoginController {
  
  late BuildContext context;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  late AuthProvider _authProvider;
  late ProgressDialog _progressDialog;

  Future? init(BuildContext context){
    this.context = context;
    _authProvider = AuthProvider();
    _progressDialog = MyProgressDialog.createProgressDialog(context, 'Espere un momento...');

    return null;
  }

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if(email.isEmpty || password.isEmpty){
      String msgError = 'Por favor, ingrese todos los campos.';
      // ignore: avoid_print
      print(msgError);
      Snackbar.showSnackbar(context, msgError );
      return;
    }
    // ignore: avoid_print
    print('Email: $email');
    // ignore: avoid_print
    print('Password: $password');

    _progressDialog.show();

    try {
      bool isLogin = await _authProvider.login(email, password);

      if(isLogin){
        String msgSnackbar = 'Inicio de sesión exitoso';
        // ignore: avoid_print
        print(msgSnackbar);
        Snackbar.showSnackbar(context, msgSnackbar, true);
        
        Future.delayed(const Duration(milliseconds: 200), () {
          goToHomePage();
        });

      }else{
        String msgSnackbar = 'No se pudo iniciar Sesión';
        // ignore: avoid_print
        print(msgSnackbar);
        Snackbar.showSnackbar(context, msgSnackbar);
      }
    } catch(error){
      // ignore: avoid_print
      // print('Error: $error');
      String msgSnackbar = 'Usuario o contraseña incorrecta';
      // ignore: avoid_print
      print(msgSnackbar);
      Snackbar.showSnackbar(context, msgSnackbar);
    }
    _progressDialog.hide();

  }

  void goToRegisterPage(){
    Navigator.pushNamed(context, 'register');
  }

  void goToHomePage(){
    Navigator.pushNamed(context, 'mainMap');
  }
}