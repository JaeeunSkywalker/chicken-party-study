import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  //파이어스토어 instance 초기화
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  //파이어베이스Auth instance 초기화
  static final FirebaseAuth auth = FirebaseAuth.instance;
  //final FirebaseStorage storage = FirebaseStorage.instance;
  late UserCredential userCredential;

  //StorageReference 생성하기
  final storageRef = FirebaseStorage.instance.ref();
  //이미지 업로드하기
  Future<String?> uploadImage(File file) async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(user.uid)
          .child('profile_image.jpg');
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  //이미지 읽어 오기
  Future<Uint8List?> getImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child(user.uid)
          .child('profile_image.jpg');
      final imageData = await storageRef.getData();
      return imageData;
    } catch (e) {
      return null;
    }
  }

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

  //현재 로그인한 사용자 닉네임을 가져 오는 메서드
  Future<String?> getFirebaseUserNickname() async {
    final user = auth.currentUser?.uid;
    final userData = firestore.collection('users').doc(user);
    final snapshot = await userData.get();
    final userNickname = snapshot.get('nickname');
    return userNickname;
  }

  //현재 로그인한 사용자 이름을 가져 오는 메서드
  Future<String> getFirebaseUserName() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('users').doc(uid);
    final snapshot = await userData.get();
    final userNickname = snapshot.get('nickname');
    return userNickname;
  }

  //studiesOnRecruiting 콜렉션에서 participants 필드의 array를 가져오는 메서드
  //true or false를 반환할 것임
  Future<bool> checkJoinOrNot() async {
    final user = FirebaseService.auth.currentUser!;
    //로그인한 사용자가 없는 상황
    // ignore: unnecessary_null_comparison
    if (user == null) {
      //첫 번째 null check
      return true;
    }

    final participantsDoc = await FirebaseFirestore.instance
        .collection('studiesOnRecruiting')
        .doc(user.uid)
        .get();

    //내가 스터디를 개설하지 않은 상황
    if (!participantsDoc.exists || participantsDoc.data() == null) {
      return true;
    }

    final participantsData = participantsDoc.data()!;
    // ignore: unused_local_variable
    final participants = participantsData.containsKey('participants')
        ? participantsData['participants'] as List<String>
        : <String>[];

    final nicknameDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    //로그인한 사용자가 없는 상황
    if (!nicknameDoc.exists || nicknameDoc.data() == null) {
      return true;
    }

    final nicknameData = nicknameDoc.data()!;
    // ignore: unused_local_variable
    final nickname = nicknameData.containsKey('nickname')
        ? nicknameData['nickname'] as String
        : '';

    return participantsData['participants'].contains(nicknameData['nickname']);
  }
}
