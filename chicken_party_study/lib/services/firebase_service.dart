import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  //파이어스토어 instance 초기화
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //파이어베이스Auth instance 초기화
  static final FirebaseAuth auth = FirebaseAuth.instance;
  late UserCredential userCredential;

  Future<bool> isEmailDuplicate(String email) async {
    final QuerySnapshot<Map<String, dynamic>> result = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return result.size > 0;
  }

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

    // Cloud Firestore의 users 컬렉션에 사용자 정보 추가
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': email,
      'name': name,
      'nickname': nickname,
      'password': password,
      'passwordConfirm': passwordConfirm,
    });
  }

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

  //현재 로그인한 사용자 이름 가져 오는 메서드
  Future<String> getFirebaseUserName() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('users').doc(uid);
    final snapshot = await userData.get();
    final userNickname = snapshot.get('nickname');
    return userNickname;
  }
}
