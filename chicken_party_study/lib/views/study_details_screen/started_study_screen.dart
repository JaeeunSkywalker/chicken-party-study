import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_screen/home.dart';

class StartedStudyScreen extends StatefulWidget {
  const StartedStudyScreen({super.key});

  @override
  State<StartedStudyScreen> createState() => _StartedStudyScreenState();
}

class _StartedStudyScreenState extends State<StartedStudyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(const Home(isloggedin: true));
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '스터디 진행 사항 페이지',
          ),
        ),
      ),
    );
  }
}
