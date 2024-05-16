import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:mr_fix_it/screen/chat/message_page.dart';

import 'package:mr_fix_it/screen/worker_profile/components/clipper.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class ProfileInformationHeader extends StatefulWidget {
  late int _id;
  late String _firstName;
  late String _lastName;
  late String _category;
  late String _email;
  late String _img;
  late double _rate;

  late BottomDrawerController _bottomDrawerController;

  ProfileInformationHeader(
      {super.key,
      required int id,
      required String firstName,
      required String lastName,
      required String category,
      required String email,
      required String img,
      required double rate,
      required BottomDrawerController bottomDrawerController}) {
    _id = id;
    _firstName = firstName;
    _lastName = lastName;
    _category = category;
    _email = email;
    _img = img;
    _rate = rate;
    _bottomDrawerController = bottomDrawerController;
  }

  @override
  State<ProfileInformationHeader> createState() => _ProfileInformationHeaderState();
}

class _ProfileInformationHeaderState extends State<ProfileInformationHeader> {
  String? _message = '';

  final GlobalKey<FormState> _formState = GlobalKey();

  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: Clipper(),
      child: InkWell(
        child: Container(
          color: primaryColor,
          padding: const EdgeInsets.only(top: defultpadding),
          height: 590,
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: backgroundColor,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Material(
                      color: transparent,
                      child: _accessToken != null
                          ? Image.network(
                              '${widget._img}',
                              //headers: {"Authorization": "Bearer $_accessToken}"},
                              fit: BoxFit.cover,
                            )
                          : const CircularProgressIndicator(color: primaryColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '${widget._firstName} ${widget._lastName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget._category,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: backgroundColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget._email,
                    style: const TextStyle(
                      color: backgroundColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              widget._rate.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: backgroundColor),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Rate',
                              style: TextStyle(fontWeight: FontWeight.bold, color: backgroundColor),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                          child: VerticalDivider(
                            thickness: 2,
                            width: 25,
                            color: backgroundColor,
                          ),
                        ),
                        SizedBox(
                          child: RatingBar.builder(
                            initialRating: widget._rate,
                            itemSize: 40,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: backgroundColor,
                            ),
                            onRatingUpdate: (rating) {},
                            ignoreGestures: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: backgroundColor,
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Request a Task',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 18,
                      ),
                    ),
                    onPressed: () {
                      widget._bottomDrawerController.open();
                    },
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Center(
                      child: InkWell(
                        child: const Icon(
                          Icons.message,
                          size: 30,
                          color: primaryColor,
                        ),
                        onTap: () {
                          _messagePage();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return FullScreenImageGallery(
                  imageUrls: [widget._img],
                  initialIndex: 0,
                  token: _accessToken,
                );
              },
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

  void _messagePage() async {
    apiCall(
      context,
      () async {
        final response = await Api.fetchData(
          'get-chat',
          {
            'receiverID': widget._id.toString(),
          },
        );

        if (context.mounted && response['chat'] != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagePage(chat: response['chat']),
            ),
          );
        } else {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text(
                    'New Message',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: SizedBox(
                    height: 180,
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
                                label: 'Message',
                                hint: "Message",
                                icon: Icons.message,
                                maxLines: 3,
                                validator: (value) {
                                  if (value!.trim().isEmpty) {
                                    return 'Message is empty';
                                  }

                                  return null;
                                },
                                onSaved: (value) {
                                  _message = value;
                                },
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 30),
                                child: Center(
                                  child: ButtonWidget(
                                    btnText: "Send",
                                    backgroundColor: primaryColor,
                                    onClick: () {
                                      if (!_formState.currentState!.validate()) {
                                        return;
                                      }

                                      _formState.currentState!.save();
                                      _sendMessage(_message);
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
          }
        }
      },
    );
  }

  void _sendMessage(String? message) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final user = json.decode(sharedPreferences.getString('user')!);

    if (context.mounted) {
      apiCall(
        context,
        () async {
          final response = await Api.postData(
            'new-message',
            {
              'senderID': user['id'].toString(),
              'receiverID': widget._id.toString(),
              'content': message,
              'type': 'TEXT',
            },
          );

          if (response['responseState'] == ResponseState.success) {
            if (context.mounted) {
              Navigator.pop(context);
              _messagePage();
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
}
