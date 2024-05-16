import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:gallery_image_viewer/gallery_image_viewer.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:mr_fix_it/util/api/api.dart';

import 'package:mr_fix_it/util/constants.dart';

class ChatMessage extends StatefulWidget {
  final chat;
  final message;
  final String? accessToken;
  final GlobalKey<FlipCardState> seenKey = GlobalKey<FlipCardState>();
  ChatMessage({super.key, required this.chat, required this.message, required this.accessToken});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: widget.chat['sender']['id'] == widget.message['senderID'] ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: (MediaQuery.of(context).size.width / 2) - 10,
                ),
                child: widget.message['type'] == 'TEXT'
                    ? Container(
                        decoration: BoxDecoration(
                          color:
                              widget.chat['sender']['id'] == widget.message['senderID'] ? const Color(0xff118ab2) : const Color(0xffa5a58d),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(
                          bottom: 3,
                        ),
                        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                widget.message['content'],
                                softWrap: true,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBackgroundTextColor,
                                ),
                              ),
                            ),
                            if (widget.message['senderID'] == widget.chat['sender']['id'])
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: FlipCard(
                                  key: widget.seenKey,
                                  flipOnTouch: false,
                                  front: Container(
                                    height: 18,
                                    width: 18,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset('asset/images/seen.png'),
                                  ),
                                  back: Container(
                                    height: 18,
                                    width: 18,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset('asset/images/not_seen.png'),
                                  ),
                                  side: widget.message['seen'] == true ? CardSide.FRONT : CardSide.BACK,
                                ),
                              ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color:
                              widget.chat['sender']['id'] == widget.message['senderID'] ? const Color(0xff118ab2) : const Color(0xffa5a58d),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.only(
                          bottom: 3,
                        ),
                        padding: const EdgeInsets.only(top: 7, left: 7, right: 7),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                child: Image(
                                  image: NetworkImage(
                                    '${widget.message['content']}',
                                    //headers: {"Authorization": "Bearer ${widget.accessToken}}"},
                                  ),
                                  fit: BoxFit.cover,
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return FullScreenImageGallery(
                                          imageUrls: [widget.message['content']],
                                          initialIndex: 0,
                                          token: widget.accessToken,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (widget.message['senderID'] == widget.chat['sender']['id'])
                              Positioned(
                                left: 0,
                                bottom: 0,
                                child: FlipCard(
                                  key: widget.seenKey,
                                  flipOnTouch: false,
                                  front: Container(
                                    height: 18,
                                    width: 18,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset('asset/images/seen.png'),
                                  ),
                                  back: Container(
                                    height: 18,
                                    width: 18,
                                    margin: const EdgeInsets.only(bottom: 2),
                                    child: Image.asset('asset/images/not_seen.png'),
                                  ),
                                  side: widget.message['seen'] == true ? CardSide.FRONT : CardSide.BACK,
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
