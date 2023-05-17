import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_cache/app_cache.dart';
import '../home_screen/home.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => Home(isloggedin: AppCache.getCachedisLoggedin()));
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '랭킹',
          ),
        ),
      ),
      body: Container(),
    );
  }
}
