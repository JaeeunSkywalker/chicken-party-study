import 'package:chicken_party_study/views/home_screen/home.dart';
import 'package:chicken_party_study/views/search_screen/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/study_screen/study_details_screen/study_details_screen.dart';
import 'app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.HOME, page: () => _buildHome()),
    GetPage(
        name: AppRoutes.STUDY_DETAILS, page: () => _buildStudyDetailsScreen()),

    //GetPage(name: AppRoutes.SETTINGS, page: () => SettingsScreen()),
    //GetPage(name: AppRoutes.PROFILE, page: () => ProfileScreen()),
  ];
}

//실 사용 시에는 Study 값들을 적절하게 바꾸면 됨
Widget _buildStudyDetailsScreen() {
  final String newGroupId = Get.arguments;
  final study = Study(
    groupName: 'Study Group',
    groupDescription: 'This is a study group.',
    selectedTags: ['tag1', 'tag2'],
    studyGoal: 'To learn new things',
    studyLeader: 'John Doe',
    newGroupId: newGroupId,
  );
  return StudyDetailsScreen(
    newGroupId: newGroupId,
    study: study,
  );
}

Widget _buildHome() {
  final bool isLoggedin = Get.arguments ?? false;
  return Home(isloggedin: isLoggedin);
}
