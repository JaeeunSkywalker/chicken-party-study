// ignore_for_file: prefer_final_fields
import 'dart:io';

import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  late Future<DocumentSnapshot> _profileDataFuture;

  bool _isEditMode = false;
  String collection1Name = '';
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
  void initState() {
    super.initState();
    _profileDataFuture = _fetchUserData();
  }

  //FutureBuilder에서 값을 읽어 온 후 State 변수에 값을 저장하고 TextFormField에서는 State 변수를 사용하도록 변경
  // 두 개의 콜렉션에 있는 값을 가져오는 메서드
  Future<DocumentSnapshot<Object?>> _fetchUserData() async {
    //uid 확보
    final uid = MyFirebaseService.auth.currentUser!.uid;

    //내 id의 users snapshot 가져 옴
    final collection1Snapshot =
        await MyFirebaseService.firestore.collection('users').doc(uid).get();
    final collection2Snapshot = await MyFirebaseService.firestore
        .collection('profileSettings')
        .doc(uid)
        .get();

    DocumentReference docRef2 =
        MyFirebaseService.firestore.collection('profileSettings').doc(uid);

    //필드가 많고 복잡하고 sorting하기 어렵고 의미가 없어서 아래 쿼리는 쓰지 않는다
    // final collection2Data =
    //     collection2Snapshot.docs.map((doc) => doc.data()).toList();

    // //users 콜렉션에서 name 가져 옴
    // collection1Name = collection1Snapshot.data()!['name'];
    collection1Nickname = collection1Snapshot.data()!['nickname'];

    //profileSettings에서 필드 가져 옴
    collection2Job = collection2Snapshot.data()!['job'];
    collection2Goal = collection2Snapshot.data()!['goal'];
    collection2Shorttermgoal = collection2Snapshot.data()!['shortTermGoal'];
    collection2Shorttermgoaldate =
        collection2Snapshot.data()!['shortTermGoalDate'];
    collection2Shorttermgoalachieved =
        collection2Snapshot.data()!['shortTermGoalAchieved'];
    collection2Midtermgoal = collection2Snapshot.data()!['midTermGoal'];
    collection2Midtermgoaldate = collection2Snapshot.data()!['midTermGoalDate'];
    collection2Midtermgoalachieved =
        collection2Snapshot.data()!['midTermGoalAchieved'];
    collection2Longtermgoal = collection2Snapshot.data()!['longTermGoal'];
    collection2Longtermgoaldate =
        collection2Snapshot.data()!['longTermGoalDate'];
    collection2Longtermgoalachieved =
        collection2Snapshot.data()!['longTermGoalAchieved'];
    collection2Selfintroduction =
        collection2Snapshot.data()!['selfIntroduction'];

    DocumentReference docRef =
        MyFirebaseService.firestore.collection('profileSettings').doc(uid);
    DocumentSnapshot<Object?> docSnapshot = await docRef.get();
    return docSnapshot;
  }

  //프로필 수정 후 저장 기능
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      //uid 확보
      final uid = MyFirebaseService.auth.currentUser!.uid;

      //내 id의 users DocRef 가져 옴
      DocumentReference docRef1 =
          MyFirebaseService.firestore.collection('users').doc(uid);
      DocumentReference docRef2 =
          MyFirebaseService.firestore.collection('profileSettings').doc(uid);

      if (collection1Nickname.isEmptyOrNull) {
        final collection1Snapshot = await MyFirebaseService.firestore
            .collection('users')
            .doc(uid)
            .get();
        collection1Nickname = collection1Snapshot.data()!['nickname'];
      }
      await docRef1.update({'nickname': collection1Nickname});

      //docRef2 가져오기
      docRef2.get().then(
        (doc) {
          if (doc.exists) {
            // docRef2가 존재할 경우
            docRef2.update({'job': collection2Job});
          } else {
            // docRef2가 존재하지 않을 경우
            // profileSettings 콜렉션에 새로운 도큐먼트 생성
            MyFirebaseService.firestore
                .collection('profileSettings')
                .doc(uid)
                .set({
              // 필드와 값을 여기에 추가
              'job': collection2Job,
              'goal': collection2Goal,
              'shortTermGoal': collection2Shorttermgoal,
              'shortTermGoalDate': collection2Shorttermgoaldate,
              'shortTermGoalAchieved': collection2Shorttermgoalachieved,
              'midTermGoal': collection2Midtermgoal,
              'midTermGoalDate': collection2Midtermgoaldate,
              'midTermGoalAchieved': collection2Midtermgoalachieved,
              'longTermGoal': collection2Longtermgoal,
              'longTermGoalDate': collection2Longtermgoaldate,
              'longTermGoalAchieved': collection2Longtermgoalachieved,
              'selfIntroduction': collection2Selfintroduction,
            }).then((value) {
              //도큐먼트가 추가된 후 수행될 코드 작성

              setState(() {
                docRef2.update({'job': collection2Job});
                docRef2.update({'goal': collection2Goal});
                docRef2.update({'shortTermGoalDate': collection2Shorttermgoal});
                docRef2.update(
                    {'shortTermGoalDate': collection2Shorttermgoaldate});
                docRef2.update({
                  'shortTermGoalAchieved': collection2Shorttermgoalachieved
                });
                docRef2.update({'midTermGoal': collection2Midtermgoal});
                docRef2.update({'midTermGoalDate': collection2Midtermgoaldate});
                docRef2.update(
                    {'midTermGoalAchieved': collection2Midtermgoalachieved});
                docRef2.update({'longTermGoal': collection2Longtermgoal});
                docRef2
                    .update({'longTermGoalDate': collection2Longtermgoaldate});
                docRef2.update(
                    {'longTermGoalAchieved': collection2Longtermgoalachieved});
                docRef2
                    .update({'selfIntroduction': collection2Selfintroduction});
              });
            }).catchError((error) {
              // 오류 발생 시 수행될 코드 작성
              Get.snackbar('데이터베이스 에러', '관리자에게 문의해 주세요.');
            });
          }
        },
      );
    }
  }

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
                                    onTap: () {
                                      _getImage();
                                      Navigator.pop(context);
                                    },
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                  ),
                                  GestureDetector(
                                    child: const Text('취소'),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<DocumentSnapshot<Object?>>(
                          future: _profileDataFuture,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              // collection2Job = snapshot.data!['job'];
                              Map<String, dynamic>? data =
                                  snapshot.data?.data() as Map<String, dynamic>;
                              if (data != null) {
                                collection2Job = data['job'] ?? 'Unknown';
                                collection2Goal = data['goal'] ?? 'Unknown';
                                collection2Shorttermgoal =
                                    data['shortTermGoal'] ?? 'Unknown';
                                collection2Shorttermgoaldate =
                                    data['shortTermGoalDate'] ?? 'Unknown';
                                collection2Shorttermgoalachieved =
                                    data['shortTermGoalAchieved'] ?? 'Unknown';
                                collection2Midtermgoal =
                                    data['midTermGoal'] ?? 'Unknown';
                                collection2Midtermgoaldate =
                                    data['midTermGoalDate'] ?? 'Unknown';
                                collection2Midtermgoalachieved =
                                    data['midTermGoalAchieved'] ?? 'Unknown';
                                collection2Longtermgoal =
                                    data['longTermGoal'] ?? 'Unknown';
                                collection2Longtermgoaldate =
                                    data['longTermGoalDate'] ?? 'Unknown';
                                collection2Longtermgoalachieved =
                                    data['longTermGoalAchieved'] ?? 'Unknown';
                                collection2Selfintroduction =
                                    data['selfIntroduction'] ?? 'Unknown';
                                // } else {
                                return Column(
                                  children: [
                                    const SizedBox(height: 16.0),
                                    Text(
                                      collection1Name,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    Row(
                                      children: [
                                        const Text(
                                          '닉네임: ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                collection1Nickname = value;
                                              });
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return '닉네임을 입력하세요.';
                                              }
                                              return null;
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection1Nickname),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Job = value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection2Job),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Goal = value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection2Goal),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Shorttermgoal =
                                                    value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection2Shorttermgoal),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Midtermgoal = value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection2Midtermgoal),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Longtermgoal = value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text: collection2Longtermgoal),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                            onChanged: (value) {
                                              setState(() {
                                                collection2Selfintroduction =
                                                    value;
                                              });
                                            },
                                            maxLines: null,
                                            keyboardType:
                                                TextInputType.multiline,
                                            controller: TextEditingController(
                                                text:
                                                    collection2Selfintroduction),
                                            decoration: const InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      0, 5, 0, 0),
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
                                          _saveProfile();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          '프로필 수정 후 저장',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            }
                            return Container();
                          }),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
