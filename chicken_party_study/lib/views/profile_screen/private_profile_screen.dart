import 'package:chicken_patry_study/views/profile_screen/public_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final _nicknameController = TextEditingController();
  final _jobController = TextEditingController();
  final _lifegoalController = TextEditingController();
  final _shorttermgoalController = TextEditingController();
  final _midtermgoalController = TextEditingController();
  final _longtermgoalController = TextEditingController();
  final _selfintroductionController = TextEditingController();

  //users 콜렉션의 nickname 제외, profiles 콜렉션만 업데이트
  void _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // final data2 = {
    //   'nickname': _nicknameController.text.trim(),
    //   'job': _jobController.text.trim(),
    //   'lifegoal': _lifegoalController.text.trim(),
    //   'shorttermgoal': _shorttermgoalController.text.trim(),
    //   'midtermgoal': _midtermgoalController.text.trim(),
    //   'longtermgoal': _longtermgoalController.text.trim(),
    //   'selfintroduction': _selfintroductionController.text.trim(),
    // };

    //2개 콜렉션에 동시 저장 시도
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final profileDocRef =
        FirebaseFirestore.instance.collection('profiles').doc(uid);

    // 기존 nickname 값 읽어오기
    final userData = await userDocRef.get();
    final prevNickname = userData.data()?['nickname'];

    // nickname 필드 업데이트
    if (_nicknameController.text.isNotEmpty &&
        _nicknameController.text != prevNickname) {
      await userDocRef.update({'nickname': _nicknameController.text});
    }

    //이제 profiles 콜렉션 작업 시작
    // 기존의 값을 가져옵니다.
    final doc2Snapshot = await profileDocRef.get();
    final oldData2 = doc2Snapshot.data() ?? {}; // null 체크를 위해 ?? 연산자 사용

    // 새롭게 들어온 값 확보
    final newData2 = {
      'job': _jobController.text.trim(),
      'lifegoal': _lifegoalController.text.trim(),
      'shorttermgoal': _shorttermgoalController.text.trim(),
      'midtermgoal': _midtermgoalController.text.trim(),
      'longtermgoal': _longtermgoalController.text.trim(),
      'selfintroduction': _selfintroductionController.text.trim(),
    };

    // 변경된 필드만 업데이트합니다.
    final Map<String, dynamic> updateData = {};
    if (oldData2.isEmpty) {
      // profiles 콜렉션 업데이트
      await profileDocRef.set(newData2, SetOptions(merge: true));
    } else {
      for (final key in newData2.keys) {
        final value = newData2[key];
        if (oldData2[key] != value && value != "") {
          updateData[key] = value;
        }
      }
      await profileDocRef.update(updateData);
    }

    //profiles 콜렉션에 저장
    // await FirebaseFirestore.instance
    //     .collection('profiles')
    //     .doc(uid)
    //     .set(data, SetOptions(merge: true));

    Get.offAll(() => const PublicProfileScreen());
  }

  //nickname만
  // 파이어스토어 데이터를 저장할 때 users와 profiles 콜렉션 모두 업데이트하도록 설정
  // void updateUserAndProfile(String userId, String nickname) async {
  //   final userDocRef =
  //       FirebaseFirestore.instance.collection('users').doc(userId);
  //   final profileDocRef =
  //       FirebaseFirestore.instance.collection('profiles').doc(userId);

  //   // 업데이트할 데이터를 Map으로 정의
  //   final data = {'nickname': nickname};
  // }

  // textformfield에서 값이 변경될 때 호출되는 콜백 함수
  // void onNicknameChanged(String value) {
  //   if (value.isNotEmpty) {
  //     final userId = FirebaseAuth.instance.currentUser?.uid;
  //     if (userId != null) {
  //       updateUserAndProfile(userId, value.trim());
  //     }
  //   }
  // }

  @override
  void dispose() {
    _nicknameController.dispose();
    _jobController.dispose();
    _lifegoalController.dispose();
    _shorttermgoalController.dispose();
    _midtermgoalController.dispose();
    _longtermgoalController.dispose();
    _selfintroductionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정 페이지'),
        actions: const [],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '닉네임',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  hintText: '닉네임 수정을 원하시면 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '직업',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _jobController,
                decoration: const InputDecoration(
                  hintText: '직업을 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '인생 목표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _lifegoalController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '인생 목표를 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '단기 목표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _shorttermgoalController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '단기 목표를 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '중기 목표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _midtermgoalController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '중기 목표를 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '장기 목표',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _longtermgoalController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: '장기 목표를 입력해 주세요.',
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '자기 소개',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _selfintroductionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '자기 소개를 해 주세요.',
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('저장'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
