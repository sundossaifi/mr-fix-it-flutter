import 'dart:async';
import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> {
  int _currentDot = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(milliseconds: 300), (Timer t) {
      setState(() {
        _currentDot = (_currentDot + 1) % 3;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              height: 8,
              width: 8,
              decoration: BoxDecoration(
                color: _currentDot == index ? Colors.blue : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
          );
        }),
      ),
    );
  }
}
