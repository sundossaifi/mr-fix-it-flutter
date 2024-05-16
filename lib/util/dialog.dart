import 'package:flutter/material.dart';

import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:mr_fix_it/util/constants.dart';

Future<dynamic> showAwsomeDialog(
    {required void Function() btnOkOnPress,
    void Function()? btnCancelOnPress,
    void Function(DismissType)? onDismissCallback,
    required BuildContext context,
    required DialogType dialogType,
    required String title,
    required String description}) {
  return AwesomeDialog(
    context: context,
    dialogType: dialogType,
    borderSide: const BorderSide(
      color: primaryColor,
      width: 2,
    ),
    width: 280,
    buttonsBorderRadius: const BorderRadius.all(
      Radius.circular(2),
    ),
    dismissOnTouchOutside: true,
    dismissOnBackKeyPress: false,
    headerAnimationLoop: false,
    animType: AnimType.bottomSlide,
    title: title,
    desc: description,
    showCloseIcon: true,
    btnOkOnPress: btnOkOnPress,
    btnCancelOnPress: btnCancelOnPress,
    onDismissCallback: onDismissCallback,
  ).show();
}
