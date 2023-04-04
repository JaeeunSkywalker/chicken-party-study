import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/consts/colors.dart';
import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/auth_screen/signin_screen/signin_screen.dart';
import '../views/login_screen/login_screen.dart';

PreferredSize appBarWidget() {
  // GetStorage에서 로그인 정보 가져오기
  // ignore: unused_local_variable
  bool loginLog = AppCache.getCachedisLoggedin();

  return PreferredSize(
    preferredSize: const Size.fromHeight(80.0),
    child: AppBar(
      backgroundColor: black,
      automaticallyImplyLeading: false,
      title: loginLog == true
          ? FutureBuilder<String>(
              future: MyFirebaseService().getFirebaseUserNickname(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    '${snapshot.data}님, 오늘도 치파스!',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Error');
                } else {
                  return const CircularProgressIndicator(
                    color: red,
                  );
                }
              },
            )
          : null,
      actions: [
        if (AppCache.getCachedisLoggedin() == false)
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Get.to(() => const LoginScreen(
                        onLoggedIn: false,
                      ));
                },
                child: const Text('로그인'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Get.to(() => const SigninScreen(
                        isLoggedin: false,
                      ));
                },
                child: const Text('회원가입'),
              ),
            ],
          )
        else
          TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(color: Colors.black),
            ),
            onPressed: () {
              // 로그아웃 처리
              MyFirebaseService.auth.signOut();
              //로그아웃 후 GetStorage에 캐시 삭제
              //GetStorage().remove('isLoggedin');
              //isLoggedin인을 false로 전환
              AppCache.delCacheisLoggedin(false);
              Get.offAll(() => Home(
                    isLoggedin: loginLog,
                  ));
            },
            child: const Text('로그아웃'),
          ),
      ],
    ),
  );
}
