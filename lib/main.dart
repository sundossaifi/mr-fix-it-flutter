import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_inapp_notifications/flutter_inapp_notifications.dart';
import 'package:mr_fix_it/screen/splash/sphash_page.dart';

import 'package:mr_fix_it/util/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _setupNotification();
  runApp(const MyApp());
}

void _setupNotification() async {
  await Firebase.initializeApp();
  _requestNotificationPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  _onForegroundMessage();
}

void _requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

void _onForegroundMessage() {
  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      if (message.notification != null) {
        InAppNotifications.instance
          ..backgroundColor = backgroundColor
          ..textColor = whiteBackgroundTextColor;

        InAppNotifications.show(
          title: message.notification!.title,
          leading: const Icon(
            Icons.handyman,
            color: primaryColor,
            size: 50,
          ),
          onTap: () {},
          description: message.notification!.body,
        );
      }
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mr. fix it',
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: mainFont,
        textTheme: Theme.of(context).textTheme.apply(bodyColor: whiteBackgroundTextColor),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(backgroundColor: primaryColor),
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      builder: InAppNotifications.init(),
    );
  }
}
