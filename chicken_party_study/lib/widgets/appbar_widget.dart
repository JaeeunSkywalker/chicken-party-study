import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/consts/colors.dart';
import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/auth_screen/signin_screen/signin_screen.dart';
import '../views/login_screen/login_screen.dart';

PreferredSize appBarWidget(isloggedin) {
  // GetStorage에서 로그인 정보 가져오기
  // ignore: unused_local_variable

  return PreferredSize(
    preferredSize: const Size.fromHeight(70.0),
    child: AppBar(
      backgroundColor: black,
      automaticallyImplyLeading: false,
      title: isloggedin == true
          ? FutureBuilder<String?>(
              future: getFirebaseUserNickname(),
              builder: (context, snapshot) {
                if (snapshot.hasData &&
                    FirebaseService.auth.currentUser != null &&
                    snapshot.data != null) {
                  return Text(
                    '${snapshot.data}님, 오늘도 치파스!',
                    style: const TextStyle(
                      color: white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != null) {
                  //여기서 null 자주 남
                  //로그인을 하지 않은 상태에서는 FirebaseService.auth.currentUser가 null이 됨
                  return Container();
                } else {
                  return Container();
                }
              },
            )
          : null,
      actions: [
        //로그인 되어 있지 않을 때
        if (AppCache.getCachedisLoggedin() == false ||
            FirebaseService.auth.currentUser == null ||
            isloggedin == false)
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Get.to(() => LoginScreen(
                        isloggedin: isloggedin = false,
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
                        isloggedin: false,
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
            onPressed: () async {
              try {
                // 로그아웃 처리
                await FirebaseService.auth.signOut();
                // 사용자 계정 삭제
                await FirebaseService.auth.currentUser!.delete();
                // 캐시 초기화
                //AppCache.delCacheisLoggedin();
                AppCache.eraseAllCache();

                Get.offAll(() => const Home(isloggedin: false));
              } catch (e) {
                // 처리 중 에러 발생 시 처리
                Get.offAll(() => const Home(isloggedin: false));
              }
            },
            child: const Text('로그아웃'),
          ),
      ],
    ),
  );
}

Future<String?> getFirebaseUserNickname() async {
  final uid = FirebaseService.auth.currentUser?.uid;
  final userData = FirebaseFirestore.instance.collection('users').doc(uid);
  final snapshot = await userData.get();
  final userNickname = snapshot.get('nickname');
  if (uid == null) {
    return null;
  } else {
    return userNickname;
  }
}
