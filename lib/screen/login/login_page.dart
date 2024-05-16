import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_fix_it/screen/client_home/client_home_page.dart';
import 'package:mr_fix_it/screen/worker_home/worker_home_page.dart';
import 'package:mr_fix_it/screen/register/register_page.dart';

import 'package:mr_fix_it/components/form_text_input.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/header_container.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  late String? _email;
  late String? _password;

  final GlobalKey<FormState> _formState = GlobalKey();
  final _emailFieldKey = GlobalKey<FormFieldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        color: backgroundColor,
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: <Widget>[
            const HeaderContainer(
              text: "Login",
            ),
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Form(
                      key: _formState,
                      child: Column(
                        children: [
                          formTextInput(
                            label: 'Email',
                            key: _emailFieldKey,
                            hint: "Email",
                            icon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Email is empty';
                              }

                              if (!RegExp(emailRegex).hasMatch(value)) {
                                return 'Email is invalid';
                              }

                              if (value.length > 50) {
                                return 'Email exceeds 50 character';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _email = value;
                            },
                          ),
                          formTextInput(
                            label: "Password",
                            obscureText: true,
                            hint: "Password",
                            icon: Icons.vpn_key,
                            keyboardType: TextInputType.visiblePassword,
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

                              return null;
                            },
                            onSaved: (value) {
                              _password = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        child: const Text(
                          "Forget Password?",
                          style: TextStyle(color: primaryColor),
                        ),
                        onTap: () {
                          if (_emailFieldKey.currentState!.validate()) {
                            _emailFieldKey.currentState!.save();
                            _forgetPassword(_email!);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: ButtonWidget(
                          onClick: () {
                            if (_formState.currentState!.validate()) {
                              _formState.currentState!.save();
                              _login(_email!, _password!);
                            }
                          },
                          backgroundColor: primaryColor,
                          btnText: "LOGIN",
                        ),
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: "Don't have an account ? ",
                              style: TextStyle(
                                color: whiteBackgroundTextColor,
                              )),
                          TextSpan(
                            text: "Registor",
                            style: const TextStyle(color: primaryColor),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegistePage(),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _login(String email, String password) async {
    ResponseState responseState = await Api.authenticate(_email!, _password!);

    if (context.mounted) {
      if (responseState == ResponseState.success) {
        final SharedPreferences preferences = await SharedPreferences.getInstance();
        String type = json.decode(preferences.getString('user')!)['type'];

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => (type.toLowerCase() == 'client') ? const ClientHomePage() : const WorkerHomePage(),
            ),
          );
        }
      } else if (responseState == ResponseState.notFound) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Not found',
          description: 'Wrong email or password',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.unauthorized) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Not activated',
          description: 'Verify your account or contact technical support',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.error) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          description: 'Something went wrong, please try again later',
          btnOkOnPress: () {},
        );
      }
    }
  }

  void _forgetPassword(String email) async {
    ResponseState responseState = await Api.forgetPassword(_email!);

    if (context.mounted) {
      if (responseState == ResponseState.success) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Success',
          description: 'a password recovery message have been sent to your email',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.notFound) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Not found',
          description: 'Wrong email',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.unauthorized) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Disabled',
          description: 'Account is disabled',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.error) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          description: 'Something went wrong, please try again later',
          btnOkOnPress: () {},
        );
      }
    }
  }
}
