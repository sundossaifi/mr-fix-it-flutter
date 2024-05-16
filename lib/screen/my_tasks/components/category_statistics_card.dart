import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class CategoryStatisticCard extends StatefulWidget {
  final categoryStatistics;
  final Color color;
  late double percentage;

  void Function() onTap;

  CategoryStatisticCard({super.key, required this.categoryStatistics, required this.color, required this.onTap}) {
    percentage = categoryStatistics['total'] == 0 ? 0 : (categoryStatistics['totalCompleted'] / categoryStatistics['total']) * 100;
  }

  @override
  State<CategoryStatisticCard> createState() => _CategoryStatisticCardState();
}

class _CategoryStatisticCardState extends State<CategoryStatisticCard> {
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
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
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
                        widget.categoryStatistics['category']['type'],
                        style: const TextStyle(
                          color: primaryBackgroundTextColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Total: ${widget.categoryStatistics['total']}',
                    style: const TextStyle(
                      color: primaryBackgroundTextColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      '${widget.percentage.toStringAsFixed(2)}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: const BoxDecoration(
                      color: grayBackgorund,
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6 * (widget.percentage / 100),
                      height: 20,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
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
