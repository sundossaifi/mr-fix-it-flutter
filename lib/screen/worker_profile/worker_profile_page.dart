import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/app_bar.dart';

import 'package:mr_fix_it/screen/worker_profile/components/profile_body.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class WorkerProfile extends StatefulWidget {
  late Map<String, dynamic> _worker;
  late List<dynamic> _workingLocations;
  late List<dynamic> _previousWorks;

  WorkerProfile({super.key, required Map<String, dynamic> worker}) {
    _worker = worker;
    _workingLocations = _worker['workingLocations'];
    _previousWorks = _worker['previousWorks'];
  }

  @override
  State<WorkerProfile> createState() => _WorkerProfileState();
}

class _WorkerProfileState extends State<WorkerProfile> {
  Color? _favoriteIconColor = Colors.white;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _setFavoriteState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        0,
        const BackButton(),
        Container(
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerRight,
          child: IconButton(
            onPressed: () {
              _isFavorite = !_isFavorite;
              _updateFavorite(widget._worker['workerID'], _isFavorite);
            },
            icon: Icon(
              Icons.favorite,
              size: 30,
              color: _favoriteIconColor,
            ),
          ),
        ),
        primaryColor,
        transparent,
      ),
      body: ProfileBody(worker: widget._worker, workingLocations: widget._workingLocations, previousWorks: widget._previousWorks),
    );
  }

  void _setFavoriteState() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final user = json.decode(sharedPreferences.getString('user')!);

    for (int i = 0; i < user['favorites'].length; i++) {
      if (user['favorites'][i]['workerID'] == widget._worker['workerID']) {
        setState(() {
          _favoriteIconColor = Colors.redAccent;
          _isFavorite = true;
        });

        break;
      }
    }
  }

  void _updateFavorite(int workerID, bool isFavorite) async {
    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.postData(
            'update-favorite',
            {
              'workerID': workerID.toString(),
              'favoriteState': isFavorite.toString(),
            },
          );

          if (context.mounted) {
            if (response['responseState'] == ResponseState.success) {
              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
              final user = json.decode(sharedPreferences.getString('user')!);
              List<dynamic> favorits = user['favorites'];

              if (isFavorite) {
                favorits.add(widget._worker);
              } else {
                for (int i = 0; i < favorits.length; i++) {
                  if (favorits[i]['workerID'] == widget._worker['workerID']) {
                    favorits.removeAt(i);
                    break;
                  }
                }
              }

              user['favorites'] = favorits;
              await sharedPreferences.setString('user', json.encode(user));

              setState(() {
                _favoriteIconColor = _isFavorite ? Colors.redAccent : Colors.white;
              });
            } else {
              _isFavorite = !_isFavorite;
              showAwsomeDialog(
                context: context,
                dialogType: DialogType.error,
                title: 'Failed',
                description: 'Something went wrong, please try again later',
                btnOkOnPress: () {},
              );
            }
          }
        },
      );
    }
  }
}
