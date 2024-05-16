import 'package:flutter/material.dart';

import 'package:mr_fix_it/util/constants.dart';

typedef KeyPressEvent = void Function(String key);

// ignore: must_be_immutable
class FilterList extends StatefulWidget {
  late String _listTitle;
  late List<String> _currentKey;
  late List<dynamic> _keys;
  late KeyPressEvent _keyPressEvent;

  FilterList({
    super.key,
    required String listTitle,
    required List<String> currentKey,
    required List<dynamic> keys,
    required KeyPressEvent keyPressEvent,
  }) {
    _listTitle = listTitle;
    _currentKey = currentKey;
    _keys = keys;
    _keyPressEvent = keyPressEvent;
  }

  @override
  State<FilterList> createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {
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
          child: Text(
            widget._listTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget._keys.length,
              itemBuilder: (BuildContext context, int index) {
                Color color = grayBackgorund;
                Color textColor = whiteBackgroundTextColor;

                for (int i = 0; i < widget._currentKey.length; i++) {
                  if (widget._currentKey[i] == widget._keys[index]) {
                    color = primaryColor;
                    textColor = primaryBackgroundTextColor;
                  }
                }

                return InkWell(
                  child: Container(
                    width: 100,
                    margin: const EdgeInsets.all(4),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: color,
                    ),
                    child: Center(
                      child: Text(
                        widget._keys[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      widget._keyPressEvent(widget._keys[index]);
                    });
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
