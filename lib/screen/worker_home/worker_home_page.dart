import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/drawer.dart';
import 'package:mr_fix_it/screen/ReelsPage/ReelsPage.dart';
import 'package:mr_fix_it/screen/chat/chat_page.dart';
import 'package:mr_fix_it/screen/worker_discover_tasks/worker_discover_tasks.dart';
import 'package:mr_fix_it/screen/worker_tasks/worker_tasks.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkerHomePage extends StatefulWidget {
  const WorkerHomePage({super.key});

  @override
  State<WorkerHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<WorkerHomePage> {
  Map<String, dynamic> _user = {};

  int lastIndex = 0;
  int _pageIndex = 0;
  List<Widget> _screens = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
    _initUser();
  }

  @override
  void dispose() {
    _scaffoldKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: mainAppBar(
        0,
        IconButton(
          icon: SvgPicture.asset("asset/images/menu.svg"),
          onPressed: () {
            _scaffoldKey.currentState!.openDrawer();
          },
        ),
        null,
        null,
        null,
      ),
      drawer: NavDrawer(
        user: _user,
      ),
      body: _screens.isNotEmpty
          ? _screens[_pageIndex]
          : const CircularProgressIndicator(
              color: primaryColor,
            ),
      bottomNavigationBar: _bottomNavBar(),
    );
  }

  Widget _bottomNavBar() {
    return Container(
      decoration: const BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(5),
          topRight: Radius.circular(5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        child: GNav(
          backgroundColor: primaryColor,
          color: backgroundColor,
          activeColor: primaryColor,
          tabBackgroundColor: backgroundColor,
          gap: 8,
          padding: const EdgeInsets.all(16),
          tabs: [
            GButton(
              icon: Icons.handyman,
              text: 'Tasks',
              onPressed: () {
                setState(() {
                  lastIndex = 0;
                  _pageIndex = 0;
                });
              },
            ),
            GButton(
              icon: Icons.explore,
              text: 'Available Offers',
              onPressed: () {
                setState(() {
                  lastIndex = 1;
                  _pageIndex = 1;
                });
              },
            ),
            GButton(
              icon: Icons.chat,
              text: 'Chat',
              onPressed: () {
                setState(() {
                  lastIndex = 2;
                  _pageIndex = 2;
                });
              },
            ),
            GButton(
              icon: Icons.video_collection,
              text: 'Reels',
              onPressed: () {
                apiCall(
                  context,
                  () async {
                    final response = await Api.fetchData('get-reels', <String, String>{});
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReelsScreen(
                            isOwner: false,
                            accessToken: _accessToken!,
                            reels: response['reels'],
                          ),
                        ),
                      ).then((value) {
                        setState(() {
                          _pageIndex = lastIndex;
                        });
                      });
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }

  void _initUser() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      _user = json.decode(preferences.getString('user')!);
      _screens = [WorkerTasks(worker: _user), WorkerDiscoverTasks(worker: _user), const ChatPage()];
    });
  }
}
