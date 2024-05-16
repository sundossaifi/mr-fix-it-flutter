import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:mr_fix_it/screen/login/login_page.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/api/exception/session_expired_exception.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef ApiCall = Future<void> Function();

void apiCall(BuildContext context, ApiCall apiCall) async {
  try {
    await apiCall();
  } on SessionExpiredException catch (e) {
    if (context.mounted) {
      await showAwsomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Failed',
        description: e.cause,
        btnOkOnPress: () {},
      );
    }

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    bool lout = await preferences.clear();

    if (context.mounted && lout) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      await showAwsomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Error',
        description: e.toString(),
        btnOkOnPress: () {},
      );
    }
  }
}
