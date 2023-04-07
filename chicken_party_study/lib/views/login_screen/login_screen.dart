import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/views/home_screen/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  final bool isloggedin; // 새로 추가한 멤버 변수
  const LoginScreen({Key? key, required this.isloggedin}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // ignore: unused_field
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isloggedin = false; // 새로 추가한 멤버 변수

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userSnapshot.exists) {
        // User does not exist, sign out
        await FirebaseAuth.instance.signOut();
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('등록된 사용자가 없습니다.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // User exists, set isloggedin to true and navigate to home screen
      setState(() {
        _isLoading = false;
        AppCache.saveCacheisLoggedin();
        Get.to(() => Home(isloggedin: AppCache.getCachedisLoggedin()));
      });

      // ignore: use_build_context_synchronously
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? '에러가 발생했습니다.\n관리자에게 문의하세요.')),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('에러가 발생했습니다.\n관리자에게 문의하세요.')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => const Home(isloggedin: false));
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '로그인 페이지',
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListView(
                shrinkWrap: true,
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
                      await _signInWithEmailAndPassword();
                      if (AppCache.getCachedisLoggedin()) {
                        Get.to(() =>
                            Home(isloggedin: AppCache.getCachedisLoggedin()));
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("사용자 정보가 바르지 않습니다.\n관리자에게 문의하세요.")));
                      }
                    },
                    child: const Text('로그인'),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<void> signInWithEmailAndPassword(String email, String password) async {
  try {
    final UserCredential userCredential =
        await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredential.user;

    if (user != null) {
      // 로그인 성공
    } else {
      // 로그인 실패
    }
  } catch (e) {
    // 예외 처리
  }
}

//구글 로그인
// final GoogleSignIn _googleSignIn = GoogleSignIn();
// final FirebaseAuth _auth = FirebaseAuth.instance;

// Future<void> signInWithGoogle() async {
//   try {
//     final GoogleSignInAccount? googleSignInAccount =
//         await _googleSignIn.signIn();
//     final GoogleSignInAuthentication googleSignInAuthentication =
//         await googleSignInAccount!.authentication;

//     final OAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleSignInAuthentication.accessToken,
//       idToken: googleSignInAuthentication.idToken,
//     );

//     final UserCredential userCredential =
//         await _auth.signInWithCredential(credential);
//     final user = userCredential.user;

//     if (user != null) {
//       // 로그인 성공
//     } else {
//       // 로그인 실패
//     }
//   } catch (e) {
//     // 예외 처리
//   }
// }

//카카오 로그인
// final KakaoLogin _kakaoLogin = KakaoLogin();

// Future<void> signInWithKakao() async {
//   try {
//     final result = await _kakaoLogin.logIn();

//     switch (result.status) {
//       case Kakao
