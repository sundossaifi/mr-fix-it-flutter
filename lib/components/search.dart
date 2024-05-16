import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:mr_fix_it/components/search_workers_delegate.dart';

import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

// ignore: must_be_immutable
class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  List<dynamic> _categories = [];
  List<dynamic> _workingLocations = [];
  List<dynamic> _suggestedWorkers = [];

  @override
  void initState() {
    super.initState();
    _loadSearchData();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: defultpadding),
        margin: const EdgeInsets.symmetric(horizontal: defultpadding),
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(offset: Offset(0, 10), blurRadius: 50, color: primaryColor),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Search",
                  hintStyle: TextStyle(
                    color: primaryColor.withOpacity(0.5),
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: SearchWorkersDelegate(
                      _categories,
                      _workingLocations,
                      _suggestedWorkers,
                    ),
                  );
                },
              ),
            ),
            SvgPicture.asset("asset/images/search.svg"),
          ],
        ),
      ),
    );
  }

  void _loadSearchData() async {
    apiCall(
      context,
      () async {
        _categories = await Api.fetchCategories();

        Map<String, dynamic> response = await Api.fetchData('get-working-locations', <String, String>{});
        _workingLocations = response['workingLocations'].map((workingLocation) => workingLocation['locality']).toList();

        response = await Api.fetchData('get-featured-workers', <String, String>{});
        _suggestedWorkers = response['workers'];

        setState(() {});
      },
    );
  }
}
