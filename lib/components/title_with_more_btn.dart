import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/title_with_custom_underline.dart';

import 'package:mr_fix_it/util/constants.dart';

class TitleWithMoreButton extends StatelessWidget {
  final String title;
  final VoidCallback? press;

  const TitleWithMoreButton({super.key, required this.title, required this.press});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defultpadding),
      child: Row(
        children: [
          TitleWithCustomUnderline(text: title),
          const Spacer(),
          if (press != null)
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: press,
              child: const Text(
                "more",
                style: TextStyle(color: Colors.white),
              ),
            )
        ],
      ),
    );
  }
}
