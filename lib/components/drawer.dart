import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/subscribe_premium_dialog.dart';
import 'package:mr_fix_it/screen/ads/ads_page.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mr_fix_it/screen/login/login_page.dart';
import 'package:mr_fix_it/screen/donation/donation_page.dart';
import 'package:mr_fix_it/screen/more_workers/more_workers_page.dart';
import 'package:mr_fix_it/screen/previous_work/previous_work.dart';
import 'package:mr_fix_it/screen/user_profile/user_profile.dart';

import 'package:mr_fix_it/components/change_password_dialog.dart';
import 'package:mr_fix_it/screen/worker_reels/worker_reels_page.dart';
import 'package:mr_fix_it/screen/working_locations/working_locations_page.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class NavDrawer extends StatefulWidget {
  late Map<String, dynamic> _user;

  NavDrawer({super.key, required Map<String, dynamic> user}) {
    _user = user;
  }

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String? _accessToken;
  List<dynamic> _favorite = [];

  @override
  void initState() {
    super.initState();
    _getToken();
    _updateFavorite();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 1.0,
          sigmaY: 1.0,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: primaryColor,
              ),
              accountName: Text(widget._user['firstName'] + ' ' + widget._user['lastName']),
              accountEmail: Text(widget._user['email']),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: backgroundColor,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Material(
                    color: transparent,
                    child: _accessToken != null
                        ? Image.network(
                            '${widget._user['img']}',
                            //headers: {"Authorization": "Bearer $_accessToken}"},
                            fit: BoxFit.cover,
                          )
                        : const CircularProgressIndicator(color: primaryColor),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text(
                'Profile',
                style: TextStyle(
                  color: whiteBackgroundTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfile(user: widget._user),
                  ),
                ).then((value) => setState(() {}));
              },
            ),
            if (widget._user['type'] == 'WORKER')
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text(
                  'Working Locations',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkingLocationsPage(
                        workingLocations: widget._user['workingLocations'],
                      ),
                    ),
                  );
                },
              ),
            if (widget._user['type'] == 'WORKER')
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text(
                  'Previous Works',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PreviousWorkPage(previousWorks: widget._user['previousWorks']),
                    ),
                  );
                },
              ),
            if (widget._user['type'] == 'WORKER')
              ListTile(
                leading: const Icon(Icons.ads_click),
                title: const Text(
                  'Ads',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdsPage(
                        workerID: widget._user['workerID'],
                        ads: widget._user['ads'],
                      ),
                    ),
                  );
                },
              ),
            if (widget._user['type'] == 'WORKER')
              ListTile(
                leading: const Icon(Icons.video_collection),
                title: const Text(
                  'Reels',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerReelsPage(
                        workerID: widget._user['workerID'],
                      ),
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text(
                'Change Password',
                style: TextStyle(
                  color: whiteBackgroundTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const ChangePasswordDialog();
                  },
                );
              },
            ),
            if (widget._user['type'] == 'CLIENT')
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text(
                  'Favorite',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreWorkersPage(
                        title: "Favorite",
                        workers: _favorite,
                      ),
                    ),
                  ).then(
                    (value) => setState(
                      () {
                        _updateFavorite();
                      },
                    ),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text(
                'Donation',
                style: TextStyle(
                  color: whiteBackgroundTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationPage(userID: widget._user['id']),
                  ),
                );
              },
            ),
            if (widget._user['type'] == 'WORKER')
              ListTile(
                leading: const Icon(Icons.workspace_premium),
                title: const Text(
                  'Premium',
                  style: TextStyle(
                    color: whiteBackgroundTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _getFeaturedWorker();
                },
              ),
            ListTile(
              leading: const Icon(Icons.messenger),
              title: const Text(
                'Contact Us',
                style: TextStyle(
                  color: whiteBackgroundTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                launchWhatsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: whiteBackgroundTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () async {
                _logout();
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

  void _updateFavorite() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      _favorite = json.decode(sharedPreferences.getString('user')!)['favorites'];
    });
  }

  void _getFeaturedWorker() {
    apiCall(
      context,
      () async {
        final response = await Api.fetchData('get-featured', {});

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return SubscribePremiumDialog(
                workerID: widget._user['workerID'],
                featured: response['featured'],
              );
            },
          );
        }
      },
    );
  }

  void launchWhatsApp() async {
    String url = "https://wa.me/+972595251236";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _logout() async {
    apiCall(
      context,
      () async {
        await Api.logout();
      },
    );

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
  }
}
