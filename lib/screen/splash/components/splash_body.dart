import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_fix_it/screen/login/login_page.dart';
import 'package:mr_fix_it/screen/splash/components/logo.dart';
import 'package:mr_fix_it/screen/splash/components/animated_loading_text.dart';
import 'package:mr_fix_it/screen/client_home/client_home_page.dart';
import 'package:mr_fix_it/screen/worker_home/worker_home_page.dart';

import 'package:mr_fix_it/util/constants.dart';

class SplashBody extends StatefulWidget {
  const SplashBody({super.key});

  @override
  State<SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<SplashBody> {
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _autoLogin();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Logo(),
          AnimatedLoadingText(),
          CircularProgressIndicator(
            color: backgroundColor,
          ),
        ],
      ),
    );
  }

  void _autoLogin() {
    Future.delayed(
      const Duration(seconds: 5),
      () async {
        if (_isMounted) {
          final SharedPreferences preferences = await SharedPreferences.getInstance();

          if (preferences.containsKey('user') &&
              preferences.containsKey('password') &&
              preferences.containsKey('token') &&
              preferences.containsKey('refreshToken') &&
              preferences.containsKey('notificationToken')) {
            if (context.mounted) {
              String type = json.decode(preferences.getString('user')!)['type'];

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => (type.toLowerCase() == 'client') ? const ClientHomePage() : const WorkerHomePage(),
                ),
              );

              return;
            }
          }

          preferences.clear();

          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          }
        }
      },
    );
  }
}
