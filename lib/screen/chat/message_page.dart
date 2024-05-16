import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_fix_it/components/typing_indicator.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:mr_fix_it/components/app_bar.dart';

import 'package:mr_fix_it/screen/chat/call_page.dart';
import 'package:mr_fix_it/screen/chat/components/chat_message.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/response_state.dart';

class MessagePage extends StatefulWidget {
  final chat;
  const MessagePage({super.key, required this.chat});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  String _messageToSend = '';

  List<dynamic> _messages = [];
  List<ChatMessage> _messagesCards = [];
  String? _accessToken;

  bool _typing = false;
  bool _loading = true;

  StompClient? _stompClient;
  final TextEditingController _messageFieldController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getToken();
    _loadMessages(widget.chat['chatID']);
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return Scaffold(
      appBar: mainAppBar(
        0,
        Row(
          children: [
            BackButton(
              onPressed: () {
                _stompClient!.deactivate();
                Navigator.pop(context);
              },
            ),
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryBackgroundTextColor,
                  width: 3.0,
                ),
              ),
              child: ClipOval(
                child: Material(
                  color: Colors.transparent,
                  child: _accessToken != null
                      ? Image.network(
                          '${widget.chat['receiver']['img']}',
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 120),
                  child: Text(
                    widget.chat['receiver']['firstName'] + " " + widget.chat['receiver']['lastName'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: primaryBackgroundTextColor,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Api.postData('notify-audio-call/${widget.chat['receiver']['id']}', {});
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(
                      callID: widget.chat['chatID'].toString(),
                      userID: widget.chat['sender']['id'].toString(),
                      userName: widget.chat['sender']['firstName'] + " " + widget.chat['sender']['lastName'],
                      isVideoCall: false,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.phone,
                color: primaryBackgroundTextColor,
              ),
            ),
            IconButton(
              onPressed: () {
                Api.postData('notify-video-call/${widget.chat['receiver']['id']}', {});
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CallPage(
                      callID: widget.chat['chatID'].toString(),
                      userID: widget.chat['sender']['id'].toString(),
                      userName: widget.chat['sender']['firstName'] + " " + widget.chat['sender']['lastName'],
                      isVideoCall: true,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.video_call,
                color: primaryBackgroundTextColor,
              ),
            ),
          ],
        ),
        primaryColor,
        transparent,
        leadingWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/images/chat_wallpaper.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            if (_typing)
              Positioned(
                top: 5,
                left: MediaQuery.of(context).size.width / 2 - 25,
                child: Container(
                  width: 50,
                  height: 30,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(child: TypingIndicator()),
                ),
              ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 100),
                child: ListView.builder(
                  reverse: true,
                  shrinkWrap: true,
                  itemCount: _messagesCards.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    return _messagesCards[index];
                  },
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 100,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: TextField(
                        controller: _messageFieldController,
                        style: const TextStyle(color: primaryBackgroundTextColor),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.message_rounded,
                            color: primaryColor,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              if (_messageToSend.trim().isEmpty) {
                                return;
                              }
                              _stompClient!.send(
                                destination: '/app/chat',
                                body: json.encode(
                                  {
                                    'senderID': widget.chat['sender']['id'].toString(),
                                    'receiverID': widget.chat['receiver']['id'].toString(),
                                    'content': _messageToSend,
                                    'type': 'TEXT',
                                  },
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.send,
                              color: primaryColor,
                            ),
                          ),
                          hintText: "Message",
                          hintStyle: TextStyle(
                            color: primaryColor.withOpacity(0.5),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: primaryColor,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(30),
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _stompClient!.send(
                            destination: '/app/typing',
                            body: json.encode(
                              {
                                'roomID': widget.chat['chatID'].toString(),
                                'receiverID': widget.chat['receiver']['id'].toString(),
                                'type': 'TYPING'
                              },
                            ),
                          );

                          setState(() {
                            _messageToSend = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.image,
                          size: 25,
                          color: primaryBackgroundTextColor,
                        ),
                        onPressed: () async {
                          final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                          if (returnedImage != null) {
                            _sendImage(returnedImage);
                          }
                        },
                      ),
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

  void _loadMessages(int chatID) {
    apiCall(
      context,
      () async {
        Map<String, dynamic> response = await Api.fetchData(
          'get-chat-messages',
          {
            'chatID': chatID.toString(),
          },
        );
        _messages = response['messages'].reversed.toList();

        for (var message in _messages) {
          _messagesCards.add(
            ChatMessage(
              chat: widget.chat,
              message: message,
              accessToken: _accessToken,
            ),
          );
        }

        setState(() {
          _loading = false;
        });
      },
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }

  void _onConnect(StompFrame frame) {
    _stompClient!.subscribe(
      destination: '/user/${widget.chat['chatID']}/queue/messages',
      callback: (frame) {
        final result = json.decode(frame.body!);

        if (result['receiverID'].toString() == widget.chat['sender']['id'].toString() &&
            result['type'] != 'TYPING' &&
            result['type'] != 'SEEN') {
          _stompClient!.send(
            destination: '/app/seen',
            body: json.encode(
              {
                'roomID': widget.chat['chatID'].toString(),
                'receiverID': widget.chat['receiver']['id'].toString(),
                'type': 'SEEN',
              },
            ),
          );
        }

        if (result['type'] == 'TEXT' || result['type'] == 'IMAGE') {
          _messages.insert(0, result);
          _messagesCards.insert(
            0,
            ChatMessage(
              chat: widget.chat,
              message: result,
              accessToken: _accessToken,
            ),
          );
          _getToken();

          setState(() {
            _typing = false;
            _messageToSend = '';
            _messageFieldController.clear();
          });
        } else if (result['type'] == 'TYPING' && result['receiverID'].toString() == widget.chat['sender']['id'].toString()) {
          setState(() {
            _typing = true;
          });

          Timer(const Duration(seconds: 3), () {
            setState(() {
              _typing = false;
            });
          });
        } else if (result['type'] == 'SEEN' && result['receiverID'].toString() == widget.chat['sender']['id'].toString()) {
          for (int i = 0; i < _messages.length; i++) {
            if (_messages[i]['senderID'].toString() == widget.chat['sender']['id'].toString() && _messages[i]['seen'] == false) {
              _messages[i]['seen'] = true;
              _messagesCards[i].message['seen'] = true;

              if (!_messagesCards[i].seenKey.currentState!.isFront) {
                _messagesCards[i].seenKey.currentState!.toggleCard();
              }

              setState(() {});
            }
          }
        }
      },
    );

    _stompClient!.send(
      destination: '/app/seen',
      body: json.encode(
        {
          'roomID': widget.chat['chatID'].toString(),
          'receiverID': widget.chat['receiver']['id'].toString(),
          'type': 'SEEN',
        },
      ),
    );
  }

  void _connect() async {
    _stompClient = StompClient(
      config: StompConfig(
        url: 'ws://13.60.3.70/ws',
        onConnect: _onConnect,
        beforeConnect: () async {
          await Future.delayed(const Duration(milliseconds: 200));
        },
        onWebSocketError: (dynamic error) {
          if (context.mounted) {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: 'Error',
              description: error.toString(),
              btnOkOnPress: () {},
            );
          }
        },
      ),
    );

    _stompClient!.activate();
  }

  void _sendImage(XFile? selectedImage) {
    if (selectedImage == null) {
      return;
    }

    apiCall(
      context,
      () async {
        final response = await Api.formData(
          'chat-image-upload',
          {},
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
            _stompClient!.send(
              destination: '/app/chat',
              body: json.encode(
                {
                  'senderID': widget.chat['sender']['id'].toString(),
                  'receiverID': widget.chat['receiver']['id'].toString(),
                  'content': response['body']['message'],
                  'type': 'IMAGE',
                },
              ),
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
