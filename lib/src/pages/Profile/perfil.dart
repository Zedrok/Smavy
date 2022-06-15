import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:smavy/src/providers/auth_provider.dart';
import 'package:smavy/src/pages/Profile/perfil_controller.dart';

class EditProfileUI extends StatefulWidget {
  const EditProfileUI({Key? key}) : super(key: key);

  @override
  State<EditProfileUI> createState() => _EditProfileUIState();
}

class _EditProfileUIState extends State<EditProfileUI> {
  bool isObscurePassword = true;

  final id = AuthProvider().getUser()!.uid;

  PerfilController con = PerfilController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text('Editar Perfil'),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )),
        body: Container(
          padding: const EdgeInsets.only(
            left: 15,
            top: 20,
            right: 15,
          ),
          child: GestureDetector(
            onTap: (() {
              FocusScope.of(context).unfocus();
            }),
            child: ListView(children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1))
                          ],
                          shape: BoxShape.circle,
                          image: const DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  'https://media.istockphoto.com/photos/icon-of-a-businessman-avatar-or-profile-pic-picture-id474001892?s=612x612'))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 4, color: Colors.white),
                            color: Colors.teal),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              buildTextField('Nombre de usuario', '${_getDisplayName()}', false,
                  con.displayNameController),
              buildTextField(
                  'Email', '${_getEmail()}', false, con.emailController),
              buildTextField(
                  'Contraseña', 'password', true, con.providerIdController),
              buildTextField('Confirmar contraseña', 'password', true,
                  con.passwordController),
              //buildTextField('Direccion', 'Av brasil', false),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text(
                      'CANCELAR',
                      style: TextStyle(
                          fontSize: 15, letterSpacing: 2, color: Colors.black),
                    ),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                  ),
                  GestureDetector(
                    onTap: con.updateDisplayName,
                    child: ElevatedButton(
                      onPressed: () {
                        con.updateDisplayName();
                        con.updateEmail();
                        con.updateProviderId();
                      },
                      child: const Text(
                        'GUARDAR',
                        style: TextStyle(
                            fontSize: 15,
                            letterSpacing: 2,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                          primary: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20))),
                    ),
                  )
                ],
              )
            ]),
          ),
        ));
  }

  Widget buildTextField(String labelText, String placeholder,
      bool isPasswordTextField, dynamic con) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextField(
        controller: con,
        obscureText: isPasswordTextField ? isObscurePassword : false,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isObscurePassword = !isObscurePassword;
                      });
                    },
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.blueGrey,
                    ))
                : null,
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Future<String> _getEmail() async {
    String email;

    var data =
        await FirebaseFirestore.instance.collection('AppUsers').doc(id).get();

    email = data.data()!['email'];

    return email;
  }

  Future<String> _getDisplayName() async {
    String username;

    var data =
        await FirebaseFirestore.instance.collection('AppUsers').doc(id).get();

    username = data.data()!['username'];

    return username;
  }
}
