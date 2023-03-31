import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseConfig {
  static const String apiKey = 'your_api_key';
  static const String authDomain = 'your_auth_domain';
  static const String projectId = 'your_project_id';
  static const String storageBucket = 'your_storage_bucket';
  static const String messagingSenderId = 'your_messaging_sender_id';
  static const String appId = 'your_app_id';

  static const String googleClientId = 'your_google_client_id';

  static const List<String> supportedSigninMethods = [
    'emailLink',
    'google.com',
  ];
}

// 익명 인증
Future<UserCredential> signInAnonymously() async {
  UserCredential userCredential =
      await FirebaseAuth.instance.signInAnonymously();
  return userCredential;
}

// 이메일/비밀번호 회원가입
Future<UserCredential> signUpWithEmailAndPassword(
    String email, String password) async {
  UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  return userCredential;
}

// 이메일/비밀번호 로그인
Future<UserCredential> signInWithEmailAndPassword(
    String email, String password) async {
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  return userCredential;
}

// 이메일 확인 메일 전송
Future<void> sendEmailVerification() async {
  User user = FirebaseAuth.instance.currentUser!;
  await user.sendEmailVerification();
}

// 이메일/비밀번호 회원정보 수정
Future<void> updateUserProfile(String displayName, String photoURL) async {
  User user = FirebaseAuth.instance.currentUser!;

  await user.updatePhotoURL(photoURL);
  await user.updateDisplayName(displayName);
}

// 비밀번호 재설정 메일 전송
Future<void> sendPasswordResetEmail(String email) async {
  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
}

// 구글 로그인
Future<UserCredential> signInWithGoogle() async {
  // GoogleSignIn 인스턴스 생성
  GoogleSignIn googleSignIn = GoogleSignIn();

  // Google 로그인 창 열기
  GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

  // GoogleSignInAuthentication 객체 가져오기
  GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount!.authentication;

  // Firebase 인증 정보 가져오기
  OAuthCredential credential = GoogleAuthProvider.credential(
    idToken: googleSignInAuthentication.idToken,
    accessToken: googleSignInAuthentication.accessToken,
  );

  // Firebase 인증
  UserCredential userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

  return userCredential;
}
