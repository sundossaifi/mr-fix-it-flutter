import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class WorkingLocationsPage extends StatefulWidget {
  final List<dynamic> workingLocations;
  const WorkingLocationsPage({super.key, required this.workingLocations});

  @override
  State<WorkingLocationsPage> createState() => _WorkingLocationsPageState();
}

class _WorkingLocationsPageState extends State<WorkingLocationsPage> {
  final List<Marker> _workingLocationMarkers = [];

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < widget.workingLocations.length; i++) {
      _workingLocationMarkers.add(
        Marker(
          markerId: MarkerId(i.toString()),
          position: LatLng(widget.workingLocations[i]['latitude'], widget.workingLocations[i]['longitude']),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Text(
                    "Working Locations",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: GridView.count(
                    childAspectRatio: 4.0 / 1.0,
                    crossAxisCount: 2,
                    children: List.generate(
                      widget.workingLocations.length,
                      (index) {
                        return Dismissible(
                          key: Key(widget.workingLocations[index]['latitude'].toString() +
                              widget.workingLocations[index]['longitude'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: primaryColor,
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.red,
                            ),
                            padding: const EdgeInsets.only(right: 5),
                            margin: const EdgeInsets.all(5),
                            child: const Icon(
                              Icons.delete,
                              size: 25,
                              color: primaryBackgroundTextColor,
                            ),
                          ),
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              _deleteWorkingLocation(widget.workingLocations[index]['id']);
                              widget.workingLocations.removeAt(index);
                              _workingLocationMarkers.removeAt(index);
                              setState(() {});
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Card(
                              color: const Color(0xff118ab2),
                              child: Center(
                                child: Text(
                                  widget.workingLocations[index]['locality'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryBackgroundTextColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.6,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: widget.workingLocations.isNotEmpty
                      ? LatLng(widget.workingLocations[0]['latitude'], widget.workingLocations[0]['longitude'])
                      : const LatLng(31.771959, 35.217018),
                  zoom: 14,
                ),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                onTap: (latlang) async {
                  try {
                    List<Placemark> workingLocationPlaceMarks = await placemarkFromCoordinates(latlang.latitude, latlang.longitude);

                    String? locality = '';

                    if (workingLocationPlaceMarks[0].locality!.isEmpty ||
                        _isDuplicatedWorkingLocation(workingLocationPlaceMarks[0].locality)) {
                      if (context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text("Messing or Duplicated Location Name"),
                              content: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    locality = _isDuplicatedWorkingLocation(value) ? '' : value;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Location Name",
                                ),
                              ),
                              actions: <Widget>[
                                MaterialButton(
                                  color: Colors.red,
                                  textColor: Colors.white,
                                  child: const Text('CANCEL'),
                                  onPressed: () {
                                    locality = '';
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                                MaterialButton(
                                  color: primaryColor,
                                  textColor: Colors.white,
                                  child: const Text('OK'),
                                  onPressed: () {
                                    setState(() {
                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } else {
                      locality = workingLocationPlaceMarks[0].locality;
                    }

                    if (locality!.isNotEmpty) {
                      final workingLocation = {
                        'locality': locality!.toString(),
                        'latitude': latlang.latitude.toString(),
                        'longitude': latlang.longitude.toString(),
                      };

                      _addWorkingLocation(workingLocation);
                      setState(() {});
                    }
                  } on Exception catch (_) {}
                },
                markers: _workingLocationMarkers.toSet(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addWorkingLocation(final workingLocation) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData('add-working-location', workingLocation);

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            final addedWorkingLocation = {
              'id': int.parse(response['body']['message']),
              'latitude': double.parse(workingLocation['latitude']),
              'longitude': double.parse(workingLocation['longitude']),
              'locality': workingLocation['locality'],
            };

            widget.workingLocations.add(addedWorkingLocation);
            _workingLocationMarkers.add(
              Marker(
                markerId: MarkerId((widget.workingLocations.length - 1).toString()),
                position: LatLng(double.parse(workingLocation['latitude']), double.parse(workingLocation['longitude'])),
              ),
            );

            setState(() {});
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

  void _deleteWorkingLocation(int id) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData('delete-working-location/${id.toString()}', {});

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Working location deleted successfully',
              btnOkOnPress: () {},
            );
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

  bool _isDuplicatedWorkingLocation(String? locality) {
    if (locality == null) {
      return false;
    }

    for (int i = 0; i < widget.workingLocations.length; i++) {
      if (widget.workingLocations[i]['locality'].toString().toLowerCase() == locality.toLowerCase()) {
        return true;
      }
    }

    return false;
  }
}
