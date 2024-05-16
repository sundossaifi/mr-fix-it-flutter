import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:reels_viewer/reels_viewer.dart';

class ReelsScreen extends StatefulWidget {
  final bool isOwner;
  final String accessToken;
  final List<dynamic> reels;

  const ReelsScreen({super.key, required this.reels, required this.accessToken, required this.isOwner});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int currentIndex = 0;
  List<ReelModel> reelsList = [];

  @override
  void initState() {
    super.initState();
    _initReels();
  }

  @override
  Widget build(BuildContext context) {
    if (reelsList.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return ReelsViewer(
      reelsList: reelsList,
      appbarTitle: 'Reels',
      onComment: (comment) {
        apiCall(
          context,
          () async {
            final response = await Api.postData(
              'post-comment/${widget.reels[currentIndex]['id'].toString()}',
              {
                'comment': comment,
              },
            );

            if (context.mounted) {
              if (response['responseState'] == ResponseState.success) {
                List<String> dateParts = response['body']['comment']['commentDate']
                    .toString()
                    .substring(0, response['body']['comment']['commentDate'].toString().indexOf("T"))
                    .split("-");

                reelsList[currentIndex].commentList!.add(
                      ReelCommentModel(
                        comment: response['body']['comment']['comment'],
                        userProfilePic: response['body']['comment']['user']['img'],
                        userName: response['body']['comment']['user']['firstName'] + ' ' + response['body']['comment']['user']['lastName'],
                        commentTime: DateTime(
                          int.parse(dateParts[2]),
                          int.parse(dateParts[1]),
                          int.parse(dateParts[0]),
                        ),
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
      },
      onClickMoreBtn: widget.isOwner
          ? () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SimpleDialog(
                    title: const Text('More Options'),
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.delete),
                        title: const Text('Delete'),
                        onTap: () {
                          _deleteReel(widget.reels[currentIndex]['id']);
                        },
                      ),
                    ],
                  );
                },
              );
            }
          : () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerProfile(
                    worker: widget.reels[currentIndex]['worker'],
                  ),
                ),
              );
            },
      onIndexChanged: (index) {
        currentIndex = index;
      },
      showProgressIndicator: true,
      showVerifiedTick: true,
      showAppbar: true,
    );
  }

  void _deleteReel(int id) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData('delete-reel/${id.toString()}', {});

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Reel deleted successfully',
              btnOkOnPress: () {},
            );
            if (context.mounted) {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            }
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

  void _initReels() {
    for (int i = 0; i < widget.reels.length; i++) {
      List<ReelCommentModel> commentList = [];
      List<dynamic> comments = widget.reels[i]['comments'];

      for (int j = 0; j < comments.length; j++) {
        List<String> dateParts = widget.reels[i]['comments'][j]['commentDate']
            .toString()
            .substring(0, widget.reels[i]['comments'][j]['commentDate'].toString().indexOf("T"))
            .split("-");

        commentList.add(
          ReelCommentModel(
            comment: widget.reels[i]['comments'][j]['comment'],
            userProfilePic: widget.reels[i]['comments'][j]['user']['img'],
            userName: widget.reels[i]['comments'][j]['user']['firstName'] + ' ' + widget.reels[i]['comments'][j]['user']['lastName'],
            commentTime: DateTime(
              int.parse(dateParts[2]),
              int.parse(dateParts[1]),
              int.parse(dateParts[0]),
            ),
          ),
        );
      }

      reelsList.add(
        ReelModel(
          widget.reels[i]['video'],
          widget.reels[i]['worker']['firstName'] + ' ' + widget.reels[i]['worker']['lastName'],
          reelDescription: widget.reels[i]['postDate'].toString().substring(0, widget.reels[i]['postDate'].toString().indexOf("T")),
          commentList: commentList,
        ),
      );

      setState(() {});
    }
  }
}
