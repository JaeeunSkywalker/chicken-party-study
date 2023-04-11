import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/views/search_screen/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../services/firebase_service.dart';
import '../home_screen/home.dart';

class StudyDetailsScreen extends StatefulWidget {
  final String newGroupId;

  const StudyDetailsScreen(
      {Key? key, required this.newGroupId, required Study study})
      : super(key: key);

  @override
  State<StudyDetailsScreen> createState() => StudyDetailsScreenState();
}

class StudyDetailsScreenState extends State<StudyDetailsScreen> {
  Map<String, dynamic> studyDetails = {'': ''};

  @override
  void initState() {
    super.initState();
    loadStudyDetails(widget.newGroupId);
  }

  Future<void> loadStudyDetails(String newGroupId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseService().getStudyDetails(widget.newGroupId);
      if (snapshot.exists) {
        setState(() {
          studyDetails = snapshot.data()!;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print(e.toString());
    }
  }

  //참여하기 버튼을 눌렀을 때 실행되는 메서드
  //studiesOnRrecruting 컬렉션의 currentMembers 필드를 업데이트하고,
  //만약 최대 인원에 도달하면 에러 메시지를 표시한다.
  Future<void> joinStudy(String newGroupId) async {
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
        final currentMembers = data1['currentMembers'] as int; //현재 인원
        final maxMembers = data1['numberOfDefaultParticipants'] as int; //최대 인원
        final participants =
            List<String>.from(data1['participants'] ?? <dynamic>[]); //참여 인원

        final String myNickname = data2['nickname'];
        if (participants.contains(myNickname)) {
          Get.snackbar(
            '잠깐만요!',
            '이미 참여되어 있습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (currentMembers >= maxMembers) {
          Get.snackbar(
            '앗...',
            '정원이 초과되어 참여할 수 없습니다.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        participants.add(myNickname);
        await studyRef1.update({
          'currentMembers': currentMembers + 1,
          'participants': participants,
        });
        Get.snackbar(
          'WOW...',
          '스터디 참여에 성공했습니다.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    } catch (e) {
      // ignore: avoid_print
      print('에러 난 이유: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(() => Home(isloggedin: AppCache.getCachedisLoggedin()));
          },
        ),
        title: Align(
            alignment: Alignment.centerLeft,
            child: Text(studyDetails['groupName'] ?? '스터디 상세 화면')),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('스터디 이름'),
            subtitle: Text(studyDetails['groupName'] ?? ''),
          ),
          ListTile(
            title: const Text('스터디 리더'),
            subtitle: Text(studyDetails['studyLeader'] ?? ''),
          ),
          ListTile(
            title: const Text('카테고리'),
            subtitle: Text(
              (List<String>.from(studyDetails['selectedTags'] ?? <dynamic>[]))
                  .map((tag) => '#$tag')
                  .join(', '),
            ),
          ),
          ListTile(
            title: const Text('스터디 참여 가능 인원'),
            subtitle: Text(
                '현재 인원: ${studyDetails['currentMembers']}명 / 최대: ${studyDetails['numberOfDefaultParticipants']}명'),
          ),
          ListTile(
            title: const Text('스터디 설명'),
            subtitle: Text(studyDetails['groupDescription'] ?? ''),
          ),

          ///스터디 참여/나가기 버튼 분기 처리 한 곳///
          FutureBuilder<bool>(
            future: FirebaseService().checkJoinOrNot(widget.newGroupId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                bool isJoined = snapshot.data!;
                return isJoined
                    ? ElevatedButton(
                        onPressed: () async {
                          // 스터디 나가기
                          await leaveStudy(context, widget.newGroupId);
                        },
                        child: const Text('스터디 나가기'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          // 스터디 참여
                          await joinStudy(widget.newGroupId);
                        },
                        child: const Text('스터디 참여하기'),
                      );
              } else if (snapshot.hasError) {
                // 에러 처리
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      '로그인을 해 주세요.',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                );
              } else {
                // 로딩 중
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }

//////////////////////////////////////////////////////////////////////////////////
/////스터디 리브 메서드////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////
  Future<void> leaveStudy(BuildContext context, String studyId) async {
    try {
      final user = FirebaseService.auth.currentUser!.uid;
      final studyRef1 = FirebaseService.firestore
          .collection('studiesOnRecruiting')
          .doc(widget.newGroupId);
      final studyRef2 = FirebaseService.firestore
          .collection('users')
          .doc(user); //닉네임 가져 오기 위해 만듬
      final snapshot1 = await studyRef1.get();
      final snapshot2 = await studyRef2.get();
      if (snapshot1.exists && snapshot2.exists) {
        final data1 = snapshot1.data()!;
        final data2 = snapshot2.data()!;
        final currentMembers = data1['currentMembers'] as int; //현재 인원
        // ignore: unused_local_variable
        final maxMembers = data1['numberOfDefaultParticipants'] as int; //최대 인원
        final participants =
            List<String>.from(data1['participants'] ?? <dynamic>[]); //참여 인원

        final String myNickname = data2['nickname'];

        if (participants.contains(myNickname)) {
          participants.remove(myNickname);
          await studyRef1.update({
            'currentMembers': currentMembers - 1,
            'participants': participants,
          });

          final updatedSnapshot = await studyRef1.get();
          final updatedData = updatedSnapshot.data();
          final updatedCurrentMembers = updatedData?['currentMembers'] as int;

          if (updatedCurrentMembers == 0) {
            final studySnapshot = await studyRef1.get();
            if (studySnapshot.exists) {
              try {
                await studyRef1.delete();

                // ignore: use_build_context_synchronously
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('알림', textAlign: TextAlign.center),
                      content: const Text('스터디가 삭제되었습니다.\n홈으로 돌아갑니다.',
                          textAlign: TextAlign.center),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => Home(
                                  isloggedin: AppCache.getCachedisLoggedin(),
                                ),
                              ),
                              (route) => false,
                            );
                            // 홈으로 이동하는 코드 추가
                          },
                          child: const Center(child: Text('확인')),
                        ),
                      ],
                    );
                  },
                );
                // ignore: empty_catches
              } catch (e) {}
            }
          } else {
            Get.snackbar(
              '흑...',
              '스터디 나가기에 성공했습니다.',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('에러 난 이유: $e');
    }
  }
}
