import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';

class StudyDetailsScreen extends StatefulWidget {
  final String newGroupId;

  const StudyDetailsScreen({Key? key, required this.newGroupId})
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(studyDetails['groupName'] ?? '스터디 상세 화면'),
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
          ElevatedButton(
            onPressed: () async {
              if (studyDetails['currentMembers'] <
                  studyDetails['numberOfDefaultParticipants']) {
                // 스터디 참여
                await joinStudy(studyDetails['newGroupId']);
              } else {
                // 스터디 참여 불가
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('인원 문제로 스터디에 참여할 수 없습니다.')),
                );
              }
            },
            child: const Text('참여하기'),
          ),
        ],
      ),
    );
  }

////////////////////////////////////////////////////////////////////////////////
  ///스터디 조인 메서드////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
  Future<void> joinStudy(String studyId) async {
    final docRef = FirebaseFirestore.instance
        .collection('studiesOnRecruiting')
        .doc(studyDetails['currentMembers']);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final currentMembers = doc.data()!['currentMembers'] as int;
      final maxMembers = doc.data()!['numberOfDefaultParticipants'] as int;

      if (currentMembers < maxMembers) {
        transaction.update(docRef, {
          'currentMembers': currentMembers + 1,
        });
      } else {
        // 참여 가능한 인원 수를 초과하면 에러 처리
        throw Exception('스터디 정원이 초과했습니다.');
      }
    });
  }

////////////////////////////////////////////////////////////////////////////////
  ///스터디 리브 메서드////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
  Future<void> leaveStudy(String studyId) async {
    final docRef = FirebaseFirestore.instance
        .collection('studiesOnRecruiting')
        .doc(studyDetails['currentMembers']);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      final currentMembers = doc.data()!['currentMembers'] as int;

      if (currentMembers > 0) {
        transaction.update(docRef, {
          'currentMembers': currentMembers - 1,
        });
      } else {
        // 현재 인원 수가 0보다 작을 수 없음
        throw Exception('스터디 진행이 가능한 인원수가 아닙니다.');
      }
    });
  }
}
