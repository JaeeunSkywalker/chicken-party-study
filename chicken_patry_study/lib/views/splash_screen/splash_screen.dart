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
      Get.to(() => Home(
            //로그인 유지 어떻게 할 건지 생각하기
            isloggedin: false,
          ));
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
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.height * 1,
                alignment: Alignment.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
