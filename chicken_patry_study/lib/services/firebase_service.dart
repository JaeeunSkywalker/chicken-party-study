import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final instance = FirebaseService();

  Future<bool> isEmailDuplicate(String email) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    return result.size > 0;
  }

  Future<void> createUser(
    String email,
    String password,
    String name,
    String nickname,
    String phone,
  ) async {
    // 중복 이메일 검사
    bool isDuplicate = await isEmailDuplicate(email);
    if (isDuplicate) {
      throw Exception('중복된 이메일입니다.');
    }

    // Firebase Auth에 사용자 등록
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Firestore에 사용자 정보 추가
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user!.uid)
        .set({
      'email': email,
      'name': name,
      'nickname': nickname,
      'phone': phone,
    });
  }
}
