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
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getStudyDetails(
      String newGroupId) async {
    final DocumentReference<Map<String, dynamic>> documentReference =
        _firestore.collection('studiesOnRecruiting').doc(newGroupId);
    return documentReference.get();
  }
}
