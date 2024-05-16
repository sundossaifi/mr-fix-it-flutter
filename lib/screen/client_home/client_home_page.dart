import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:mr_fix_it/screen/ReelsPage/ReelsPage.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_fix_it/screen/chat/chat_page.dart';
import 'package:mr_fix_it/screen/discover/discover_page.dart';
import 'package:mr_fix_it/screen/my_tasks/my_tasks_page.dart';
import 'package:mr_fix_it/screen/post_task/post_task_page.dart';
import 'package:mr_fix_it/screen/client_home/components/home_body.dart';

import 'package:mr_fix_it/components/drawer.dart';
import 'package:mr_fix_it/components/app_bar.dart';

import 'package:mr_fix_it/util/constants.dart';

class ClientHomePage extends StatefulWidget {
  const ClientHomePage({super.key});

  @override
  State<ClientHomePage> createState() => _HomePageState();
}

class _HomePageState extends State<ClientHomePage> {
  Map<String, dynamic> _user = {};

  int lastIndex = 0;
  int _pageIndex = 0;
  final List<Widget> _screens = [const HomeBody(), const DiscoverPage(), const ChatPage(), const PostTaskPage(), const MyTasksPage()];

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
      body: Builder(builder: (context) => _screens[_pageIndex]),
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
          padding: const EdgeInsets.all(11),
          tabs: [
            GButton(
              icon: Icons.home,
              text: 'Home',
              onPressed: () {
                setState(() {
                  lastIndex = 0;
                  _pageIndex = 0;
                });
              },
            ),
            GButton(
              icon: Icons.handyman,
              text: 'Discover',
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
              icon: Icons.task,
              text: 'Post Task',
              onPressed: () {
                setState(() {
                  lastIndex = 3;
                  _pageIndex = 3;
                });
              },
            ),
            GButton(
              icon: Icons.work_history,
              text: 'My Tasks',
              onPressed: () {
                setState(() {
                  lastIndex = 4;
                  _pageIndex = 4;
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
    });
  }
}
