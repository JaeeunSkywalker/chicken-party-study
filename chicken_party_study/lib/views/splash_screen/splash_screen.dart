import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app_cache/app_cache.dart';
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
      AppCache.delCacheisLoggedin();
      Get.to(() => const Home(
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
            Expanded(
              child: Container(
                alignment: Alignment.center,
                color: mainBackGroundColor,
                child: Image.asset(
                  splashScreen1,
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: MediaQuery.of(context).size.height * 0.9,
                  alignment: Alignment.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
