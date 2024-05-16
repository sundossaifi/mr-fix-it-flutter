import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:video_player/video_player.dart';

class ShareNewReel extends StatefulWidget {
  final List<dynamic> reels;
  const ShareNewReel({super.key, required this.reels});

  @override
  State<ShareNewReel> createState() => _ShareNewReelState();
}

class _ShareNewReelState extends State<ShareNewReel> {
  XFile? reel;
  late VideoPlayerController _controller; // Add this line

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(reel?.path ?? ''))
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'New Reel ',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                ),
              ),
              WidgetSpan(
                child: Icon(
                  Icons.ondemand_video,
                  size: 45,
                  color: Color(0xff118ab2),
                ),
              ),
            ],
          ),
        ),
      ),
      content: SizedBox(
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: primaryColor,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.center,
              child: InkWell(
                child: reel == null
                    ? const Icon(
                        Icons.video_file,
                        size: 45,
                        color: Color(0xff118ab2),
                      )
                    : VideoPlayer(_controller),
                onTap: () async {
                  final returnedVideo = await ImagePicker().pickVideo(source: ImageSource.gallery);

                  if (returnedVideo != null) {
                    setState(() {
                      reel = returnedVideo;
                      _controller = VideoPlayerController.file(File(reel!.path))
                        ..initialize().then((_) {
                          setState(() {});
                        });
                    });
                  }
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
              child: InkWell(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  apiCall(
                    context,
                    () async {
                      final response = await Api.formData(
                        'add-reel',
                        {},
                        (request) async {
                          request.files.add(
                            await http.MultipartFile.fromPath(
                              'video',
                              reel!.path,
                              filename: reel!.name,
                              contentType: MediaType('video', path.extension(reel!.name).replaceAll('.', '')),
                            ),
                          );
                        },
                      );

                      if (context.mounted) {
                        if (response['responseState'] == ResponseState.success) {
                          widget.reels.add(response['body']['reel']);
                          setState(() {});
                          showAwsomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            title: 'Success',
                            description: 'Reel shared successfully',
                            btnOkOnPress: () {
                              Navigator.pop(context);
                            },
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
