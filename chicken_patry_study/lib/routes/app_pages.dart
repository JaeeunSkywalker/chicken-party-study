//app_pages.dart: 앱에서 사용할 페이지 경로를 상수로 정의합니다.
//GetMaterialApp 위젯의 routes 속성에 이 상수를 사용합니다.

import 'package:get/get.dart';
import '../views/home_screen/home.dart';
import '../views/auth_screen/signin_screen/signin_screen.dart';
import '../views/study_details/study_details.dart';
import '../views/login_screen/login_screen.dart';

part '../routes/app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.HOME, page: () => const Home()),
    GetPage(name: AppRoutes.SIGNIN, page: () => const SigninScreen()),
    GetPage(name: AppRoutes.STUDY_DETAILS, page: () => const StudyDetails()),
    GetPage(name: AppRoutes.LOGIN, page: () => const LoginScreen()),
  ];
}
