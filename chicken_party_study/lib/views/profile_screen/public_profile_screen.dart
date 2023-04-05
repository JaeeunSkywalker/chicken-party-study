// ignore_for_file: prefer_final_fields
import 'dart:io';

import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/profile_screen/private_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PublicProfileScreen extends StatefulWidget {
  const PublicProfileScreen({Key? key}) : super(key: key);

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> {
  ImageProvider<Object>? _imageProvider;
  String? _userNickname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadProfileImage();
  }

  Future<String> _loadUserData() async {
    final uid = FirebaseService.auth.currentUser!.uid;
    //users collection
    final userData1 = FirebaseService.firestore.collection('users').doc(uid);
    final snapshot1 = await userData1.get();
    //profileSettings collection
    final userData2 =
        FirebaseService.firestore.collection('profileSettings').doc(uid);
    // ignore: unused_local_variable
    final snapshot2 = await userData2.get();
    final name = snapshot1.data()?['name'];
    if (name != null) {
      setState(() {
        _userNickname = name;
      });
      return name;
    } else {
      return '';
    }
  }

  //파이어베이스 스토리지에서 사진 가져 오기
  Future<void> _loadProfileImage() async {
    final user = FirebaseService.auth.currentUser!;
    final userDoc =
        await FirebaseService.firestore.collection('users').doc(user.uid).get();
    final userPhotoUrl = userDoc.data()!['profileImage'];
    setState(() {
      _imageProvider = userPhotoUrl != null
          ? NetworkImage(userPhotoUrl) as ImageProvider<Object>?
          : const AssetImage('assets/images/default_profile_image.png');
    });
  }

  //프로필 사진 관련
  // File? _imageFile;

  //이미지 피커로 로컬에서 이미지 가져 오기
  // Future _getImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   setState(() {
  //     if (pickedFile != null) {
  //       _imageFile = File(pickedFile.path);
  //     }
  //   });
  // }

  //이미지를 ImagePicker에서 선택한 뒤
  //Firebase Storage에 업로드하고 업로드한 이미지의 URL을 Firestore에 저장함
  Future<void> _updateProfileImage() async {
    final user = FirebaseService.auth.currentUser!;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      //final String fileName = DateTime.now().toString();
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('images/${user.uid}.jpg');
      final UploadTask uploadTask =
          storageReference.putFile(File(pickedFile.path));
      await uploadTask.whenComplete(() => null);
      final imageUrl = await storageReference.getDownloadURL();
      await FirebaseService.firestore.collection('users').doc(user.uid).update({
        'profileImage': imageUrl,
      });
      setState(() {
        user.updatePhotoURL(imageUrl);
        _imageProvider = NetworkImage(imageUrl);
      });
    }
  }

  //파이어스토어에서 기존 사진을 삭제함
  Future<void> _deleteProfileImage() async {
    final user = FirebaseService.auth.currentUser;
    if (user == null) return;

    // Firebase Storage에서 프로필 이미지 삭제
    final reference =
        FirebaseStorage.instance.ref().child('images/${user.uid}.jpg');
    await reference.delete();

    // Firestore에서 프로필 이미지 URL 삭제
    await FirebaseService.firestore.collection('users').doc(user.uid).update({
      'profileImage': null,
    });
  }

  String? userPhotoUrl = FirebaseAuth.instance.currentUser!.photoURL;

  //프로필 설정 관련
  //변수 설정

  String collection1Nickname = ''; //닉네임
  String? collection2Job; //직업
  String? collection2Goal; //치파스를 통해 달성하고 싶은 목표

  //단기 목표
  String? collection2Shorttermgoal;
  String? collection2Shorttermgoaldate;
  String? collection2Shorttermgoalachieved;

  //중기 목표
  String? collection2Midtermgoal;
  String? collection2Midtermgoaldate;
  String? collection2Midtermgoalachieved;

  //장기 목표
  String? collection2Longtermgoal;
  String? collection2Longtermgoaldate;
  String? collection2Longtermgoalachieved;

  //자기 소개
  String? collection2Selfintroduction;

  //키 설정
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('공개 프로필 페이지'), actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Get.to(() => const EditProfileScreen());
          },
        ),
      ]),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('프로필 이미지 변경'),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  GestureDetector(
                                    child: const Text('갤러리에서 선택'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await _updateProfileImage();
                                    },
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                  ),
                                  GestureDetector(
                                    child: const Text('초기화'),
                                    onTap: () {
                                      setState(() {
                                        _deleteProfileImage();
                                        _imageProvider = null;
                                      });
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      radius: 64,
                      backgroundImage: _imageProvider ??
                          const AssetImage(
                              'assets/images/default_profile_image.png'),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('profiles')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          snapshot.data != null &&
                          snapshot.data!.exists) {
                        final data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        return Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.4,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                              ),
                            ),
                            Positioned(
                              left: 16,
                              top: 32,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            Positioned(
                              bottom: -64,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 76,
                                  backgroundImage: NetworkImage(
                                    data['photoUrl'],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 180),
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['nickname'],
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['job'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '자기 소개',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['selfintroduction'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '인생 목표',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['lifegoal'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '단기 목표',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['shorttermgoal'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '중기 목표',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['midtermgoal'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      '장기 목표',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['longtermgoal'],
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: const [
                            Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('우측 상단 펜 아이콘을 클릭해 등록부터 해 주세요.')),
                            Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(' 사진 변경은 이 페이지에서도 할 수 있습니다.'),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
