import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/auth_screen/signin_screen/signin_screen.dart';

PreferredSizeWidget homeAppbarWidget(BuildContext context) {
  return AppBar(
    automaticallyImplyLeading: false,
    actions: [
      TextButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('로그인'),
                content: SizedBox(
                  height: 150,
                  child: Column(
                    children: const [
                      TextField(
                        decoration: InputDecoration(
                          hintText: '이메일',
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        decoration: InputDecoration(
                          hintText: '비밀번호',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // 로그인 버튼 눌렀을 때 처리할 로직 작성
                      Navigator.pop(context);
                    },
                    child: const Text('로그인'),
                  ),
                ],
              );
            },
          );
        },
        child: const Text(
          '로그인',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          Get.to(() => const SigninScreen());
        },
        child: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    ],
  );
}
