import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/screen/worker_tasks/components/task_card.dart';
import 'package:mr_fix_it/screen/worker_tasks/components/status_card.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class WorkerTasks extends StatefulWidget {
  final worker;

  const WorkerTasks({super.key, required this.worker});

  @override
  State<WorkerTasks> createState() => _WorkerTasksState();
}

class _WorkerTasksState extends State<WorkerTasks> {
  String _searchKey = '';

  List<dynamic> _tasks = [];
  List<dynamic> _workingLocations = [];
  List<dynamic> _currentDisplayedTasks = [];

  final List<String> _taskStatus = ['ALL', 'REQUESTED', 'ASSIGNED', 'DECLINED', 'CANCELED', 'COMPLETED'];

  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getMyTasksData(false);
    _workingLocations = List.of(widget.worker['workingLocations']);
    _workingLocations.insert(0, {'locality': 'ALL'});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    return Scaffold(
      body: RefreshIndicator(
        color: primaryColor,
        backgroundColor: backgroundColor,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10,
                  left: 10,
                  right: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(
                                    Icons.search,
                                    color: whiteBackgroundTextColor,
                                  ),
                                  suffixIcon: _searchKey.trim().isEmpty
                                      ? null
                                      : IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _searchKey = '';
                                              _searchController.clear();
                                              _currentDisplayedTasks = List.from(_tasks);
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.clear,
                                            color: whiteBackgroundTextColor,
                                          ),
                                        ),
                                  hintText: "Search",
                                  hintStyle: TextStyle(
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: primaryColor,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1,
                                      color: primaryColor,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(30),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _searchKey = value;
                                    _currentDisplayedTasks = _tasks.where((task) => task['title'].toString().contains(value)).toList();
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.sort,
                                  size: 25,
                                  color: primaryBackgroundTextColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _currentDisplayedTasks = _currentDisplayedTasks.reversed.toList();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: const Text(
                            'Status',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 170,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _taskStatus.length,
                            itemBuilder: (BuildContext context, int index) {
                              return StatusCard(
                                type: {
                                  'type': _taskStatus[index],
                                  'total': _taskStatus[index] == 'ALL'
                                      ? _tasks.length
                                      : _tasks.where((task) => task['status'] == _taskStatus[index]).toList().length,
                                },
                                color: ((index + 1) % 2) == 0 ? const Color(0xffa5a58d) : const Color(0xff118ab2),
                                onTap: () {
                                  setState(() {
                                    _currentDisplayedTasks = _taskStatus[index] == 'ALL'
                                        ? _tasks
                                        : _tasks.where((task) => task['status'] == _taskStatus[index]).toList();
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: const Text(
                        'My Tasks',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration: const BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: grayBackgorund,
                            spreadRadius: 3,
                            blurRadius: 7,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: DefaultTabController(
                        length: _workingLocations.length,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                left: defultpadding,
                                right: defultpadding,
                              ),
                              child: TabBar(
                                isScrollable: true,
                                indicatorColor: whiteBackgroundTextColor,
                                tabs: List.generate(
                                  _workingLocations.length,
                                  (index) => Tab(
                                    child: Text(
                                      _workingLocations[index]['locality'],
                                      style: const TextStyle(
                                        color: whiteBackgroundTextColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: TabBarView(
                                children: List.generate(
                                  _workingLocations.length,
                                  (i) {
                                    final tasks = _workingLocations[i]['locality'] == 'ALL'
                                        ? List.from(_currentDisplayedTasks)
                                        : _currentDisplayedTasks
                                            .where((task) => task['locality'] == _workingLocations[i]['locality'])
                                            .toList();

                                    return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: tasks.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return TaskCard(
                                          task: tasks[index],
                                          update: () {
                                            _getMyTasksData(false);
                                            setState(() {});
                                          },
                                          actionWidget: tasks[index]['status'] == 'REQUESTED'
                                              ? Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: whiteBackgroundTextColor),
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: primaryColor,
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          _updateRequested(tasks[index]['id'], true);
                                                        },
                                                        icon: const Icon(
                                                          Icons.check,
                                                          color: primaryBackgroundTextColor,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: whiteBackgroundTextColor),
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: Colors.redAccent,
                                                      ),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          _updateRequested(tasks[index]['id'], false);
                                                        },
                                                        icon: const Icon(
                                                          Icons.close,
                                                          color: primaryBackgroundTextColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : tasks[index]['status'] == 'ASSIGNED'
                                                  ? SizedBox(
                                                      width: 80,
                                                      child: ButtonWidget(
                                                        btnText: 'Done',
                                                        backgroundColor: primaryColor,
                                                        onClick: () {
                                                          _completeTask(tasks[index]['id']);
                                                        },
                                                      ),
                                                    )
                                                  : const SizedBox(),
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _getMyTasksData(true);
            },
          );
        },
      ),
    );
  }

  void _getMyTasksData(bool refresh) async {
    apiCall(
      context,
      () async {
        Map<String, dynamic> response = await Api.fetchData('get-worker-tasks', <String, String>{});
        _tasks = response['tasks'];
        _currentDisplayedTasks = List.from(_tasks);

        setState(() {
          _loading = false;
        });

        if (refresh && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Refreshed'),
            ),
          );
        }
      },
    );
  }

  void _updateRequested(int id, bool state) {
    String stateMessage = state ? 'accept' : 'decline';

    showAwsomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: 'Confirm',
      description: 'Are you sure you want to $stateMessage this?',
      btnOkOnPress: () {
        apiCall(
          context,
          () async {
            final response = await Api.postData(
              'set-requested-task-status',
              {
                'taskID': id.toString(),
                'state': state.toString(),
              },
            );

            if (context.mounted) {
              if (response['responseState'] == ResponseState.success) {
                showAwsomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  title: 'Success',
                  description: 'Task ${stateMessage}ed successfully',
                  btnOkOnPress: () {},
                );

                int index = _tasks.indexWhere((task) => task['id'] == id);
                _tasks[index] = response['body']['task'];

                index = _currentDisplayedTasks.indexWhere((task) => task['id'] == id);
                _currentDisplayedTasks[index] = response['body']['task'];
                setState(() {});
              } else {
                showAwsomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: 'Failed',
                  description: 'Something went wrong, please try again later',
                  btnOkOnPress: () {},
                );
              }
            }
          },
        );
      },
      btnCancelOnPress: () {},
      onDismissCallback: (value) {},
    );
  }

  void _completeTask(int id) {
    showAwsomeDialog(
      context: context,
      dialogType: DialogType.question,
      title: 'Confirm',
      description: 'Are you sure you want to update this?',
      btnOkOnPress: () {
        apiCall(
          context,
          () async {
            final response = await Api.postData(
              'set-task-completed/$id',
              {},
            );

            if (context.mounted) {
              if (response['responseState'] == ResponseState.success) {
                showAwsomeDialog(
                  context: context,
                  dialogType: DialogType.info,
                  title: 'Success',
                  description: 'Task updated successfully',
                  btnOkOnPress: () {},
                );

                int index = _tasks.indexWhere((task) => task['id'] == id);
                _tasks[index] = response['body']['task'];

                index = _currentDisplayedTasks.indexWhere((task) => task['id'] == id);
                _currentDisplayedTasks[index] = response['body']['task'];
                setState(() {});
              } else {
                showAwsomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  title: 'Failed',
                  description: 'Something went wrong, please try again later',
                  btnOkOnPress: () {},
                );
              }
            }
          },
        );
      },
      btnCancelOnPress: () {},
      onDismissCallback: (value) {},
    );
  }
}
