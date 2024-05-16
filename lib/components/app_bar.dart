import 'package:flutter/material.dart';

PreferredSizeWidget? mainAppBar(double? elevation, Widget? leading, Widget? title, Color? backgroundColor, Color? shadowColor,
    {double? leadingWidth}) {
  return AppBar(
    leadingWidth: leadingWidth,
    elevation: elevation,
    leading: leading,
    title: title,
    backgroundColor: backgroundColor,
    shadowColor: shadowColor,
  );
}
