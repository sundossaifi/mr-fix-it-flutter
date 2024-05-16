import 'package:flutter/material.dart';

class Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 590);
    path.quadraticBezierTo(size.width / 4, 530, size.width / 2, 545);
    path.quadraticBezierTo(3 / 4 * size.width, 550, size.width, 500);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
