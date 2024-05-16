import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:mr_fix_it/screen/login/login_page.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/header_container.dart';
import 'package:mr_fix_it/components/form_text_input.dart';

import 'package:mr_fix_it/model/working_location.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class RegistePage extends StatefulWidget {
  const RegistePage({super.key});

  @override
  RegPageState createState() => RegPageState();
}

class RegPageState extends State<RegistePage> {
  String? _firstName;
  String? _lastName;
  String? _dob;
  String _gender = 'MALE';
  String? _city;
  String? _email;
  String? _password;
  String? _phone;
  String? _selectedCategory;
  XFile? _selectedImage;
  String _imageName = 'No image';
  String _type = 'CLIENT';

  List<dynamic> _categories = [''];
  final List<Marker> _workingLocationMarkers = [];
  final List<WorkingLocation> _workingLocations = [];

  bool _datePickerVisiablity = false;
  bool _workerInfoSection = false;
  bool _messingProfilePicture = false;
  bool _messingWorkingLocations = false;

  final dobFieldController = TextEditingController();
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
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: <Widget>[
            const HeaderContainer(
              text: "Register",
            ),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.40,
                    margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formState,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: formTextInput(
                                    label: 'First Name',
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
                                    onSaved: (value) {
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
                                    onSaved: (value) {
                                      _lastName = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                            formTextInput(
                              label: 'Birthday',
                              controller: dobFieldController,
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
                              onSaved: (value) {
                                _dob = value;
                              },
                              onTap: () {
                                setState(() {
                                  _datePickerVisiablity = !_datePickerVisiablity;
                                });
                              },
                            ),
                            if (_datePickerVisiablity)
                              SfDateRangePicker(
                                selectionMode: DateRangePickerSelectionMode.single,
                                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                                  setState(() {
                                    dobFieldController.text = args.value.toString().substring(0, 10);
                                    _datePickerVisiablity = false;
                                  });
                                },
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text(
                                      'Male',
                                    ),
                                    value: 'MALE',
                                    groupValue: _gender,
                                    onChanged: (value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text(
                                      'Female',
                                    ),
                                    value: 'FEMALE',
                                    groupValue: _gender,
                                    onChanged: (value) {
                                      setState(() {
                                        _gender = value!;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            formTextInput(
                              label: 'City',
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
                              onSaved: (value) {
                                _city = value;
                              },
                            ),
                            formTextInput(
                              label: 'Email',
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
                              onSaved: (value) {
                                _email = value;
                              },
                            ),
                            formTextInput(
                              label: 'Password',
                              obscureText: true,
                              hint: "Password",
                              icon: Icons.vpn_key,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (value) {
                                if (value!.trim().isEmpty) {
                                  return 'Password is empty';
                                }

                                if (value.length < 8) {
                                  return 'Password should be at least 8 characters';
                                }

                                if (value.length > 16) {
                                  return 'Password exceeds 16 character';
                                }

                                if (!RegExp(passwordRegex).hasMatch(value)) {
                                  return 'Password should contain lower, upper, special characters and number';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _password = value;
                              },
                            ),
                            formTextInput(
                              label: 'Phone Number',
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
                              onSaved: (value) {
                                _phone = value;
                              },
                            ),
                            Container(
                              height: 15,
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
                                    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                                    if (returnedImage != null) {
                                      setState(() {
                                        _imageName = returnedImage.name;
                                        _selectedImage = returnedImage;
                                      });
                                    }
                                  },
                                ),
                                Text(
                                  'Profile picture: $_imageName',
                                ),
                              ],
                            ),
                            if (_messingProfilePicture)
                              const Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Messing profile picture',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text(
                                      'Client',
                                    ),
                                    value: 'CLIENT',
                                    groupValue: _type,
                                    onChanged: (value) {
                                      setState(() {
                                        _type = value!;
                                        _workerInfoSection = false;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text(
                                      'Worker',
                                    ),
                                    value: 'WORKER',
                                    groupValue: _type,
                                    onChanged: (value) {
                                      setState(() {
                                        _type = value!;
                                        _workerInfoSection = true;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (_workerInfoSection)
                              SizedBox(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            "Working Locations: ",
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
                                                  if (_workingLocationMarkers.isNotEmpty) {
                                                    _workingLocations.removeLast();
                                                    _workingLocationMarkers.removeLast();
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
                                            List<Placemark> workingLocationPlaceMarks =
                                                await placemarkFromCoordinates(latlang.latitude, latlang.longitude);

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
                                              _workingLocations.add(
                                                WorkingLocation(
                                                  locality: locality!,
                                                  latitude: latlang.latitude.toString(),
                                                  longitude: latlang.longitude.toString(),
                                                ),
                                              );

                                              setState(() {
                                                _workingLocationMarkers.add(Marker(
                                                    position: LatLng(latlang.latitude, latlang.longitude),
                                                    markerId: MarkerId(latlang.toString())));
                                              });
                                            }
                                          } on Exception catch (_) {}
                                        },
                                        markers: _workingLocationMarkers.toSet(),
                                      ),
                                    ),
                                    if (_messingWorkingLocations)
                                      const Text(
                                        'Messing working locations',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    Container(
                                      height: 30,
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
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
                      child: Center(
                        child: ButtonWidget(
                          btnText: "REGISTER",
                          backgroundColor: primaryColor,
                          onClick: () {
                            bool validTextFieldsData = _formState.currentState!.validate();

                            setState(() {
                              _messingProfilePicture = (_selectedImage == null);
                              _messingWorkingLocations = (_workingLocations.isEmpty);
                            });

                            if (!validTextFieldsData || _messingProfilePicture || (_messingWorkingLocations && _type == 'WORKER')) {
                              return;
                            }

                            _formState.currentState!.save();

                            Map<String, dynamic> user = {
                              'firstName': _firstName,
                              'lastName': _lastName,
                              'dob': _dob,
                              'gender': _gender,
                              'city': _city,
                              'email': _email,
                              'password': _password,
                              'phone': _phone,
                              'profilePicture': _selectedImage,
                            };

                            if (_type == 'WORKER') {
                              user['workingLocations'] = _workingLocations;
                              user['category'] = _selectedCategory;
                            }

                            _register(user, _type == 'WORKER');
                          },
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 20,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: "Already a member ? ",
                          style: TextStyle(
                            color: whiteBackgroundTextColor,
                          ),
                        ),
                        TextSpan(
                          text: "Login",
                          style: const TextStyle(color: primaryColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
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

  void _register(Map<String, dynamic> user, bool isWorker) async {
    ResponseState responseState = await Api.register(user, isWorker);

    if (context.mounted) {
      if (responseState == ResponseState.success) {
        await showAwsomeDialog(
          context: context,
          dialogType: DialogType.info,
          title: 'Verify your account',
          description: 'a verification link have been sent to your email',
          btnOkOnPress: () {},
        );

        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ),
          );
        }
      } else if (responseState == ResponseState.conflict) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Already registered',
          description: 'there is exising account with provided email or phone',
          btnOkOnPress: () {},
        );
      } else if (responseState == ResponseState.error) {
        showAwsomeDialog(
          context: context,
          dialogType: DialogType.error,
          title: 'Error',
          description: 'Something went wrong, please try again later',
          btnOkOnPress: () {},
        );
      }
    }
  }

  bool _isDuplicatedWorkingLocation(String? locality) {
    if (locality == null) {
      return false;
    }

    return _workingLocations
            .singleWhere((element) => element.locality.toLowerCase() == locality.toLowerCase(),
                orElse: () => WorkingLocation(locality: "-", latitude: '-1', longitude: '-1'))
            .latitude !=
        '-1';
  }
}
