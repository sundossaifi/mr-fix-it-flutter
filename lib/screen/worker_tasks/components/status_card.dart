import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class StatusCard extends StatefulWidget {
  final type;
  final Color color;

  void Function() onTap;

  StatusCard({super.key, required this.type, required this.color, required this.onTap});

  @override
  State<StatusCard> createState() => _StatusCardState();
}

class _StatusCardState extends State<StatusCard> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        margin: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: grayBackgorund,
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: 145,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.handyman,
                        size: 35,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.type['type'],
                        style: const TextStyle(
                          color: primaryBackgroundTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total: ${widget.type['total']}',
                    style: const TextStyle(
                      color: primaryBackgroundTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
