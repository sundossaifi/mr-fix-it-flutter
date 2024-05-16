import 'package:flutter/material.dart';

import 'package:mr_fix_it/screen/more_workers/more_workers_page.dart';
import 'package:mr_fix_it/screen/client_home/components/ads_list_view.dart';
import 'package:mr_fix_it/screen/client_home/components/header_with_searchbox.dart';

import 'package:mr_fix_it/util/api/api.dart';
import 'package:mr_fix_it/util/api/api_call_template.dart';

import 'package:mr_fix_it/components/worker_list_view.dart';
import 'package:mr_fix_it/components/title_with_more_btn.dart';

import 'package:mr_fix_it/util/constants.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _BodyState();
}

class _BodyState extends State<HomeBody> {
  List<dynamic> _ads = [];
  List<dynamic> _featuredWorkers = [];
  List<dynamic> _topRatedWorkers = [];
  List<dynamic> _newcomers = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _getHomePageData(false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

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
              HeaderWithSerachBox(
                size: size,
              ),
              const TitleWithMoreButton(title: "Ads", press: null),
              AdsListView(
                ads: _ads,
              ),
              const SizedBox(
                height: defultpadding,
              ),
              TitleWithMoreButton(
                title: "Featured",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreWorkersPage(
                        workers: _featuredWorkers,
                        title: "Featured",
                      ),
                    ),
                  );
                },
              ),
              WorkerListView(
                workers: _featuredWorkers,
              ),
              TitleWithMoreButton(
                title: "Top Rated",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreWorkersPage(
                        workers: _topRatedWorkers,
                        title: "Top Rated",
                      ),
                    ),
                  );
                },
              ),
              WorkerListView(
                workers: _topRatedWorkers,
              ),
              TitleWithMoreButton(
                title: "Newcomers",
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MoreWorkersPage(
                        workers: _newcomers,
                        title: "Newcomers",
                      ),
                    ),
                  );
                },
              ),
              WorkerListView(
                workers: _newcomers,
              ),
            ],
          ),
        ),
        onRefresh: () {
          return Future.delayed(
            const Duration(seconds: 2),
            () {
              _getHomePageData(true);
            },
          );
        },
      ),
    );
  }

  void _getHomePageData(bool refresh) async {
    apiCall(
      context,
      () async {
        Map<String, dynamic> response = await Api.fetchData('get-workers-ads', <String, String>{});
        _ads = response['ads'];

        response = await Api.fetchData('get-featured-workers', <String, String>{});
        _featuredWorkers = response['workers'];

        response = await Api.fetchData('get-top-rated-workers', <String, String>{});
        _topRatedWorkers = response['workers'];

        response = await Api.fetchData('get-newcomers', <String, String>{});
        _newcomers = response['workers'];

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
}
