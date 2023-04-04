import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../consts/colors.dart';

//파이어베이스 인증 정보를 Singleton으로 관리
class MyFirebaseService {
  //파이어스토어 instance 초기화
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //파이어베이스Auth instance 초기화
  static final FirebaseAuth auth = FirebaseAuth.instance;
  late UserCredential userCredential;

  //클래스 생성자
  static final instance = MyFirebaseService();

  //이메일이 중복되었는지 확인하는 메서드
  Future<bool> isEmailDuplicate(String email) async {
    final QuerySnapshot<Map<String, dynamic>> result = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return result.size > 0;
  }

  //사용자 생성 메서드
  Future<void> createUser(
    String email,
    String password,
    String passwordConfirm,
    String name,
    String nickname,
  ) async {
    // 중복 이메일 검사
    bool isDuplicate = await isEmailDuplicate(email);
    if (isDuplicate) {
      throw Exception('중복된 이메일입니다.');
    }

    // Firebase Auth에 사용자 등록
    // ignore: unused_local_variable
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  //스터디 필드 가져오는 메서드
  Future<DocumentSnapshot<Map<String, dynamic>>> getStudyDetails(
      String newGroupId) async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        firestore.collection('studiesOnRecruiting').doc(newGroupId);
    return documentReference.get();
  }

  //현재 로그인한 사용자 닉네임 가져 오는 메서드
  Future<String> getFirebaseUserNickname() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('users').doc(uid);
    final snapshot = await userData.get();
    final userNickname = snapshot.get('nickname');
    return userNickname;
  }

  //위 내용 가장 짧게 줄인 거
  // Future<String> getFirebaseUserNickname() async =>
  // await firestore.collection('users').doc(auth.currentUser!.uid).get().then((snapshot) => snapshot.get('nickname'));

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

// 익명 인증
  Future<UserCredential> signInAnonymously() async {
    UserCredential userCredential = await auth.signInAnonymously();
    return userCredential;
  }

// 이메일/비밀번호 회원가입 후 사용자 정보 리턴
  Future<UserCredential> signUpWithEmailAndPassword(
      String email, String password) async {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential;
  }

  // 이메일/비밀번호 로그인
  Future<UserCredential> mySignInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      //토큰 생성
      final token = await userCredential.user!.getIdToken();
      //GetStorage에 저장
      //토큰은 토큰대로 로그인 상태는 로그인 상태대로 따로 관리 중
      await GetStorage().write('token', token);
      await AppCache.saveCacheisLoggedin(true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Get.snackbar(
          '이메일 오류', // 타이틀
          '해당 이메일로 가입한 사용자가 없습니다.', // 메시지
          duration: const Duration(seconds: 1), // Snackbar가 보일 시간
          snackPosition: SnackPosition.BOTTOM, // Snackbar 위치
          backgroundColor: white,
        );
      } else if (e.code == 'wrong-password') {
        Get.snackbar(
          '비밀번호 오류', // 타이틀
          '비밀번호가 맞지 않습니다.', // 메시지
          duration: const Duration(seconds: 1), // Snackbar가 보일 시간
          snackPosition: SnackPosition.BOTTOM, // Snackbar 위치
          backgroundColor: white,
        );
      }
    }
    return userCredential;
  }

// 이메일 확인 메일 전송
  Future<void> sendEmailVerification() async {
    User user = auth.currentUser!;
    await user.sendEmailVerification();
  }

// 이메일/비밀번호 회원정보 수정
  Future<void> updateUserProfile(String displayName, String photoURL) async {
    User user = auth.currentUser!;

    await user.updatePhotoURL(photoURL);
    await user.updateDisplayName(displayName);
  }

// 비밀번호 재설정 메일 전송
  Future<void> sendPasswordResetEmail(String email) async {
    await auth.sendPasswordResetEmail(email: email);
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
    UserCredential userCredential = await auth.signInWithCredential(credential);

    return userCredential;
  }

  //로그인 되어 있는지 확인하고 사용자 객체 리턴하는 함수
  Future<User?> isLoggedin() async {
    if (auth.currentUser != null) {
      final user = auth.currentUser;
      return user;
    } else {
      return null;
    }
  }
}
