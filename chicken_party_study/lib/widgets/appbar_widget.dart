import 'package:chicken_patry_study/consts/colors.dart';
import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../views/auth_screen/signin_screen/signin_screen.dart';
import '../views/login_screen/login_screen.dart';

PreferredSize appBarWidget(isloggedin) {
  // GetStorage에서 로그인 정보 가져오기
  // ignore: unused_local_variable
  bool loginLog = GetStorage().read<bool>('isLoggedin') ?? false;

  return PreferredSize(
    preferredSize: const Size.fromHeight(70.0),
    child: AppBar(
      backgroundColor: black,
      automaticallyImplyLeading: false,
      title: isloggedin
          ? FutureBuilder<String>(
              future: getFirebaseUserNickname(),
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
        if (!isloggedin)
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
              FirebaseAuth.instance.signOut();
              GetStorage().remove('isLoggedin');
              Get.offAll(() => Home(isloggedin: false));
            },
            child: const Text('로그아웃'),
          ),
      ],
    ),
  );
}

Future<String> getFirebaseUserNickname() async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final userData = FirebaseFirestore.instance.collection('users').doc(uid);
  final snapshot = await userData.get();
  final userNickname = snapshot.get('nickname');
  // ignore: avoid_print
  print(snapshot);
  return userNickname;
}

// IconButton(
//           onPressed: () {},
//           icon: const Icon(
//             Icons.logout,
//             color: Colors.black,
//           ),
//         ),