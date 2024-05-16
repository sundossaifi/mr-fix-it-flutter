import 'package:flutter/material.dart';

import 'package:mr_fix_it/components/btn_widget.dart';
import 'package:mr_fix_it/components/filter_list.dart';
import 'package:mr_fix_it/components/worker_search_card.dart';

import 'package:mr_fix_it/screen/worker_profile/worker_profile_page.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/constants.dart';

class SearchWorkersDelegate extends SearchDelegate {
  List<String> _categoryKeys = [];
  List<String> _workingLocationKeys = [];

  List<dynamic> _categories = [];
  List<dynamic> _workingLocations = [];
  List<dynamic> _suggestedWorkers = [];
  List<dynamic> _workersSearchResult = [];

  SearchWorkersDelegate(List<dynamic> categories, List<dynamic> workingLocations, List<dynamic> suggestedWorkers) {
    _categories = categories;
    _workingLocations = workingLocations;
    _suggestedWorkers = suggestedWorkers;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        color: primaryColor,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: primaryBackgroundTextColor,
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return _filterDialog(dialogContext);
            },
          );
        },
        icon: const Icon(Icons.filter_alt),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'search',
          {
            'key': query,
            'categories': _categoryKeys,
            'cities': _workingLocationKeys,
          },
        );

        _workersSearchResult = response['body']['workers'];
        (context as Element).markNeedsBuild();
      },
    );

    return _buildWorkersCards(_workersSearchResult, _workersSearchResult.length);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildWorkersCards(
      _suggestedWorkers,
      _suggestedWorkers.length > 5 ? 5 : _suggestedWorkers.length,
    );
  }

  Widget _buildWorkersCards(List<dynamic> workers, int lengthLimit) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: lengthLimit,
      itemBuilder: (BuildContext context, int index) {
        return WorkerSearchCard(
          image: workers[index]['img'],
          name: workers[index]['firstName'] + ' ' + workers[index]['lastName'],
          city: workers[index]['city'],
          category: workers[index]['category']['type'],
          rate: workers[index]['rate'],
          press: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerProfile(worker: workers[index]),
                ),
              );
            }
          },
        );
      },
    );
  }

  Widget _filterDialog(BuildContext dialogContext) {
    return Center(
      child: Container(
        width: 350,
        height: 320,
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: primaryBackgroundTextColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            FilterList(
              listTitle: 'Categories',
              currentKey: _categoryKeys,
              keys: _categories,
              keyPressEvent: _categoryPressEvent,
            ),
            const SizedBox(
              height: 15,
            ),
            FilterList(
              listTitle: 'Working Locations',
              currentKey: _workingLocationKeys,
              keys: _workingLocations,
              keyPressEvent: _workingLocationPressEvent,
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  margin: const EdgeInsets.all(10),
                  child: ButtonWidget(
                    btnText: 'Reset',
                    backgroundColor: grayBackgorund,
                    textColor: whiteBackgroundTextColor,
                    onClick: () {
                      _categoryKeys = [];
                      _workingLocationKeys = [];
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
                Container(
                  width: 100,
                  margin: const EdgeInsets.all(10),
                  child: ButtonWidget(
                    btnText: 'Done',
                    backgroundColor: primaryColor,
                    onClick: () {
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _categoryPressEvent(String category) {
    if (_categoryKeys.contains(category)) {
      _categoryKeys.removeAt(_categoryKeys.indexOf(category));
      return;
    }

    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i] == category) {
        _categoryKeys.add(_categories[i]);
      }
    }
  }

  void _workingLocationPressEvent(String workingLocation) {
    if (_workingLocationKeys.contains(workingLocation)) {
      _workingLocationKeys.removeAt(_workingLocationKeys.indexOf(workingLocation));
      return;
    }

    for (int i = 0; i < _workingLocations.length; i++) {
      if (_workingLocations[i] == workingLocation) {
        _workingLocationKeys.add(_workingLocations[i]);
      }
    }
  }
}
