import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  void _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final data = {
      'nickname': _nicknameController.text,
      'job': _jobController.text,
      'lifegoal': _lifegoalController.text,
      'shorttermgoal': _shorttermgoalController.text,
      'midtermgoal': _midtermgoalController.text,
      'longtermgoal': _longtermgoalController.text,
      'selfintroduction': _selfintroductionController.text,
    };

    await FirebaseFirestore.instance
        .collection('profiles')
        .doc(uid)
        .set(data, SetOptions(merge: true));

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

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
