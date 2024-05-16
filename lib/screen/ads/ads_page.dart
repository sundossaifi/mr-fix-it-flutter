import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/gallery_view.dart';
import 'package:mr_fix_it/components/img_card.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';
import 'package:mr_fix_it/screen/ads/components/share_ad.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class AdsPage extends StatefulWidget {
  final int workerID;
  final List<dynamic> ads;
  const AdsPage({super.key, required this.ads, required this.workerID});

  @override
  State<AdsPage> createState() => _AdsPagetState();
}

class _AdsPagetState extends State<AdsPage> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.all(8.0),
              child: TitleWithCustomUnderline(
                text: 'Ads',
                fontSize: 38,
                height: 38,
              ),
            ),
            ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.ads.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 400,
                  height: 350,
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
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
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
                              description: 'Are you sure to delete this ad?',
                              btnOkOnPress: () {
                                _deleteAd(widget.ads[index]['id']);
                              },
                            );
                          }
                        },
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ImageCard(
                              poster: widget.ads[index]['poster'],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    List<String> imgs = [];

                                    for (int i = 0; i < widget.ads.length; i++) {
                                      imgs.add(widget.ads[i]['poster']);
                                    }

                                    return FullScreenImageGallery(
                                      imageUrls: imgs,
                                      initialIndex: index,
                                      token: _accessToken,
                                    );
                                  }),
                                );
                              },
                            ),
                            Text.rich(
                              TextSpan(
                                children: [
                                  const WidgetSpan(
                                    child: Icon(
                                      Icons.calendar_month,
                                      size: 25,
                                      color: primaryColor,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        '${widget.ads[index]['startDate'].toString().substring(0, widget.ads[index]['startDate'].toString().indexOf("T"))} - ${widget.ads[index]['expiryDate'].toString().substring(0, widget.ads[index]['startDate'].toString().indexOf("T"))}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ShareNewAd(
                  ads: widget.ads,
                );
              },
            ).then((value) {
              setState(() {});
            });
          }
        },
        backgroundColor: primaryColor,
        child: const Icon(
          Icons.add,
          color: primaryBackgroundTextColor,
          size: 30,
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

  void _deleteAd(int id) {
    apiCall(
      context,
      () async {
        final response = await Api.postData('delete-ad/${id.toString()}', {});

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            widget.ads.removeWhere((element) => element['id'] == id);
            setState(() {});
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Ad deleted successfully',
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
