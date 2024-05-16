import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/form_text_input.dart';
import 'package:mr_fix_it/screen/worker_discover_tasks/components/post_type_card.dart';
import 'package:mr_fix_it/screen/worker_discover_tasks/components/task_card.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/response_state.dart';

class WorkerDiscoverTasks extends StatefulWidget {
  final worker;
  const WorkerDiscoverTasks({super.key, this.worker});

  @override
  State<WorkerDiscoverTasks> createState() => _WorkerDiscoverTasksState();
}

class _WorkerDiscoverTasksState extends State<WorkerDiscoverTasks> {
  String _searchKey = '';

  List<dynamic> _tasks = [];
  List<dynamic> _workingLocations = [];
  List<dynamic> _currentDisplayedTasks = [];

  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;

  double? _price = -1;
  final GlobalKey<FormState> _formState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getTasks(false);
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
                            'Type',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 170,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              PostCardType(
                                type: {
                                  'type': 'ALL',
                                  'total': _tasks.length,
                                },
                                color: const Color(0xff118ab2),
                                onTap: () {
                                  setState(() {
                                    _currentDisplayedTasks = _tasks;
                                  });
                                },
                              ),
                              PostCardType(
                                type: {
                                  'type': 'POST',
                                  'total': _tasks.where((task) => task['type'] == 'POST').toList().length,
                                },
                                color: const Color(0xffa5a58d),
                                onTap: () {
                                  setState(() {
                                    _currentDisplayedTasks = _tasks.where((task) => task['type'] == 'POST').toList();
                                  });
                                },
                              ),
                              PostCardType(
                                type: {
                                  'type': 'TENDER',
                                  'total': _tasks.where((task) => task['type'] == 'TENDER').toList().length,
                                },
                                color: const Color(0xff118ab2),
                                onTap: () {
                                  setState(() {
                                    _currentDisplayedTasks = _tasks.where((task) => task['type'] == 'TENDER').toList();
                                  });
                                },
                              ),
                            ],
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
                        'Tasks',
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
                                          offerPress: () {
                                            if (tasks[index]['type'] == 'POST') {
                                              showAwsomeDialog(
                                                context: context,
                                                dialogType: DialogType.question,
                                                title: 'Confirm',
                                                description: 'Are you sure you want offer this?',
                                                btnOkOnPress: () {
                                                  _offerTask(tasks[index]['id'], tasks[index]['price']);
                                                },
                                                btnCancelOnPress: () {},
                                                onDismissCallback: (value) {},
                                              );
                                            } else if (tasks[index]['type'] == 'TENDER') {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    title: const Center(
                                                      child: Text(
                                                        'Price Offer',
                                                        style: TextStyle(
                                                          fontSize: 30,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    content: SizedBox(
                                                      height: 160,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Form(
                                                            key: _formState,
                                                            child: formTextInput(
                                                              label: 'Price',
                                                              hint: "Price",
                                                              icon: Icons.price_change,
                                                              keyboardType: TextInputType.number,
                                                              validator: (value) {
                                                                if (value!.trim().isEmpty) {
                                                                  return 'Price is empty';
                                                                }

                                                                return null;
                                                              },
                                                              onSaved: (value) {
                                                                _price = double.tryParse(value!);
                                                              },
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 25,
                                                          ),
                                                          SizedBox(
                                                            width: 200,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                SizedBox(
                                                                  width: 80,
                                                                  child: ButtonWidget(
                                                                    btnText: 'Cancel',
                                                                    backgroundColor: Colors.red,
                                                                    onClick: () {
                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 80,
                                                                  child: ButtonWidget(
                                                                    btnText: 'Offer',
                                                                    backgroundColor: primaryColor,
                                                                    onClick: () {
                                                                      if (!_formState.currentState!.validate()) {
                                                                        return;
                                                                      }

                                                                      _formState.currentState!.save();
                                                                      _offerTask(tasks[index]['id'], _price!);

                                                                      Navigator.of(context).pop();
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }
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
          ],
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _getTasks(true);
            },
          );
        },
      ),
    );
  }

  void _getTasks(bool refresh) {
    apiCall(
      context,
      () async {
        final response = await Api.fetchData('get-posted-tasks', {});
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

  void _offerTask(int id, double price) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'offer-task',
          {
            'taskID': id.toString(),
            'price': price.toString(),
          },
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Your offer submitted successfully',
              btnOkOnPress: () {},
            );
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
  }
}
