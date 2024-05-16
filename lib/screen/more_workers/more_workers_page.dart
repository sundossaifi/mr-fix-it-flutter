import 'package:flutter/material.dart';

import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';

import 'package:mr_fix_it/components/worker_card.dart';
import 'package:mr_fix_it/components/app_bar.dart';
import 'package:mr_fix_it/components/title_with_more_btn.dart';

import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class MoreWorkersPage extends StatefulWidget {
  late String _title;
  late List<dynamic> _workers;

  MoreWorkersPage({super.key, required List<dynamic> workers, required String title}) {
    _title = title;
    _workers = workers;
  }

  @override
  State<MoreWorkersPage> createState() => _MoreWorkersPageState();
}

class _MoreWorkersPageState extends State<MoreWorkersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: mainAppBar(
        0,
        const BackButton(),
        null,
        primaryColor,
        transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              child: TitleWithMoreButton(
                title: widget._title,
                press: null,
              ),
            ),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 360,
                ),
                padding: const EdgeInsets.all(8.0),
                itemCount: widget._workers.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: WorkerCard(
                      image: widget._workers[index]['img'],
                      name: widget._workers[index]['firstName'] + ' ' + widget._workers[index]['lastName'],
                      city: widget._workers[index]['city'],
                      category: widget._workers[index]['category']['type'],
                      rate: widget._workers[index]['rate'],
                      press: () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WorkerProfile(worker: widget._workers[index]),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
