import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

class ButtonWidget extends StatelessWidget {
  final String btnText;
  final dynamic onClick;
  final Color backgroundColor;
  final Color textColor;

  const ButtonWidget(
      {super.key,
      required this.btnText,
      required this.backgroundColor,
      required this.onClick,
      this.textColor = primaryBackgroundTextColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onClick,
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [backgroundColor, backgroundColor], end: Alignment.centerLeft, begin: Alignment.centerRight),
          borderRadius: const BorderRadius.all(
            Radius.circular(100),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          btnText,
          style: TextStyle(
            fontSize: 20,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
