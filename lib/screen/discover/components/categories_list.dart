import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

typedef CategoryPressEvent = void Function(String category);

// ignore: must_be_immutable
class CategoriesList extends StatefulWidget {
  late List<dynamic> _categories;
  late CategoryPressEvent _categoryPressEvent;

  CategoriesList({
    super.key,
    required List<dynamic> categories,
    required CategoryPressEvent categoryPressEvent,
  }) {
    _categories = categories;
    _categoryPressEvent = categoryPressEvent;
  }

  @override
  State<CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<CategoriesList> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 13),
          child: const Text(
            'Categories',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget._categories.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        widget._categories[index],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: backgroundColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    widget._categoryPressEvent(widget._categories[index]);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
