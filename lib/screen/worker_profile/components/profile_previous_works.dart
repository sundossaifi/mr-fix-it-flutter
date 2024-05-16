import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import 'package:mr_fix_it/util/api/api.dart';

// ignore: must_be_immutable
class ProfilePreviousWorks extends StatefulWidget {
  late bool _isOwner;
  late double _height;
  late List<dynamic> _previousWorks;

  ProfilePreviousWorks({super.key, required List<dynamic> previousWorks, required double height, required bool isOwner}) {
    _isOwner = isOwner;
    _height = height;
    _previousWorks = previousWorks;
  }

  @override
  State<ProfilePreviousWorks> createState() => _ProfilePreviousWorksState();
}

class _ProfilePreviousWorksState extends State<ProfilePreviousWorks> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: TitleWithCustomUnderline(
            text: 'Previous Work',
            fontSize: 24,
            height: 24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: widget._height,
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: widget._previousWorks.length,
              itemBuilder: (BuildContext context, int i) {
                return Container(
                  height: 300,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      ),
                    ],
                    border: Border.all(
                      color: primaryColor,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 165,
                        child: InkWell(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: PhotoViewGallery.builder(
                              scrollPhysics: const ClampingScrollPhysics(),
                              itemCount: widget._previousWorks[i]['previousWorkImgs'].length,
                              builder: (BuildContext context, int j) {
                                return PhotoViewGalleryPageOptions(
                                  imageProvider: NetworkImage(
                                    '${widget._previousWorks[i]['previousWorkImgs'][j]['img']}',
                                    //headers: {"Authorization": "Bearer $_accessToken}"},
                                  ),
                                  initialScale: PhotoViewComputedScale.covered,
                                );
                              },
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  List<String> imgs = [];

                                  for (int x = 0; x < widget._previousWorks[i]['previousWorkImgs'].length; x++) {
                                    imgs.add(widget._previousWorks[i]['previousWorkImgs'][x]['img']);
                                  }

                                  return FullScreenImageGallery(
                                    imageUrls: imgs,
                                    initialIndex: 0,
                                    token: _accessToken,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 300,
                        child: VerticalDivider(
                          thickness: 2,
                          width: 25,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(
                            widget._previousWorks[i]['description'],
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      if (widget._isOwner)
                        PopupMenuButton(
                          itemBuilder: (context) {
                            return [
                              const PopupMenuItem<int>(
                                value: 0,
                                child: Text("Delete"),
                              ),
                            ];
                          },
                          onSelected: (value) {
                            if (value == 0) {
                              showAwsomeDialog(
                                context: context,
                                dialogType: DialogType.question,
                                title: 'Confirm',
                                description: 'Are you sure to delete?',
                                btnOkOnPress: () {
                                  _deletePreviousWork(widget._previousWorks[i]['id']);
                                },
                              );
                            }
                          },
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }

  void _deletePreviousWork(int id) {
    apiCall(
      context,
      () async {
        final response = await Api.postData('delete-previous-work/${id.toString()}', {});

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            widget._previousWorks.removeWhere((element) => element['id'] == id);
            setState(() {});
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Previous work deleted successfully',
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
