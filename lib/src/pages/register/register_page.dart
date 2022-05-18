import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
// import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:smavy/src/pages/register/register_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({ Key? key }) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final LoginController _con = LoginController();

  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    super.initState();
    // ignore: avoid_print
    print('INIT STATE');
    _con.init(context);

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _con.init(context);
      // ignore: avoid_print
      print('METODO SCHEDULER');
    });
  }

  @override
  Widget build(BuildContext context) {

    // ignore: avoid_print
    print('METODO BUILD');

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row( //Esto es para que se alinien a la izquierda
          children: const <Widget>[
            Text('Registro'),
          ],
        )
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // _bannerApp(context),
            _textRegister(),
            // _textDescription(),
            _textFieldName(),
            _textFieldEmail(),
            _textFieldPassword(),
            _textFieldConfirmPassword(),
            _buttonRegister(),
            _textHaveAccount(),
            // Expanded(child: Container()), Esto es para crear un objeto infinito
          ],
        ),
      ),
    );
  }

  Widget _textRegister(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 30, left:40),
      child: const Text(
        'Crear cuenta',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 28,
          fontFamily: 'NimbusSans'
        ),
      ),
    );
  }

  Widget _textHaveAccount(){
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 30, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '¿Ya tienes una cuenta? ',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
              fontWeight: FontWeight.w500, 
            ),
          ),
          GestureDetector(
            onTap: _con.goToLogin,
            child: const Text(
              'Inicia sesión',
              style: TextStyle(
                fontSize: 15,
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
          
        ],
      ),
    );
  }


  Widget _textFieldConfirmPassword(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: _con.confirmPasswordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Confirmar Contraseña',
          suffixIcon: Icon(
            Icons.lock_open_outlined,
            color: Colors.black38,
          )
        ),
      ),
    );
  }

  Widget _textFieldPassword(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: _con.passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Contraseña',
          suffixIcon: Icon(
            Icons.lock_open_outlined,
            color: Colors.black38,
          )
        ),
      ),
    );
  }

  Widget _textFieldEmail(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: _con.emailController,
        decoration: const InputDecoration(
          hintText: 'ejemplo@gmail.com',
          labelText: 'Email',
          suffixIcon: Icon(
            Icons.email_outlined,
            color: Colors.black38,
          )
        ),
      ),
    );
  }

  Widget _textFieldName(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: TextField(
        controller: _con.usernameController,
        decoration: const InputDecoration(
          labelText: 'Nombre',
          hintText: 'Tu nombre',
          suffixIcon: Icon(
            Icons.account_circle,
            color: Colors.black38,
          )
        ),
      ),
    );
  }

  Widget _buttonRegister(){
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: ButtonApp(
        text: 'Continuar',
        onPressed: _con.register,
      ),
    );
  }

  // Widget _textDescription(){
  //   return Container(
  //     alignment: Alignment.centerLeft,
  //     margin: const EdgeInsets.only(left: 40, bottom: 40),
  //     child: const Text(
  //       'Hola! Gracias por usar Smavy!',
  //       style: TextStyle(
  //         color: Colors.black54,
  //         fontSize: 16,
  //         fontFamily: 'NimbusSans',
  //       ),
  //     ),
  //   );
  // }

  // Widget _bannerApp(BuildContext context){
  //   return ClipPath(
  //     clipper: OvalBottomBorderClipper(),
  //     child: Container(
  //       color: Colors.teal,
  //       height: MediaQuery.of(context).size.height*0.2,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: const [
  //           Text(
  //             'Smavy',
  //             style: TextStyle(
  //               color: Colors.white,
  //               fontFamily: 'Tangerine-Regular',
  //               fontSize: 40,
  //               fontWeight: FontWeight.w600
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}

