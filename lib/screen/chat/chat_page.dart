import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:mr_fix_it/screen/chat/components/chat_card.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/util/dialog.dart';
import 'package:mr_fix_it/util/constants.dart';
import 'package:mr_fix_it/util/response_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _searchKey = '';

  List<dynamic> _chats = [];
  List<dynamic> _currentDisplayedChats = [];

  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChats(false);
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
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
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
                                      _currentDisplayedChats = List.from(_chats);
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
                            _currentDisplayedChats = _chats
                                .where((chat) => ('${chat['receiver']['firstName']} ${chat['receiver']['lastName']}').contains(value))
                                .toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _currentDisplayedChats.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Dismissible(
                      key: Key(index.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: primaryColor,
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        padding: const EdgeInsets.all(20),
                        child: const Icon(
                          Icons.delete,
                          size: 25,
                          color: primaryBackgroundTextColor,
                        ),
                      ),
                      onDismissed: (direction) {
                        if (direction == DismissDirection.endToStart) {
                          _deleteChat(_currentDisplayedChats[index]['chatID']);

                          _chats.removeWhere((chat) => chat['chatID'] == _currentDisplayedChats[index]['chatID']);
                          _currentDisplayedChats.removeAt(index);

                          setState(() {});
                        }
                      },
                      child: ChatCard(
                        chat: _currentDisplayedChats[index],
                        onpop: () {
                          _loadChats(false);
                          setState(() {});
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _loadChats(true);
            },
          );
        },
      ),
    );
  }

  void _loadChats(bool refresh) async {
    apiCall(
      context,
      () async {
        Map<String, dynamic> response = await Api.fetchData('get-chats', <String, String>{});
        _chats = response['chats'];
        _currentDisplayedChats = List.from(_chats);

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

  void _deleteChat(int chatID) async {
    apiCall(
      context,
      () async {
        final response = await Api.postData(
          'delete-chat',
          {
            'chatID': chatID.toString(),
          },
        );

        if (context.mounted) {
          if (response['responseState'] == ResponseState.success) {
            await showAwsomeDialog(
              context: context,
              dialogType: DialogType.info,
              title: 'Success',
              description: 'Chat deleted successfully',
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

            _loadChats(false);
            setState(() {});
          }
        }
      },
    );
  }
}
