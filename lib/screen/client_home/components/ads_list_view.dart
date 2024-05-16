import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/gallery_view.dart';

import 'package:mr_fix_it/components/img_card.dart';
import 'package:mr_fix_it/util/api/api.dart';

// ignore: must_be_immutable
class AdsListView extends StatefulWidget {
  late List<dynamic> _ads;

  AdsListView({super.key, required List<dynamic> ads}) {
    _ads = ads;
  }

  @override
  State<AdsListView> createState() => _AdsListViewState();
}

class _AdsListViewState extends State<AdsListView> {
  String? _accessToken;
  final PageController _pageController = PageController(viewportFraction: 0.9);

  @override
  void initState() {
    super.initState();
    _getToken();

    Future.delayed(const Duration(seconds: 5), () {
      _scrollAds();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget._ads.length,
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: ImageCard(
              poster: widget._ads[index]['poster'],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    List<String> imgs = [];

                    for (int i = 0; i < widget._ads.length; i++) {
                      imgs.add(widget._ads[i]['poster']);
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

  void _scrollAds() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(seconds: 1),
        curve: Curves.ease,
      );
    }

    Future.delayed(const Duration(seconds: 3), () {
      _scrollAds();
      if (_pageController.page == widget._ads.length - 1) {
        _pageController.animateTo(
          0,
          duration: const Duration(seconds: 1),
          curve: Curves.ease,
        );
      }
    });
  }
}
