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
    final userName = snapshot.get('name');
    return userName;
  }

  //studyLeader 값을 가져 오는 메서드
  Future<String> getStudyLeaderName() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('studiesOnRecruiting').doc(uid);
    final snapshot = await userData.get();
    final studyLeaderName = snapshot.get('studyLeader');
    return studyLeaderName;
  }

  //currentMembers 값을 가져 오는 메서드
  Future<String> getCurrentMembers() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('studiesOnRecruiting').doc(uid);
    final snapshot = await userData.get();
    final currentMembersNumber = snapshot.get('currentMembers');
    return currentMembersNumber;
  }

  //NumberOfDefaultParticipants 값을 가져 오는 메서드
  Future<String> getParticipantsNumber() async {
    final uid = auth.currentUser!.uid;
    final userData = firestore.collection('studiesOnRecruiting').doc(uid);
    final snapshot = await userData.get();
    final maxParticipants = snapshot.get('numberOfDefaultParticipants');
    return maxParticipants;
  }

  //studiesOnRecruiting 콜렉션에서 participants 필드의 array를 가져오는 메서드
  //true or false를 반환할 것임
  Future<bool> checkJoinOrNot(newGroupId) async {
    try {
      final user = FirebaseService.auth.currentUser!.uid;
      final studyRef1 = FirebaseService.firestore
          .collection('studiesOnRecruiting')
          .doc(newGroupId);
      final studyRef2 = FirebaseService.firestore
          .collection('users')
          .doc(user); //닉네임 가져 오기 위해 만듬
      final snapshot1 = await studyRef1.get();
      final snapshot2 = await studyRef2.get();
      if (snapshot1.exists && snapshot2.exists) {
        final data1 = snapshot1.data()!;
        final data2 = snapshot2.data()!;
        // ignore: unused_local_variable
        final currentMembers = data1['currentMembers'] as int; //현재 인원
        // ignore: unused_local_variable
        final maxMembers = data1['numberOfDefaultParticipants'] as int; //최대 인원
        final participants =
            List<String>.from(data1['participants'] ?? <dynamic>[]); //참여 인원
        final String myNickname = data2['nickname'];

        return (participants.contains(myNickname)) ? true : false;
      }
    } catch (e) {
      throw Exception("checkJoinOrNot error: $e");
    }
    throw Exception("checkJoinOrNot error: unknown");
  }

  //참가자 리스트로 가져오기
  static Future<List<String>> getParticipantsList(String studyId) async {
    final DocumentSnapshot studySnapshot = await FirebaseFirestore.instance
        .collection('studiesOnRecruiting')
        .doc(studyId)
        .get();
    final List<dynamic> participants = studySnapshot.get('participants') ?? [];
    return participants.cast<String>();
  }
}
