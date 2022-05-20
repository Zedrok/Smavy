import 'package:flutter/material.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/utils/shared_pref.dart';

class HomePageController {
  late BuildContext context;
  late SharedPref _sharedPref;
  late String _typeUser;

  late AuthProvider _authProvider;

  Future? init(BuildContext context){
    this.context = context;
    _authProvider = AuthProvider();
    _sharedPref = SharedPref();
    _typeUser = 'driver';
    _sharedPref.save('typeUser', _typeUser);
    
    // ignore: avoid_print
    print('==home_cont====INIT=========');
    _authProvider.checkIfUserIsLogged(context);
    // ignore: avoid_print
    print(_typeUser);

    return null;
  }
}