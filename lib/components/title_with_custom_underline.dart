import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class TitleWithCustomUnderline extends StatelessWidget {
  final String text;
  late double fontSize;
  late double height;

  TitleWithCustomUnderline({super.key, required this.text, this.fontSize = 20, this.height = 24});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: defultpadding / 4.0),
            child: Text(
              text,
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.only(right: defultpadding / 4),
              height: 7,
              color: primaryColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}
