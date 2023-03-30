import 'package:flutter/material.dart';

import '../../../services/firebase_service.dart';

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
  String _nickname = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                onChanged: (value) => setState(() => _email = value.trim()),
                decoration: const InputDecoration(
                  labelText: '이메일',
                  hintText: 'BruceWayne@gmail.com',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이메일을 입력하세요.';
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return '유효한 이메일을 입력하세요.';
                  } else {
                    return null;
                  }
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                onChanged: (value) => setState(() => _password = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호를 입력하세요';
                  } else if (!RegExp(r'^.{6,}$').hasMatch(value)) {
                    return '비밀번호는 최소 6자리 이상이어야 합니다';
                  } else {
                    return null;
                  }
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
                onChanged: (value) =>
                    setState(() => _passwordConfirm = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '비밀번호를 다시 입력하세요';
                  } else if (!RegExp(r'^.{6,20}$').hasMatch(value)) {
                    return '비밀번호는 최소 6자리 이상이어야 합니다';
                  } else if (value != _password) {
                    return '비밀번호가 일치하지 않습니다';
                  } else {
                    return null;
                  }
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
                onChanged: (value) => setState(() => _name = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '이름을 입력하세요';
                  } else if (!RegExp(r'^[가-힣]{2,5}$').hasMatch(value)) {
                    return '한글 2자 이상, 5자 이하로 입력해주세요';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: '이름',
                  hintText: '브루스웨인',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                onChanged: (value) => setState(() => _nickname = value.trim()),
                validator: (value) {
                  if (value!.isEmpty) {
                    return '닉네임을 입력하세요';
                  } else if (!RegExp(r'^.{1,15}$').hasMatch(value)) {
                    return '닉네임은 1자 이상, 15자 이하로 입력해주세요';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                  labelText: '닉네임',
                  hintText: '브루스는치킨좋아',
                ),
              ),
              const SizedBox(height: 24.0),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('제출'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    // 모든 TextField에 값이 입력되었는지 확인
    if (_email.isEmpty ||
        _password.isEmpty ||
        _passwordConfirm.isEmpty ||
        _name.isEmpty ||
        _nickname.isEmpty) {
      // 모든 필드가 입력되지 않았을 경우, 사용자에게 알림을 표시
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('입력 오류'),
            content: const Text('모든 필드를 입력해야 합니다.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // FirebaseService를 사용하여 회원가입 처리
      await FirebaseService.instance.createUser(
        _email,
        _password,
        _passwordConfirm,
        _name,
        _nickname,
      );
      // 회원가입 성공
    } catch (e) {
      // 회원가입 실패
      print(e.toString());
    }
  }
}
