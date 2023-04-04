import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/firebase_service.dart';
import '../../login_screen/login_screen.dart';

class SigninScreen extends StatefulWidget {
  //const SigninScreen({Key? key}) : super(key: key);
  const SigninScreen(
      // ignore: avoid_types_as_parameter_names
      {super.key,
      required bool isLoggedin});

  @override
  State<SigninScreen> createState() => _SigninState();
}

class _SigninState extends State<SigninScreen> {
  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  String _name = '';
  static String nickname = '';

  List<String> errorMessages = List.generate(5, (_) => '');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //resizeToAvoidBottomInset: false,
        body: Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 24.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => setState(() => _email = value.trim()),
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'brucewayne@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    errorMessages[0] = '이메일을 입력해 주세요.';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    errorMessages[0] = '유효한 이메일을 입력해 주세요.';
                  } else {
                    errorMessages[0] = '';
                  }
                  return errorMessages[0];
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => setState(() => _password = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    errorMessages[1] = '비밀번호를 입력해 주세요.';
                  } else if (!RegExp(r'^.{5,}$').hasMatch(value)) {
                    errorMessages[1] = '비밀번호는 최소 6자리 이상이어야 합니다.';
                  } else {
                    errorMessages[1] = '';
                  }
                  return errorMessages[1];
                },
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  hintText: '최소 6자리',
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) =>
                    setState(() => _passwordConfirm = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    errorMessages[2] = '비밀번호를 다시 입력해 주세요.';
                  } else if (!RegExp(r'^.{5,20}$').hasMatch(value)) {
                    errorMessages[2] = '비밀번호가 일치하지 않습니다.';
                  } else if (value != _password) {
                    errorMessages[2] = '비밀번호가 일치하지 않습니다.';
                  } else {
                    errorMessages[2] = '';
                  }
                  return errorMessages[2];
                },
                decoration: const InputDecoration(
                  labelText: '비밀번호 확인',
                  hintText: '위와 똑같이 입력',
                ),
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => setState(() => _name = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    errorMessages[3] = '이름을 입력해 주세요.';
                  } else if (!RegExp(r'^[가-힣]{2,5}$').hasMatch(value)) {
                    errorMessages[3] = '한글 2자 이상, 5자 이하로 입력해 주세요.';
                  } else {
                    errorMessages[3] = '';
                  }
                  return errorMessages[3];
                },
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '브루스웨인',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                onChanged: (value) => setState(() => nickname = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    errorMessages[4] = '닉네임을 입력해 주세요.';
                  } else if (!RegExp(r'^.{1,15}$').hasMatch(value)) {
                    errorMessages[4] = '닉네임은 1자 이상, 15자 이하로 입력해 주세요.';
                  } else {
                    errorMessages[4] = '';
                  }
                  return errorMessages[4];
                },
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '치킨러버브루스',
                ),
              ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () {
                    _submit(context);
                  },
                  child: const Text('제출'),
                ),
              ),
              // 저장된 errorMessages 출력
              // (errorMessages.isNotEmpty)
              //     ? Center(
              //         child: Column(
              //           children: errorMessages
              //               .map((error) => Text(
              //                     error,
              //                     style: const TextStyle(
              //                         color: Colors.red,
              //                         backgroundColor: Vx.purple100),
              //                   ))
              //               .toList(),
              //         ),
              //       )
              //     : const Text('')
            ])),
      ),
    ));
  }

  void _submit(context) async {
    // 모든 TextField에 값이 입력되었는지 확인
    if (_email.isEmpty ||
        _password.isEmpty ||
        _passwordConfirm.isEmpty ||
        _name.isEmpty ||
        nickname.isEmpty) {
      // 모든 필드가 입력되지 않았을 경우, 사용자에게 알림을 표시
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('입력 오류\n모든 필드를 입력해야 합니다.'),
        action: SnackBarAction(
          label: '닫기',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ));
    }

    try {
      // FirebaseService를 사용하여 회원가입 처리
      await FirebaseService().createUser(
        _email.toLowerCase(),
        _password,
        _passwordConfirm,
        _name,
        nickname,
      );

      final snackBar = SnackBar(
        content: const Text('회원가입이 완료되었습니다.\n로그인 페이지로 이동합니다.'),
        action: SnackBarAction(
          label: '닫기',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      Timer(const Duration(seconds: 2), () {
        if (ScaffoldMessenger.of(context).mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Get.to(() => const LoginScreen(onLoggedIn: false));
        }
      });
    } catch (e) {
      // 회원가입 실패
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입에 실패했습니다.\n$e'),
          action: SnackBarAction(
            label: '닫기',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }
}
