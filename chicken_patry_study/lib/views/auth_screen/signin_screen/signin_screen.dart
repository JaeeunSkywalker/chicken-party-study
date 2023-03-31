import 'dart:async';

import 'package:chicken_patry_study/consts/consts.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/firebase_service.dart';

//프로바이더 생성
final nicknameProvider = StateProvider<String>((ref) => '');

class SigninScreen extends StatefulWidget {
  const SigninScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  String _email = '';
  String _password = '';
  String _passwordConfirm = '';
  String _name = '';
  static String nickname = '';

  List<String> errorMessages = List.generate(5, (_) => '');
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24.0),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '회원가입',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: (value) => setState(() => _email = value.trim()),
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    hintText: 'BruceWayne@gmail.com',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      errorMessages[0] = '이메일을 입력하세요.';
                    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      errorMessages[0] = '유효한 이메일을 입력하세요.';
                    } else {
                      errorMessages[0] = '';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: (value) =>
                      setState(() => _password = value.trim()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      errorMessages[1] = '비밀번호를 입력하세요';
                    } else if (!RegExp(r'^.{5,}$').hasMatch(value)) {
                      errorMessages[1] = '비밀번호는 최소 6자리 이상이어야 합니다';
                    } else {
                      errorMessages[1] = '';
                    }
                    return null;
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
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: (value) =>
                      setState(() => _passwordConfirm = value.trim()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      errorMessages[2] = '비밀번호를 다시 입력하세요';
                    } else if (!RegExp(r'^.{5,20}$').hasMatch(value)) {
                      errorMessages[2] = '비밀번호는 최소 6자리 이상이어야 합니다';
                    } else if (value != _password) {
                      errorMessages[2] = '비밀번호가 일치하지 않습니다';
                    } else {
                      errorMessages[2] = '';
                    }
                    return null;
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
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: (value) => setState(() => _name = value.trim()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      errorMessages[3] = '이름을 입력하세요';
                    } else if (!RegExp(r'^[가-힣]{2,5}$').hasMatch(value)) {
                      errorMessages[3] = '한글 2자 이상, 5자 이하로 입력해주세요';
                    } else {
                      errorMessages[3] = '';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: '이름',
                    hintText: '브루스웨인',
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  onChanged: (value) => setState(() => nickname = value.trim()),
                  validator: (value) {
                    if (value!.isEmpty) {
                      errorMessages[4] = '닉네임을 입력하세요';
                    } else if (!RegExp(r'^.{1,15}$').hasMatch(value)) {
                      errorMessages[4] = '닉네임은 1자 이상, 15자 이하로 입력해주세요';
                    } else {
                      errorMessages[4] = '';
                    }
                    return null;
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
                (errorMessages.isNotEmpty)
                    ? Center(
                        child: Column(
                          children: errorMessages
                              .map((error) => Text(
                                    error,
                                    style: const TextStyle(
                                        color: Colors.red,
                                        backgroundColor: Vx.purple100),
                                  ))
                              .toList(),
                        ),
                      )
                    : const Text(''),
              ],
            ),
          ),
        ),
      ),
    );
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
      await FirebaseService.instance.createUser(
        _email,
        _password,
        _passwordConfirm,
        _name,
        nickname,
      );

      final snackBar = SnackBar(
        content: const Text('회원가입이 완료되었습니다.'),
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
          Navigator.of(context).pop();
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
