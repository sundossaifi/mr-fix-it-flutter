import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

class AnimatedLoadingText extends StatefulWidget {
  const AnimatedLoadingText({super.key});

  @override
  State<AnimatedLoadingText> createState() => _AnimatedLoadingTextState();
}

class _AnimatedLoadingTextState extends State<AnimatedLoadingText> {
  int _curruntIndex = 0;
  int _curruntChartIndex = 0;
  final List<String> _strings = ["Mr.Fix it", "Your Trusted Solution Provider "];

  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _typeWritingAnimation();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        top: 30,
        bottom: 30,
      ),
      child: Text(
        _strings[_curruntIndex].substring(0, _curruntChartIndex),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: primaryBackgroundTextColor,
        ),
      ),
    );
  }

  void _typeWritingAnimation() {
    if (_isMounted) {
      if (_curruntChartIndex < _strings[_curruntIndex].length) {
        _curruntChartIndex++;
      } else if (_curruntIndex < _strings.length - 1) {
        _curruntIndex++;
        _curruntChartIndex = 0;
      }

      if (_isMounted) {
        setState(() {});
      }

      Future.delayed(
        const Duration(milliseconds: 113),
        () {
          _typeWritingAnimation();
        },
      );
    }
  }
}
