import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/worker_card.dart';

import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';

// ignore: must_be_immutable
class WorkerListView extends StatefulWidget {
  late List<dynamic> _workers;

  WorkerListView({super.key, required List<dynamic> workers}) {
    _workers = workers;
  }

  @override
  State<WorkerListView> createState() => _WorkerListViewtState();
}

class _WorkerListViewtState extends State<WorkerListView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (widget._workers.length > 5) ? 5 : widget._workers.length,
        itemBuilder: (BuildContext context, int index) {
          return WorkerCard(
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
          );
        },
      ),
    );
  }
}
