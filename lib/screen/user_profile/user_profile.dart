import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';

import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

// ignore: must_be_immutable
class UserProfile extends StatefulWidget {
  late Map<String, dynamic> _user;

  UserProfile({super.key, required Map<String, dynamic> user}) {
    _user = user;
  }

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _firstName;
  String? _lastName;
  String? _dob;
  String? _selectedGender;
  String? _city;
  String? _email;
  String? _phone;

  String? _accessToken;
  bool _datePickerVisiablity = false;

  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initFields();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    double imageWidth = height * 0.2;
    double imageHeight = height * 0.2;

    return Scaffold(
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.3,
              child: Stack(
                children: [
                  Positioned(
                    child: ClipPath(
                      clipper: OvalBottomBorderClipper(),
                      child: Container(
                        height: height * 0.2,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.1 - 75,
                    child: SizedBox(
                      width: width,
                      height: 100,
                      child: const Text(
                        'Profile Information',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: primaryBackgroundTextColor,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: height * 0.2 - imageHeight / 2,
                    right: (width / 2) - imageWidth / 2,
                    child: Stack(
                      children: [
                        Positioned(
                          child: InkWell(
                            child: Container(
                              width: imageWidth,
                              height: imageHeight,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryBackgroundTextColor, // Change the color as per your requirement
                                  width: 3.0,
                                ),
                              ),
                              child: ClipOval(
                                child: Material(
                                  color: Colors.transparent,
                                  child: _accessToken != null
                                      ? Image.network(
                                          '${widget._user['img']}',
                                          //headers: {"Authorization": "Bearer $_accessToken"},
                                          fit: BoxFit.cover,
                                        )
                                      : const CircularProgressIndicator(color: primaryColor),
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return FullScreenImageGallery(
                                      imageUrls: [widget._user['img']],
                                      initialIndex: 0,
                                      token: _accessToken,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: grayBackgorund,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryBackgroundTextColor,
                                width: 3.0,
                              ),
                            ),
                            child: Center(
                              child: IconButton(
                                iconSize: 30,
                                icon: const Icon(Icons.camera_enhance),
                                onPressed: () async {
                                  final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                                  if (returnedImage != null) {
                                    _updateUserImg(returnedImage);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                key: _formState,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: formTextInput(
                            label: 'First Name',
                            controller: TextEditingController(text: _firstName),
                            hint: "First Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'First name is empty';
                              }

                              if (value.length > 50) {
                                return 'First name exceeds 50 character';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              _firstName = value;
                            },
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: formTextInput(
                            label: 'Last Name',
                            controller: TextEditingController(text: _lastName),
                            hint: "Last Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Last name is empty';
                              }

                              if (value.length > 50) {
                                return 'Last name exceeds 50 character';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              _lastName = value;
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: formTextInput(
                            label: 'Birthday',
                            controller: TextEditingController(text: _dob),
                            readOnly: true,
                            hint: "Birthday",
                            icon: Icons.date_range,
                            validator: (value) {
                              if (value!.trim().isEmpty) {
                                return 'Birthday is empty';
                              }

                              if (!RegExp(birthdayRegex).hasMatch(value)) {
                                return 'Birthday is invalid';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              _dob = value;
                            },
                            onTap: () {
                              setState(() {
                                _datePickerVisiablity = !_datePickerVisiablity;
                              });
                            },
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                            ),
                            child: DropdownMenu<String>(
                              width: width / 2 - 15,
                              label: const Text(
                                "Gender: ",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 17,
                                ),
                              ),
                              inputDecorationTheme: InputDecorationTheme(
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: primaryColor),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              initialSelection: _selectedGender,
                              onSelected: (String? value) {
                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                              dropdownMenuEntries: const [
                                DropdownMenuEntry(value: 'MALE', label: 'MALE'),
                                DropdownMenuEntry(value: 'FEMALE', label: 'FEMALE'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_datePickerVisiablity)
                      SfDateRangePicker(
                        selectionMode: DateRangePickerSelectionMode.single,
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                          setState(() {
                            _dob = args.value.toString().substring(0, 10);
                            _datePickerVisiablity = false;
                          });
                        },
                      ),
                    formTextInput(
                      label: 'City',
                      controller: TextEditingController(text: _city),
                      hint: "City",
                      icon: Icons.location_city,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'City is empty';
                        }

                        if (value.length > 50) {
                          return 'City exceeds 50 character';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _city = value;
                      },
                    ),
                    formTextInput(
                      label: 'Email',
                      controller: TextEditingController(text: _email),
                      hint: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Email is empty';
                        }

                        if (!RegExp(emailRegex).hasMatch(value)) {
                          return 'Email is invalid';
                        }

                        if (value.length > 50) {
                          return 'Email exceeds 50 character';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _email = value;
                      },
                    ),
                    formTextInput(
                      label: 'Phone Number',
                      controller: TextEditingController(text: _phone),
                      hint: "Phone Number",
                      icon: Icons.call,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value!.trim().isEmpty) {
                          return 'Phone is empty';
                        }

                        if (!RegExp(phoneRegex).hasMatch(value)) {
                          return 'Phone is invalid';
                        }

                        return null;
                      },
                      onChanged: (value) {
                        _phone = value;
                      },
                    ),
                    Container(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          child: ButtonWidget(
                            btnText: "SAVE",
                            backgroundColor: primaryColor,
                            onClick: () {
                              _saveInfomation();
                            },
                          ),
                        ),
                        Container(
                          width: 20,
                        ),
                        SizedBox(
                          width: 100,
                          child: ButtonWidget(
                            btnText: "CANCEL",
                            backgroundColor: primaryColor,
                            onClick: () {
                              setState(() {
                                _initFields();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

  void _initFields() {
    setState(() {
      _firstName = widget._user['firstName'];
      _lastName = widget._user['lastName'];
      _dob = widget._user['dob'];
      _selectedGender = widget._user['gender'];
      _city = widget._user['city'];
      _email = widget._user['email'];
      _phone = widget._user['phone'];
    });
  }

  void _saveInfomation() {
    if (!_formState.currentState!.validate()) {
      return;
    }

    Map<String, dynamic> user = {
      'firstName': _firstName,
      'lastName': _lastName,
      'dob': _dob,
      'gender': _selectedGender,
      'city': _city,
      'email': _email,
      'phone': _phone,
    };

    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.postData(
            'update-user',
            user,
          );

          if (context.mounted) {
            if (response['responseState'] == ResponseState.success) {
              await showAwsomeDialog(
                context: context,
                dialogType: DialogType.info,
                title: 'Success',
                description: 'Your information updated successfully',
                btnOkOnPress: () {},
              );

              SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

              setState(() {
                widget._user['firstName'] = _firstName;
                widget._user['lastName'] = _lastName;
                widget._user['dob'] = _dob;
                widget._user['gender'] = _selectedGender;
                widget._user['city'] = _city;
                widget._user['email'] = _email;
                widget._user['phone'] = _phone;
                sharedPreferences.setString('user', json.encode(widget._user));
              });
            } else if (response['responseState'] == ResponseState.conflict) {
              showAwsomeDialog(
                context: context,
                dialogType: DialogType.error,
                title: 'Failed',
                description: 'Email or phone number already taken',
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
  }

  void _updateUserImg(XFile? selectedImage) {
    if (selectedImage == null) {
      return;
    }

    apiCall(
      context,
      () async {
        final response = await Api.formData(
          'update-user-img',
          {
            'userID': widget._user['id'].toString(),
          },
          (request) async {
            request.files.add(
              await http.MultipartFile.fromPath(
                'img',
                selectedImage.path,
                filename: selectedImage.name,
                contentType: MediaType('image', path.extension(selectedImage.name).replaceAll('.', '')),
              ),
            );
          },
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Your profile picture updated successfully',
              btnOkOnPress: () {},
            );

            SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

            setState(() {
              widget._user['img'] = response['body']['message'];
              sharedPreferences.setString('user', json.encode(widget._user));
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
