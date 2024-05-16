import 'package:flutter/material.dart';

import 'package:mr_fix_it/screen/discover/components/categories_list.dart';
import 'package:mr_fix_it/screen/more_workers/more_workers_page.dart';

import 'package:mr_fix_it/components/search.dart';
import 'package:mr_fix_it/components/worker_list_view.dart';
import 'package:mr_fix_it/components/title_with_more_btn.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';
import 'package:mr_fix_it/util/constants.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List<dynamic> _categories = [];
  List<dynamic> _workersGroups = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getDiscoverPageData(false);
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
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 30,
              ),
              const SizedBox(
                height: 70,
                child: Stack(
                  children: <Widget>[
                    SearchBox(),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              CategoriesList(
                categories: _categories,
                categoryPressEvent: _categoryPressEvent,
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: (_workersGroups.length > 5) ? 5 : _workersGroups.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      TitleWithMoreButton(
                        title: _workersGroups[index]['category']['type'],
                        press: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreWorkersPage(
                                workers: _workersGroups[index]['workers'],
                                title: _workersGroups[index]['category']['type'],
                              ),
                            ),
                          );
                        },
                      ),
                      WorkerListView(
                        workers: _workersGroups[index]['workers'],
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _getDiscoverPageData(true);
            },
          );
        },
      ),
    );
  }

  void _getDiscoverPageData(bool refresh) async {
    apiCall(
      context,
      () async {
        _categories = await Api.fetchCategories();

        Map<String, dynamic> response = await Api.fetchData('get-workers-grouped-by-categories', <String, String>{});
        _workersGroups = response['workersGroups'];

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

  void _categoryPressEvent(String category) {
    setState(() {
      dynamic workersGroup;

      for (int i = 0; i < _workersGroups.length; i++) {
        if (_workersGroups[i]['category']['type'] == category) {
          workersGroup = _workersGroups.elementAt(i);
          _workersGroups.removeAt(i);
          break;
        }
      }

      _workersGroups.insert(0, workersGroup);
    });
  }
}
