import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ButtonApp extends StatelessWidget {
  Color color;
  Color textColor;
  String text;
  IconData icon;
  Function onPressed;
  double? margin;
  bool? buttonIcon;
  Color colorIcon;

  ButtonApp(
      {Key? key,
      this.buttonIcon,
      this.margin,
      this.color = Colors.teal,
      this.textColor = Colors.white,
      this.icon = Icons.arrow_forward_ios,
      this.text = "",
      this.colorIcon = Colors.teal,
      required this.onPressed,
      child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: () {
        if (margin != null) {
          return EdgeInsets.symmetric(horizontal: margin!);
        } else {
          return const EdgeInsets.symmetric(horizontal: 40);
        }
      }(),
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
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            () {
              if (buttonIcon == null) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 38,
                    child: CircleAvatar(
                      backgroundColor: colorIcon,
                      radius: 14,
                      child: Icon(icon, color: textColor, size: 18),
                    ),
                  ),
                );
              } else {
                if (buttonIcon == true) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 38,
                      child: CircleAvatar(
                        backgroundColor: colorIcon,
                        radius: 14,
                        child: Icon(icon, color: textColor, size: 18),
                      ),
                    ),
                  );
                } else {
                  return const Align();
                }
              }
            }(),
          ], //children
        ),
      ),
    );
  }
}
