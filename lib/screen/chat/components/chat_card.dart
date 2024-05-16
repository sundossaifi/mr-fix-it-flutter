import 'package:flutter/material.dart';

import 'package:mr_fix_it/screen/chat/message_page.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class ChatCard extends StatefulWidget {
  final chat;
  final Function onpop;

  ChatCard({super.key, required this.chat, required this.onpop});

  @override
  State<ChatCard> createState() => _ChatCardState();
}

class _ChatCardState extends State<ChatCard> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessagePage(chat: widget.chat),
            ),
          ).then(
            (value) => widget.onpop(),
          );
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.chat['receiver']['firstName'] + " " + widget.chat['receiver']['lastName'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: primaryColor,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                widget.chat['lastMessage']['type'] == 'TEXT' ? widget.chat['lastMessage']['content'] : 'IMAGE',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            widget.chat['lastMessage']['timestamp'].toString().split("T")[1].substring(0, 5),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Container(
                            height: 30,
                            width: 30,
                            decoration: const BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(50),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.chat['newMessages'].toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBackgroundTextColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
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
}
