import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';
import 'package:mr_fix_it/screen/navigation/navigation_page.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';
import 'package:mr_fix_it/screen/task_page/components/workers_offers_drawer.dart';

import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/img_card.dart';
import 'package:mr_fix_it/components/form_text_input.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/constants.dart';

class TaskPage extends StatefulWidget {
  final bool isClient;
  final bool isAssignedWorker;
  final client;
  final task;

  const TaskPage({super.key, required this.task, required this.isClient, required this.client, required this.isAssignedWorker});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  String? _accessToken;
  LatLng? _source;

  final Location _locationController = Location();
  final BottomDrawerController _bottomDrawerController = BottomDrawerController();
  String? _reason = '';
  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getToken();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: CircularPercentIndicator(
                                radius: 70.0,
                                lineWidth: 5.0,
                                animation: true,
                                percent: 0.75,
                                circularStrokeCap: CircularStrokeCap.round,
                                progressColor: const Color(0xff118ab2),
                                backgroundColor: primaryBackgroundTextColor,
                                center: CircleAvatar(
                                  radius: 65.0,
                                  backgroundImage: NetworkImage(
                                    '${widget.task['taskImgs'][0]['img']}',
                                    //headers: {"Authorization": "Bearer $_accessToken}"},
                                    scale: 1.0,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.task['title'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 35,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBackgroundTextColor,
                                    ),
                                  ),
                                  Text(
                                    widget.task['category']['type'],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      color: primaryBackgroundTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        if (widget.task['type'] != 'PRIVATE')
                          const SizedBox(
                            height: 10,
                          ),
                        if (widget.task['type'] != 'PRIVATE' && widget.task['worker'] == null && widget.isClient)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Workers Offers',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              _bottomDrawerController.open();
                            },
                          ),
                        if (widget.task['status'] == 'ASSIGNED')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: backgroundColor,
                              padding: const EdgeInsets.all(14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                      'Reason',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: SizedBox(
                                      height: 200,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Form(
                                            key: _formState,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                formTextInput(
                                                  label: 'Reason',
                                                  hint: "Reason",
                                                  icon: Icons.message,
                                                  maxLines: 3,
                                                  validator: (value) {
                                                    if (value!.trim().isEmpty) {
                                                      return 'Reason is empty';
                                                    }

                                                    return null;
                                                  },
                                                  onSaved: (value) {
                                                    _reason = value;
                                                  },
                                                ),
                                                Container(
                                                  margin: const EdgeInsets.only(top: 30),
                                                  child: Center(
                                                    child: ButtonWidget(
                                                      btnText: "Cancel",
                                                      backgroundColor: primaryColor,
                                                      onClick: () {
                                                        if (!_formState.currentState!.validate()) {
                                                          return;
                                                        }

                                                        _formState.currentState!.save();
                                                        _cancelTask(_reason);
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 240,
                        child: PageView.builder(
                          controller: PageController(viewportFraction: 0.9),
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.task['taskImgs'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return Center(
                              child: ImageCard(
                                poster: widget.task['taskImgs'][index]['img'],
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) {
                                      List<String> imgs = [];

                                      for (int i = 0; i < widget.task['taskImgs'].length; i++) {
                                        imgs.add(widget.task['taskImgs'][i]['img']);
                                      }

                                      return FullScreenImageGallery(
                                        imageUrls: imgs,
                                        initialIndex: index,
                                        token: _accessToken,
                                      );
                                    }),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      formTextInput(
                        controller: TextEditingController(text: widget.task['description']),
                        label: 'Description',
                        hint: "Description...",
                        icon: Icons.description,
                        maxLines: 5,
                        readOnly: true,
                      ),
                      if (widget.isClient)
                        formTextInput(
                          controller: TextEditingController(
                            text: widget.task['startDate'] != null ? widget.task['startDate'].toString().replaceAll('T', ' ') : '-',
                          ),
                          label: 'Start Date',
                          hint: "Start Date",
                          icon: Icons.date_range,
                          maxLines: 1,
                          readOnly: true,
                        ),
                      if (widget.isClient)
                        formTextInput(
                          controller: TextEditingController(
                            text: widget.task['expiryDate'] != null ? widget.task['expiryDate'].toString().replaceAll('T', ' ') : '-',
                          ),
                          label: 'End Date',
                          hint: "End Date",
                          icon: Icons.date_range,
                          maxLines: 1,
                          readOnly: true,
                        ),
                      if (widget.isClient)
                        formTextInput(
                          controller: TextEditingController(
                              text: widget.task['worker'] == null
                                  ? '-'
                                  : widget.task['worker']['firstName'] + ' ' + widget.task['worker']['lastName']),
                          label: 'Assigned Worker',
                          hint: "Assigned Worker",
                          icon: Icons.handyman,
                          maxLines: 1,
                          readOnly: true,
                          onTap: () {
                            if (widget.task['worker'] != null) {
                              if (context.mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => WorkerProfile(worker: widget.task['worker']),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      if (widget.isClient)
                        formTextInput(
                          controller: TextEditingController(text: widget.task['price'] == -1 ? '-' : widget.task['price'].toString()),
                          label: 'Price',
                          hint: "Price",
                          icon: Icons.price_change,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                      if (widget.isClient)
                        formTextInput(
                          controller: TextEditingController(text: widget.task['status']),
                          label: 'Status',
                          hint: "Status",
                          icon: Icons.mode,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                        ),
                      if (!widget.isClient)
                        formTextInput(
                          controller: TextEditingController(text: widget.client['firstName'] + ' ' + widget.client['lastName']),
                          label: 'Client',
                          hint: 'Client',
                          icon: Icons.person,
                          keyboardType: TextInputType.number,
                          readOnly: true,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Center(
                                    child: Text(
                                      'Client',
                                      style: TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  content: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Container(
                                            margin: const EdgeInsets.all(5),
                                            child: CircularPercentIndicator(
                                              radius: 80.0,
                                              lineWidth: 5.0,
                                              animation: true,
                                              percent: 0.75,
                                              circularStrokeCap: CircularStrokeCap.round,
                                              progressColor: const Color(0xff118ab2),
                                              backgroundColor: primaryBackgroundTextColor,
                                              center: CircleAvatar(
                                                radius: 75.0,
                                                backgroundImage: NetworkImage(
                                                  '${widget.task['client']['img']}',
                                                  //headers: {"Authorization": "Bearer $_accessToken}"},
                                                  scale: 1.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => FullScreenImageGallery(
                                                  imageUrls: [widget.task['client']['img']],
                                                  initialIndex: 0,
                                                  token: _accessToken,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        formTextInput(
                                          controller:
                                              TextEditingController(text: widget.client['firstName'] + ' ' + widget.client['lastName']),
                                          label: 'Name',
                                          hint: 'Name',
                                          icon: Icons.person,
                                          readOnly: true,
                                        ),
                                        formTextInput(
                                          controller: TextEditingController(text: widget.client['email']),
                                          label: 'Email',
                                          hint: 'Email',
                                          icon: Icons.email,
                                          readOnly: true,
                                        ),
                                        formTextInput(
                                          controller: TextEditingController(text: widget.client['phone']),
                                          label: 'Phone',
                                          hint: 'Phone',
                                          icon: Icons.phone,
                                          readOnly: true,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TitleWithCustomUnderline(
                              text: 'Location',
                              fontSize: 30,
                              height: 30,
                            ),
                            if (widget.task['worker'] != null && widget.task['status'] == 'ASSIGNED' && widget.isAssignedWorker)
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(10),
                                child: ButtonWidget(
                                  btnText: 'GO',
                                  backgroundColor: primaryColor,
                                  onClick: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NavigationPage(
                                          destination: LatLng(
                                            widget.task['latitude'],
                                            widget.task['longitude'],
                                          ),
                                          source: _source!,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 300,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(widget.task['latitude'], widget.task['longitude']),
                            zoom: 17,
                          ),
                          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                            ),
                          },
                          markers: {
                            Marker(
                              position: LatLng(widget.task['latitude'], widget.task['longitude']),
                              markerId: MarkerId(UniqueKey().toString()),
                            )
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          WorkersOffersDrawer(
            task: widget.task,
            bottomDrawerController: _bottomDrawerController,
            updateTaskWorker: (worker) {
              setState(() {
                widget.task['worker'] = worker;
              });
            },
          ),
        ],
      ),
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }

  void _getCurrentLocation() async {
    LocationData data = await _locationController.getLocation();
    _source = LatLng(data.latitude!, data.longitude!);
  }

  void _cancelTask(String? reason) {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'cancel-task/${widget.task['id'].toString()}',
          {'reason': reason},
        );

        if (response['responseState'] == ResponseState.success) {
          widget.task['status'] = 'CANCELED';
          setState(() {});
          if (context.mounted) {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.success,
              title: 'Success',
              description: 'Task canceled successfully',
              btnOkOnPress: () {},
              onDismissCallback: (value) {
                Navigator.of(context).pop();
              },
            );
          }
        } else {
          if (context.mounted) {
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
