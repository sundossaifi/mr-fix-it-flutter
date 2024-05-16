import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/search.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class HeaderWithSerachBox extends StatelessWidget {
  const HeaderWithSerachBox({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: defultpadding * 2.5),
      height: size.height * 0.2,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(left: defultpadding, right: defultpadding, bottom: 36 + defultpadding),
            height: size.height * 2 - 27,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
            ),
            child: Row(
              children: <Widget>[
                Text(
                  'Mr.Fix it',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: Image.asset("asset/images/icon-green.png"),
                ),
              ],
            ),
          ),
          const SearchBox(),
        ],
      ),
    );
  }
}
