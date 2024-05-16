import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';

import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class ChangePasswordDialog extends StatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  State<ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  String? _currentPassword = '';
  String? _oldPassword = '';
  String? _newPassword = '';

  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initCurrentPassword();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Change Password',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formState,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              formTextInput(
                label: 'Old Password',
                hint: "Old Password",
                icon: Icons.password,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Password is empty';
                  }

                  if (value != _currentPassword) {
                    return 'Incorrect password';
                  }

                  return null;
                },
                onSaved: (value) {
                  _oldPassword = value;
                },
              ),
              formTextInput(
                label: 'New Password',
                hint: "New Password",
                icon: Icons.password,
                maxLines: 1,
                validator: (value) {
                  if (value!.trim().isEmpty) {
                    return 'Password is empty';
                  }

                  if (value.length < 8) {
                    return 'Password should be at least 8 characters';
                  }

                  if (value.length > 16) {
                    return 'Password exceeds 16 character';
                  }

                  if (!RegExp(passwordRegex).hasMatch(value)) {
                    return 'Password should contain lower, upper, special characters and number';
                  }

                  return null;
                },
                onSaved: (value) {
                  _newPassword = value;
                },
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Center(
                  child: ButtonWidget(
                    btnText: "Save",
                    backgroundColor: primaryColor,
                    onClick: () {
                      if (!_formState.currentState!.validate()) {
                        return;
                      }

                      _formState.currentState!.save();
                      _changePassword(_oldPassword, _newPassword);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changePassword(String? oldPassword, String? newPassword) async {
    Map<String, dynamic> passwordData = {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
    };

    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.postData(
            'update-user-password',
            passwordData,
          );

          if (context.mounted) {
            if (response['responseState'] == ResponseState.success) {
              await showAwsomeDialog(
                context: context,
                dialogType: DialogType.info,
                title: 'Success',
                description: 'Your password updated successfully',
                btnOkOnPress: () {
                  Navigator.pop(context);
                },
                onDismissCallback: (dismissType) {
                  Navigator.pop(context);
                },
              );

              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

              setState(() {
                _currentPassword = newPassword;
                sharedPreferences.setString('password', newPassword!);
              });
            } else {
              showAwsomeDialog(
                context: context,
                dialogType: DialogType.error,
                title: 'Failed',
                description: 'Something went wrong, please try again later',
                btnOkOnPress: () {
                  Navigator.pop(context);
                },
                onDismissCallback: (dismissType) {
                  Navigator.pop(context);
                },
              );
            }
          }
        },
      );
    }
  }

  void _initCurrentPassword() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _currentPassword = sharedPreferences.getString('password')!;
    });
  }
}
