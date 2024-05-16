import 'package:flutter/material.dart';
import 'package:mr_fix_it/screen/ReelsPage/ReelsPage.dart';
import 'package:mr_fix_it/screen/worker_reels/share_new_reel.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';

class WorkerReelsPage extends StatefulWidget {
  final int workerID;
  const WorkerReelsPage({super.key, required this.workerID});

  @override
  State<WorkerReelsPage> createState() => _WorkerReelsPageState();
}

class _WorkerReelsPageState extends State<WorkerReelsPage> {
  List<dynamic> reels = [];
  String? _accessToken;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getToken();
    _getReels(false);
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
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: backgroundColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.all(8.0),
                child: TitleWithCustomUnderline(
                  text: 'Reels',
                  fontSize: 38,
                  height: 38,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: reels.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FutureBuilder<Uint8List?>(
                      future: getVideoThumbnail(reels[index]['video']),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReelsScreen(
                                    isOwner: true,
                                    accessToken: _accessToken!,
                                    reels: [reels[index]],
                                  ),
                                ),
                              ).then((value) {
                                _getReels(false);
                                setState(() {});
                              });
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xff118ab2),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            height: 100,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _getReels(true);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return ShareNewReel(
                  reels: reels,
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

  Future<Uint8List?> getVideoThumbnail(String videoUrl) async {
    final uint8list = await VideoThumbnail.thumbnailData(
      //headers: {"Authorization": "Bearer $_accessToken}"},
      video: videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 100,
    );

    return uint8list;
  }

  Future<Image> getImageFromBytes(Uint8List bytes) async {
    final Completer<Image> completer = Completer();
    final Image image = Image.memory(bytes);
    image.image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(image);
    }));
    return completer.future;
  }

  void _getReels(bool refresh) {
    apiCall(
      context,
      () async {
        final response = await Api.fetchData('get-worker-reels', <String, String>{});
        reels = response['reels'];

        setState(() {
          _loading = false;
        });

        if (refresh && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refreshed'),
            ),
          );
        }
      },
    );
  }
}
