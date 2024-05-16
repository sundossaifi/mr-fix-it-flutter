import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final String? token;
  final int initialIndex;

  const FullScreenImageGallery({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
    required this.token,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  int currentIndex = 0;
  PageController? pageController;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
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
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        '${widget.imageUrls[currentIndex]}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                PhotoViewGallery.builder(
                  itemCount: widget.imageUrls.length,
                  builder: (context, index) {
                    return PhotoViewGalleryPageOptions(
                      imageProvider: NetworkImage(
                        '${widget.imageUrls[index]}',
                        // headers: {
                        //   "Authorization": "Bearer ${widget.token}",
                        // },
                      ),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    );
                  },
                  scrollPhysics: const AlwaysScrollableScrollPhysics(),
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  pageController: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                ),
              ],
            ),
          ),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    setState(
                      () {
                        pageController?.animateToPage(
                          index,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutSine,
                        );
                        currentIndex = index;
                      },
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: index == currentIndex ? Colors.white : Colors.transparent,
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(
                          '${widget.imageUrls[index]}',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
