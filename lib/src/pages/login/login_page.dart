import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:smavy/src/pages/login/login_controller.dart';
import 'package:smavy/src/widgets/button_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({ Key? key }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

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
      // appBar: AppBar(
      //   elevation: 0,
      //   title: Row( //Esto es para que se alinien a la izquierda
      //     children: <Widget>[
      //       IconButton(
      //         icon: const Icon(Icons.arrow_back_ios_new),
      //         tooltip: 'Volver',
      //         onPressed: () {
      //           // handle the press
      //         },
      //       ),
      //     ],
      //   )
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _bannerApp(context),
            _textLogin(),
            _textDescription(),
            _textFieldEmail(),
            _textFieldPassword(),
            _textDontHaveAccount(),
            _buttonLogin(),
            // Expanded(child: Container()), Esto es para crear un objeto infinito
          ],
        ),
      ),
    );
  }

  Widget _textDontHaveAccount(){
    return GestureDetector(
      onTap: _con.goToRegisterPage,
      child: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(right: 40),
        child: const Text(
          'Crear cuenta',
          style: TextStyle(
            fontSize: 15,
            color: Colors.teal
          ),
        ),
      ),
    );
  }

  Widget _buttonLogin(){
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ButtonApp(
        text: 'Iniciar Sesión',
        onPressed: _con.login,
      ),
    );
  }

  Widget _textFieldPassword(){
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: _con.emailController,
        decoration: const InputDecoration(
          hintText: 'ejemplo@gmail.com',
          labelText: 'Correo electrónico',
          suffixIcon: Icon(
            Icons.email_outlined,
            color: Colors.black38,
          )
        ),
      ),
    );
  }

  Widget _textLogin(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(top: 30, left:40),
      child: const Text(
        'Inicio de Sesión',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 28,
          fontFamily: 'NimbusSans'
        ),
      ),
    );
  }

  Widget _textDescription(){
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      child: const Text(
        'Hola! Gracias por usar Smavy!',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
          fontFamily: 'NimbusSans',
        ),
      ),
    );
  }

  Widget _bannerApp(BuildContext context){
    return ClipPath(
      clipper: OvalBottomBorderClipper(),
      child: Container(
        color: Colors.teal,
        height: MediaQuery.of(context).size.height*0.2,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Text(
              'Smavy',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Tangerine-Regular',
                fontSize: 40,
                fontWeight: FontWeight.w600
              ),
            ),
          ],
        ),
      ),
    );
  }
}

