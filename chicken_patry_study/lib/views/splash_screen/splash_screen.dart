import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../home_screen/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //스플래시 스크린 뜨고 3초 뒤에 Home으로 들어감
  changeScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.to(() => const Home());
    });
  }

  @override
  void initState() {
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: white,
      body: Center(
        child: Column(
          children: [
            Container(
              color: mainBackGroundColor,
              child: Image.asset(
                splashScreen1,
                width: context.screenWidth * 1,
                height: context.screenHeight * 1,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
