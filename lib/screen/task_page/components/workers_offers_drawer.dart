import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

// ignore: must_be_immutable
class WorkersOffersDrawer extends StatefulWidget {
  late BottomDrawerController _bottomDrawerController;
  final task;
  late final offers;
  final void Function(Map<String, dynamic> worker) updateTaskWorker;

  WorkersOffersDrawer(
      {super.key, required BottomDrawerController bottomDrawerController, required this.task, required this.updateTaskWorker}) {
    _bottomDrawerController = bottomDrawerController;
    offers = task['offers'];
  }

  @override
  State<WorkersOffersDrawer> createState() => _WorkersOffersDrawerState();
}

class _WorkersOffersDrawerState extends State<WorkersOffersDrawer> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return BottomDrawer(
      header: const SizedBox(
        width: 0,
        height: 0,
      ),
      controller: widget._bottomDrawerController,
      body: _buildBottomDrawerBody(context),
      headerHeight: 0,
      drawerHeight: MediaQuery.of(context).size.height * 0.5,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 60,
          spreadRadius: 5,
          offset: const Offset(2, -6),
        ),
      ],
    );
  }

  Widget _buildBottomDrawerBody(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.offers.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: InkWell(
              onTap: () {
                if (context.mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkerProfile(worker: widget.offers[index]['worker']),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 3.0,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: _accessToken != null
                                        ? Image.network(
                                            '${widget.offers[index]['worker']['img']}',
                                            //headers: {"Authorization": "Bearer $_accessToken}"},
                                            fit: BoxFit.cover,
                                          )
                                        : const CircularProgressIndicator(color: primaryColor),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.offers[index]['worker']['firstName'] + widget.offers[index]['worker']['lastName'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    widget.offers[index]['worker']['city'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    '${widget.offers[index]['price']}\$',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              RatingBar.builder(
                                initialRating: widget.offers[index]['worker']['rate'],
                                itemSize: 25,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: primaryColor,
                                ),
                                onRatingUpdate: (rating) {},
                                ignoreGestures: true,
                              ),
                              Container(
                                width: 100,
                                margin: const EdgeInsets.only(top: 5),
                                child: ButtonWidget(
                                  btnText: "Assign",
                                  backgroundColor: primaryColor,
                                  onClick: () {
                                    showAwsomeDialog(
                                      btnOkOnPress: () {
                                        _assignWorker(
                                          widget.offers[index]['taskID'],
                                          widget.offers[index]['price'],
                                          widget.offers[index]['worker'],
                                        );
                                      },
                                      btnCancelOnPress: () {},
                                      context: context,
                                      dialogType: DialogType.question,
                                      title: "Confirm!",
                                      description: "Are you sure to assign this worker?",
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }

  void _assignWorker(int taskID, double price, final selectedWorker) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'assign-worker',
          {
            'taskID': taskID.toString(),
            'workerID': selectedWorker['workerID'].toString(),
            'price': price.toString(),
          },
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'The worker assigned successfully',
              btnOkOnPress: () {},
            );

            setState(() {
              widget.updateTaskWorker(selectedWorker);
              widget._bottomDrawerController.close();
            });
          } else {
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
