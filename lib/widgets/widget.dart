import 'package:flutter/material.dart';

class Buttons extends StatelessWidget {
  final onTap;
  final double height;
  final double width;
  final String buttonName;
  final fontColor;
  //final Color color;
  final double fontSize;
  final FontWeight fontWeight;
  const Buttons(
      {super.key,
      this.onTap,
      required this.height,
      required this.width,
      required this.buttonName,
      //this.color = NU_BLUE,
      this.fontColor,
      required this.fontSize,
      this.fontWeight = FontWeight.normal}
      );
      

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
           //color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Center(
          child: Text(
            buttonName,
            style: TextStyle(
              color: fontColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}