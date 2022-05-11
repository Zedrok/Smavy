import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonApp extends StatelessWidget {

  Color color;
  Color textColor;
  String text;
  IconData icon;
  Function onPressed;

  ButtonApp({Key? key, 
    this.color = Colors.teal,
    this.textColor = Colors.white,
    this.icon = Icons.arrow_forward_ios,
    this.text = "",
    required this.onPressed 

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                child: 
                Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                height: 38,
                child: CircleAvatar(
                  radius: 14,
                  child: Icon(
                    icon,
                    color: textColor,
                    size: 18
                  ),
                ),
              )  
            ),
          ], //children
        ),
      ),
    );
  }
}