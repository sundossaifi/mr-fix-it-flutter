import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:mr_fix_it/util/constants.dart';

class DiscoverHeader extends StatelessWidget {
  const DiscoverHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 150,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryColor, // Assuming primaryColor is defined elsewhere
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Image.asset(
            'asset/images/app-icon.png',
            height: 150,
            fit: BoxFit.cover,
          ),
          const Text(
            'Mr.',
            style: TextStyle(fontSize: 43.0),
          ),
          const SizedBox(width: 5.0),
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 40.0,
              color: backgroundColor, // Assuming backgroundColor is defined elsewhere
            ),
            child: AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                RotateAnimatedText('Fix It'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
