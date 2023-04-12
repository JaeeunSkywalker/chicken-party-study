// ignore_for_file: prefer_final_fields
import 'dart:io';

import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/profile_screen/goals.dart';
import 'package:chicken_patry_study/views/profile_screen/private_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  // ignore: unused_field
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
    final user = FirebaseService.auth.currentUser!;
    // ignore: unnecessary_null_comparison
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

  String? userPhotoUrl = FirebaseService.auth.currentUser!.photoURL;

  //키 설정
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '공개 프로필 페이지',
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Get.to(() => const EditProfileScreen());
              },
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  const SizedBox(height: 20.0),

                  ///FutureBuilder로 그리기 시작
                  FutureBuilder<List<DocumentSnapshot>>(
                      future: Future.wait([
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseService.auth.currentUser!.uid)
                            .get(),
                        FirebaseFirestore.instance
                            .collection('profiles')
                            .doc(FirebaseService.auth.currentUser!.uid)
                            .get(),
                      ]),
                      builder: (BuildContext context,
                          AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          final userDoc = snapshot.data![0];
                          final profileDoc = snapshot.data![1];
                          if (userDoc.exists && profileDoc.exists) {
                            // users 콜렉션과 profiles 콜렉션 모두에 해당 문서가 존재하는 경우
                            final userData =
                                userDoc.data() as Map<String, dynamic>?;
                            final profileData =
                                profileDoc.data() as Map<String, dynamic>?;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(15.0),
                                  // 화면을 보여줌
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Card(
                                          elevation: 5,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '이름: ${userData?['name'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 20,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        '직업: ${profileData?['job'] ?? ''}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 20,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  '닉네임: ${userData?['nickname'] ?? ''}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const GoalsScreen(),
                                    ],
                                  ),
                                ),
                                // 추가적인 위젯 등
                              ],
                            );
                          } else {
                            // profiles 콜렉션에 해당 문서가 없는 경우
                            return Column(
                              children: const [
                                Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text('프로필 등록을 한 적이 없으시네요!')),
                                Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child:
                                        Text('우측 상단 펜 아이콘을 클릭해 등록부터 해 주세요.')),
                                Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text(' 사진 변경은 이 페이지에서도 할 수 있습니다.'),
                                ),
                              ],
                            );
                          }
                        } else {
                          // Future가 완료되지 않은 경우, 로딩 중 표시
                          return const CircularProgressIndicator();
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
