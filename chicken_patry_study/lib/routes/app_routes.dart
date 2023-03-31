//Get.toNamed 메서드 등에서 사용할 페이지 경로 문자열을 상수로 정의합니다.
//이 파일에서 정의한 상수를 app_pages.dart에서 사용할 수 있습니다.

// ignore_for_file: constant_identifier_names

part of 'app_pages.dart';

abstract class AppRoutes {
  static const HOME = '/';
  static const SIGNIN = '/signin';
  static const STUDY_DETAILS = '/study-details';
  static const LOGIN = '/login';
}
