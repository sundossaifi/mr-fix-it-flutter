import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/title_with_custom_underline.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class ProfileWorkingLocations extends StatefulWidget {
  late List<dynamic> _workingLocations;

  ProfileWorkingLocations({super.key, required List<dynamic> workingLocations}) {
    _workingLocations = workingLocations;
  }

  @override
  State<ProfileWorkingLocations> createState() => _ProfileWorkingLocationsState();
}

class _ProfileWorkingLocationsState extends State<ProfileWorkingLocations> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          child: TitleWithCustomUnderline(
            text: 'Working Locations',
            fontSize: 24,
            height: 24,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget._workingLocations.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      widget._workingLocations[index]['locality'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: backgroundColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
