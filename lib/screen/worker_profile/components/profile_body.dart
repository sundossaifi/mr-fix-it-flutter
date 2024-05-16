import 'package:flutter/material.dart';
import 'package:bottom_drawer/bottom_drawer.dart';

import 'package:mr_fix_it/screen/worker_profile/components/profile_information_header.dart';
import 'package:mr_fix_it/screen/worker_profile/components/profile_working_locations.dart';
import 'package:mr_fix_it/screen/worker_profile/components/profile_previous_works.dart';
import 'package:mr_fix_it/screen/worker_profile/components/request_task_drawer.dart';

// ignore: must_be_immutable
class ProfileBody extends StatefulWidget {
  late Map<String, dynamic> _worker;
  late List<dynamic> _workingLocations;
  late List<dynamic> _previousWorks;

  ProfileBody(
      {super.key, required Map<String, dynamic> worker, required List<dynamic> workingLocations, required List<dynamic> previousWorks}) {
    _worker = worker;
    _workingLocations = workingLocations;
    _previousWorks = previousWorks;
  }

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  final BottomDrawerController _bottomDrawerController = BottomDrawerController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          children: [
            ProfileInformationHeader(
              id: widget._worker['id'],
              firstName: widget._worker['firstName'],
              lastName: widget._worker['lastName'],
              category: widget._worker['category']['type'],
              email: widget._worker['email'],
              img: widget._worker['img'],
              rate: widget._worker['rate'],
              bottomDrawerController: _bottomDrawerController,
            ),
            const SizedBox(height: 48),
            ProfileWorkingLocations(workingLocations: widget._workingLocations),
            const SizedBox(height: 48),
            ProfilePreviousWorks(
              isOwner: false,
              previousWorks: widget._previousWorks,
              height: 310,
            ),
          ],
        ),
        RequestTaskDrawer(
          bottomDrawerController: _bottomDrawerController,
          workerID: widget._worker['workerID'],
        ),
      ],
    );
  }
}
