import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/study_details_screen/study_details_screen.dart';
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

Widget _buildStudyDetailsScreen() {
  final String newGroupId = Get.arguments;
  return StudyDetailsScreen(
    newGroupId: newGroupId,
  );
}

Widget _buildHome() {
  final bool isLoggedin = Get.arguments ?? false;
  return Home(isloggedin: isLoggedin);
}
