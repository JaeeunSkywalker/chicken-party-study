// ignore_for_file: prefer_final_fields
import 'dart:io';

import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _userNickname;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<String> _loadUserData() async {
    final uid = FirebaseService.auth.currentUser!.uid;
    //users collection
    final userData1 = FirebaseService.firestore.collection('users').doc(uid);
    final snapshot1 = await userData1.get();
    //profileSettings collection
    final userData2 =
        FirebaseService.firestore.collection('profileSettings').doc(uid);
    final snapshot2 = await userData2.get();
    final name = snapshot1.data()?['name'];
    if (name != null) {
      setState(() {
        _userNickname = name;
      });
      return name;
    } else {
      print('콜렉션에 name이 없습니다.');
      return '';
    }
  }

  Exception(e) {}

  //프로필 사진 관련
  File? _imageFile;

  Future _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  //프로필 설정 관련
  //변수 설정

  bool _isEditMode = false;

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
        appBar: AppBar(
          title: const Text('프로필 설정'),
        ),
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Center(
                        child: Column(children: [
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
                                        onTap: () {
                                          _getImage();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                      ),
                                      GestureDetector(
                                        child: const Text('초기화'),
                                        onTap: () {
                                          setState(() {
                                            _imageFile = null;
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
                          // ignore: unnecessary_null_comparison
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider<Object>?
                              : const AssetImage(
                                  'assets/images/default_profile_image.png'),
                        ),
                      ),

                      //여기서부터 CircleAvatar 밑
                      Column(children: [
                        const SizedBox(height: 16.0),
                        Center(
                          child: _userNickname != null
                              ? Text(
                                  _userNickname!,
                                  style: const TextStyle(fontSize: 20),
                                )
                              : const CircularProgressIndicator(),
                        ),
                        Row(
                          children: [
                            const Text(
                              '닉네임: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return '닉네임을 입력하세요.';
                                  }
                                  return null;
                                },
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection1Nickname),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '직업: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller:
                                    TextEditingController(text: collection2Job),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '인생 목표: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection2Goal),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        //단기 목표 안에 shortTermGoalDate랑 shortTermGoalAchieved 넣어야 함
                        Row(
                          children: [
                            const Text(
                              '단기 목표: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection2Shorttermgoal),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '중기 목표: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection2Midtermgoal),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '장기 목표: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection2Longtermgoal),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              '자기 소개: ',
                              style: TextStyle(fontSize: 16),
                            ),
                            Expanded(
                              child: TextFormField(
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                controller: TextEditingController(
                                    text: collection2Selfintroduction),
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.fromLTRB(0, 5, 0, 0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              '프로필 수정 후 저장',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ])
                    ]))))));
  }
}
