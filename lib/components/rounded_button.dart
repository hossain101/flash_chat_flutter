import 'package:flutter/material.dart';

//Rounded button used in welcome screen, login screen , registration screen.
// ignore: must_be_immutable
class RoundedButton extends StatelessWidget {
  RoundedButton({
    Key? key,
    required this.title,
    required this.btnColor,
    required this.funcOnPressed,
  }) : super(key: key);

  VoidCallback funcOnPressed;
  String title;
  Color btnColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        elevation: 5.0,
        color: btnColor,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: funcOnPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            title,
          ),
        ),
      ),
    );
  }
}
