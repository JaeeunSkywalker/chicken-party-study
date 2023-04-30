import 'package:get/get.dart';

class AppController extends GetxController {
  void goToHome() {
    Get.offNamed('/home');
  }

  void goToSignIn() {
    Get.toNamed('/signin');
  }

  void goToStudyDetails() {
    Get.toNamed('/study_details');
  }

  void goToLogin() {
    Get.toNamed('/login');
  }
}
