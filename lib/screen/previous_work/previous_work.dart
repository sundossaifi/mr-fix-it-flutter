import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/screen/previous_work/components/share_previous_work.dart';
import 'package:mr_fix_it/screen/worker_profile/components/profile_previous_works.dart';
import 'package:mr_fix_it/util/constants.dart';

class PreviousWorkPage extends StatefulWidget {
  final List<dynamic> previousWorks;
  const PreviousWorkPage({
    super.key,
    required this.previousWorks,
  });

  @override
  State<PreviousWorkPage> createState() => _PreviousWorkPagetState();
}

class _PreviousWorkPagetState extends State<PreviousWorkPage> {
  @override
  void initState() {
    super.initState();
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ProfilePreviousWorks(
            isOwner: true,
            height: MediaQuery.of(context).size.height,
            previousWorks: widget.previousWorks,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return SharePreviousWork(
                  previousWorks: widget.previousWorks,
                );
              },
            ).then(
              (value) {
                setState(() {});
              },
            );
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
}
