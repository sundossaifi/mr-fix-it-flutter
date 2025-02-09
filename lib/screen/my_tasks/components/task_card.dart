import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/screen/task_page/task_page.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/constants.dart';

// ignore: must_be_immutable
class TaskCard extends StatefulWidget {
  final task;
  final Function update;
  void Function() deletePress;
  void Function() ratePress;

  TaskCard({super.key, required this.task, required this.deletePress, required this.ratePress, required this.update});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    _getToken();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskPage(
                task: widget.task,
                isClient: true,
                client: widget.task['client'],
                isAssignedWorker: false,
              ),
            ),
          ).then((value) {
            widget.update();
            setState(() {});
          });
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor,
                              width: 3.0,
                            ),
                          ),
                          child: ClipOval(
                            child: Material(
                              color: Colors.transparent,
                              child: _accessToken != null
                                  ? Image.network(
                                      '${widget.task['taskImgs'][0]['img']}',
                                      //headers: {"Authorization": "Bearer $_accessToken}"},
                                      fit: BoxFit.cover,
                                    )
                                  : const CircularProgressIndicator(color: primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              child: Text(
                                widget.task['title'],
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.task['category']['type'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              widget.task['status'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.task['startDate'] != null
                                  ? widget.task['startDate'].toString().substring(0, widget.task['startDate'].toString().indexOf("T"))
                                  : '-',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (widget.task['status'].toString().toLowerCase() == 'requested' ||
                        widget.task['status'].toString().toLowerCase() == 'posted')
                      IconButton(
                        onPressed: widget.deletePress,
                        icon: const Icon(
                          Icons.delete_sweep,
                          size: 35,
                          color: Colors.redAccent,
                        ),
                      ),
                    if (widget.task['status'].toString().toLowerCase() == 'completed' && widget.task['feedback'] == null)
                      SizedBox(
                        width: 80,
                        child: ButtonWidget(
                          btnText: 'Rate',
                          backgroundColor: primaryColor,
                          onClick: widget.ratePress,
                        ),
                      ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _getToken() async {
    String? token = await Api.getToken();

    setState(() {
      _accessToken = token;
    });
  }
}
