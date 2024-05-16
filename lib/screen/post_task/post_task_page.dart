import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/response_state.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

class PostTaskPage extends StatefulWidget {
  const PostTaskPage({super.key});

  @override
  State<PostTaskPage> createState() => _PostTaskPageState();
}

class _PostTaskPageState extends State<PostTaskPage> {
  double? _price = -1;
  String? _title = '';
  String? _description = '';

  String? _selectedCategory;
  List<dynamic> _categories = [''];

  String? _locality = '';
  double? _latitude = -1;
  double? _longitude = -1;

  String _type = 'POST';

  int _imgsCount = 0;
  final List<XFile> _imageFileList = [];

  final List<Marker> _taskLocationMarkers = [];

  bool _messingTaskLocations = false;
  bool _messingTaskImgs = false;
  bool _priceSection = true;

  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(
              defultpadding,
            ),
            child: Form(
              key: _formState,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Post a Task',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  formTextInput(
                    label: 'Title',
                    hint: "Title",
                    icon: Icons.title,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Title is empty';
                      }

                      if (value.length > 50) {
                        return 'Title exceeds 50 character';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _title = value;
                    },
                  ),
                  formTextInput(
                    label: 'Description',
                    hint: "Description...",
                    icon: Icons.description,
                    maxLines: 5,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Description is empty';
                      }

                      if (value.length > 500) {
                        return 'Description exceeds 50 character';
                      }

                      return null;
                    },
                    onSaved: (value) {
                      _description = value;
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        "Category: ",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      DropdownMenu<String>(
                        width: 180,
                        initialSelection: _categories.first,
                        onSelected: (String? value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                        inputDecorationTheme: InputDecorationTheme(
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: primaryColor),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        dropdownMenuEntries: _categories.map<DropdownMenuEntry<String>>((dynamic value) {
                          return DropdownMenuEntry<String>(value: value, label: value);
                        }).toList(),
                      )
                    ],
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: whiteBackgroundTextColor,
                        ),
                        onPressed: () async {
                          final List<XFile> selectedImages = await ImagePicker().pickMultiImage();

                          if (selectedImages.isNotEmpty) {
                            _imageFileList.clear();
                            _imageFileList.addAll(selectedImages);

                            setState(() {
                              _imgsCount = _imageFileList.length;
                            });
                          }
                        },
                      ),
                      Text(
                        'Task Imgs: $_imgsCount',
                      ),
                    ],
                  ),
                  if (_messingTaskImgs)
                    const Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        'Messing task imgs',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Task Locations: ",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 30,
                          margin: const EdgeInsets.all(5),
                          child: ButtonWidget(
                            btnText: "Uncheck",
                            backgroundColor: primaryColor,
                            onClick: () {
                              setState(() {
                                if (_taskLocationMarkers.isNotEmpty) {
                                  _locality = '';
                                  _latitude = -1;
                                  _longitude = -1;
                                  _taskLocationMarkers.removeLast();
                                }
                              });
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
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(31.771959, 35.217018),
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

                          if (workingLocationPlaceMarks[0].locality!.isEmpty) {
                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Messing Location Name"),
                                    content: TextField(
                                      onChanged: (value) {
                                        setState(() {
                                          _locality = value;
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
                                          _locality = '';
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
                            _locality = workingLocationPlaceMarks[0].locality!;
                          }

                          if (_locality!.isNotEmpty) {
                            _latitude = latlang.latitude;
                            _longitude = latlang.longitude;

                            setState(() {
                              _taskLocationMarkers.clear();
                              _taskLocationMarkers.add(
                                  Marker(position: LatLng(latlang.latitude, latlang.longitude), markerId: MarkerId(latlang.toString())));
                            });
                          }
                        } on Exception catch (_) {}
                      },
                      markers: _taskLocationMarkers.toSet(),
                    ),
                  ),
                  if (_messingTaskLocations)
                    const Text(
                      'Messing task locations',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Post',
                          ),
                          value: 'POST',
                          groupValue: _type,
                          onChanged: (value) {
                            setState(() {
                              _type = value!;
                              _priceSection = true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text(
                            'Tender',
                          ),
                          value: 'TENDER',
                          groupValue: _type,
                          onChanged: (value) {
                            setState(() {
                              _type = value!;
                              _priceSection = false;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_priceSection)
                    formTextInput(
                      label: 'Price',
                      hint: "Price",
                      icon: Icons.price_change,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Price is empty';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _price = double.tryParse(value!);
                      },
                    ),
                  Container(
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                    child: Center(
                      child: ButtonWidget(
                        btnText: "Post",
                        backgroundColor: primaryColor,
                        onClick: () async {
                          bool validTextFieldsData = _formState.currentState!.validate();

                          setState(() {
                            _messingTaskImgs = (_imageFileList.isEmpty);
                            _messingTaskLocations = (_taskLocationMarkers.isEmpty);
                          });

                          if (!validTextFieldsData || _messingTaskLocations || _messingTaskImgs) {
                            return;
                          }

                          _formState.currentState!.save();

                          SharedPreferences preferences = await SharedPreferences.getInstance();
                          int userID = json.decode(preferences.getString('user')!)['id'];

                          Map<String, dynamic> taskPost = {
                            'userID': userID.toString(),
                            'locality': _locality,
                            'latitude': _latitude.toString(),
                            'longitude': _longitude.toString(),
                            'title': _title,
                            'description': _description,
                            'category': _selectedCategory,
                          };

                          String url;

                          if (_type == 'POST') {
                            url = 'post-task';
                            taskPost['price'] = _price.toString();
                          } else {
                            url = 'post-tender';
                          }

                          _postTask(taskPost, url);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _fetchCategories() async {
    _categories = await Api.fetchCategories();
    setState(() {
      _selectedCategory = _categories.first;
    });
  }

  void _postTask(Map<String, dynamic> task, String url) {
    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.formData(
            url,
            task,
            (request) async {
              for (int i = 0; i < _imageFileList.length; i++) {
                request.files.add(
                  await http.MultipartFile.fromPath(
                    'taskImg',
                    _imageFileList[i].path,
                    filename: _imageFileList[i].name,
                    contentType: MediaType('image', path.extension(_imageFileList[i].name).replaceAll('.', '')),
                  ),
                );
              }
            },
          );

          if (context.mounted) {
            if (response['responseState'] == ResponseState.success) {
              await showAwsomeDialog(
                context: context,
                dialogType: DialogType.info,
                title: 'Success',
                description: 'Your task posted successfully',
                btnOkOnPress: () {},
              );

              setState(() {
                _formState.currentState!.reset();
                _imgsCount = 0;
                _imageFileList.clear();
                _locality = '';
                _latitude = -1;
                _longitude = -1;
                _taskLocationMarkers.clear();
                _type = 'POST';
                _priceSection = true;
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
}