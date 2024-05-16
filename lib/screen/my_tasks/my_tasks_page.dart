import 'package:flutter/material.dart';
import 'package:bottom_drawer/bottom_drawer.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:mr_fix_it/screen/my_tasks/components/task_card.dart';
import 'package:mr_fix_it/screen/my_tasks/components/category_statistics_card.dart';
import 'package:mr_fix_it/screen/my_tasks/components/task_rate_drawer.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/response_state.dart';

class MyTasksPage extends StatefulWidget {
  const MyTasksPage({super.key});

  @override
  State<MyTasksPage> createState() => _MyTasksPageState();
}

class _MyTasksPageState extends State<MyTasksPage> {
  String _searchKey = '';

  List<dynamic> _tasks = [];
  List<dynamic> _categoryStatistics = [];
  List<dynamic> _currentDisplayedTasks = [];

  final List<String> _taskStatus = ['ALL', 'REQUESTED', 'ASSIGNED', 'POSTED', 'DECLINED', 'CANCELED', 'COMPLETED'];

  Map<String, dynamic>? taskToRate;

  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();
  final BottomDrawerController _bottomDrawerController = BottomDrawerController();

  @override
  void initState() {
    super.initState();
    _getMyTasksData(false);
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
                            'Categories',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 230,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categoryStatistics.length,
                            itemBuilder: (BuildContext context, int index) {
                              return CategoryStatisticCard(
                                categoryStatistics: _categoryStatistics[index],
                                color: ((index + 1) % 2) == 0 ? const Color(0xffa5a58d) : const Color(0xff118ab2),
                                onTap: () {
                                  setState(() {
                                    _currentDisplayedTasks = _categoryStatistics[index]['category']['type'] == 'ALL'
                                        ? _tasks
                                        : _tasks
                                            .where((task) => task['category']['type'] == _categoryStatistics[index]['category']['type'])
                                            .toList();
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
                        length: _taskStatus.length,
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
                                  _taskStatus.length,
                                  (index) => Tab(
                                    child: Text(
                                      _taskStatus[index],
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
                                  _taskStatus.length,
                                  (i) {
                                    final tasks = _taskStatus[i] == 'ALL'
                                        ? List.from(_currentDisplayedTasks)
                                        : _currentDisplayedTasks.where((task) => task['status'] == _taskStatus[i]).toList();

                                    return ListView.builder(
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: tasks.length,
                                      itemBuilder: (BuildContext context, int index) {
                                        return TaskCard(
                                          task: tasks[index],
                                          deletePress: () {
                                            _deleteTask(tasks[index]);
                                          },
                                          ratePress: () {
                                            setState(() {
                                              taskToRate = tasks[index];
                                              _bottomDrawerController.open();
                                            });
                                          },
                                          update: () {
                                            _getMyTasksData(false);
                                            setState(() {});
                                          },
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
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: MediaQuery.of(context).size.height * 0.5,
              child: TaskRateDrawer(
                bottomDrawerController: _bottomDrawerController,
                task: taskToRate,
                updateTaskRate: (feedback) {
                  int index = _tasks.indexWhere((task) => task['id'] == feedback['taskID']);

                  if (index != -1) {
                    setState(() {
                      _tasks[index]['feedback'] = feedback;
                    });
                  }
                },
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
        Map<String, dynamic> response = await Api.fetchData('get-client-tasks', <String, String>{});
        _tasks = response['tasks'];
        _currentDisplayedTasks = List.from(_tasks);

        response = await Api.fetchData('get-client-tasks-category-statistics', <String, String>{});
        _categoryStatistics = response['categoryStatistics'];

        num total = 0;
        num totalCompleted = 0;

        for (int i = 0; i < _categoryStatistics.length; i++) {
          total += _categoryStatistics[i]['total'];
          totalCompleted += _categoryStatistics[i]['totalCompleted'];
        }

        _categoryStatistics.insert(
          0,
          {
            'category': {'type': 'ALL'},
            'total': total,
            'totalCompleted': totalCompleted
          },
        );

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

  void _deleteTask(final taskToDelete) async {
    int id = taskToDelete['id'];

    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'delete-client-task',
          {'id': id},
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.error) {
            showAwsomeDialog(
              context: context,
              dialogType: DialogType.error,
              title: 'Failed',
              description: 'Something went wrong, please try again later',
              btnOkOnPress: () {},
            );
          } else {
            setState(() {
              _tasks.removeWhere((task) => task['id'] == taskToDelete['id']);
              _currentDisplayedTasks.removeWhere((task) => task['id'] == taskToDelete['id']);
            });
          }
        }
      },
    );
  }
}
