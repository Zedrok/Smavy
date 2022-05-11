import 'package:flutter/material.dart';

class Snackbar{
  
  static void showSnackbar(BuildContext context, String text, [bool? exito]){

    FocusScope.of(context).requestFocus(FocusNode());
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        )
      ),
      backgroundColor: (((){
        if(exito != null){
          if(exito != true){
            return Colors.red;
          }else{
            return Colors.teal;
          }
        }else{
           return Colors.redAccent[700];
        }
      }
      )()),
      duration: const Duration(seconds: 3),
    ) );
  }
}