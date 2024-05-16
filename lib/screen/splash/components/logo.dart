import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(200),
      ),
      width: 200,
      height: 200,
      child: Image.asset(
        'asset/images/icon-green.png',
        height: 120,
      ),
    );
  }
}
