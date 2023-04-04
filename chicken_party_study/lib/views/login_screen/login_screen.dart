import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  final bool onLoggedIn; // 새로 추가한 멤버 변수
  const LoginScreen({Key? key, required this.onLoggedIn}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // ignore: unused_field, prefer_final_fields
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Future<void> _signInWithEmailAndPassword() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     UserCredential userCredential =
  //         await FirebaseService.auth.signInWithEmailAndPassword(
  //       email: _emailController.text,
  //       password: _passwordController.text,
  //     );

  //     // 사용자가 파이어베이스에 있는지 확인
  //     DocumentSnapshot userSnapshot = await FirebaseService.firestore
  //         .collection('users')
  //         .doc(userCredential.user!.uid)
  //         .get();

  //     if (!userSnapshot.exists) {
  //       // User does not exist, sign out
  //       await FirebaseService.auth.signOut();
  //       // ignore: use_build_context_synchronously
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('등록된 사용자가 없습니다.')),
  //       );
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       return;
  //     }

  //     // User exists, set isLoggedin to true and navigate to home screen
  //     setState(() {
  //       _isLoading = false;
  //       isLoggedin = true;
  //       //여기서 isLoggedn 값을 Home으로 보내야 함
  //     });

  //     // ignore: use_build_context_synchronously
  //   } on FirebaseAuthException catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.message ?? '에러가 발생했습니다.\n관리자에게 문의하세요.')),
  //     );
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   } catch (e) {
  //     // ignore: avoid_print
  //     print(e);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('에러가 발생했습니다.\n관리자에게 문의하세요.')),
  //     );
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력해 주세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () async {
                  final result =
                      await MyFirebaseService().mySignInWithEmailAndPassword(
                    _emailController.text,
                    _passwordController.text,
                  );
                  if (result.user != null) {
                    Get.to(() => Home(isLoggedin: true));
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("사용자 정보가 바르지 않습니다.\n관리자에게 문의하세요.")));
                  }
                },
                child: const Text('로그인'),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}

//카카오 로그인
// final KakaoLogin _kakaoLogin = KakaoLogin();

// Future<void> signInWithKakao() async {
//   try {
//     final result = await _kakaoLogin.logIn();

//     switch (result.status) {
//       case Kakao
