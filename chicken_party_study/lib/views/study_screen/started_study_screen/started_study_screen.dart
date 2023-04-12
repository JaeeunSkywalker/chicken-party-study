import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/firebase_service.dart';
import '../../home_screen/home.dart';

class StartedStudyScreen extends StatefulWidget {
  final String newGroupId;

  const StartedStudyScreen({Key? key, required this.newGroupId})
      : super(key: key);

  @override
  StartedStudyScreenState createState() => StartedStudyScreenState();
}

class StartedStudyScreenState extends State<StartedStudyScreen> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<List<String>>> getMyStudyParticipantList() async {
    final user = await FirebaseService.firestore
        .collection('users')
        .doc(FirebaseService.auth.currentUser!.uid)
        .get();
    final nickname = user.data()!['nickname'];

    final snapshot = await FirebaseService.firestore
        .collection('studiesOnRecruiting')
        .where('participants', arrayContains: nickname)
        .get();

    final List<List<String>> participantsList = snapshot.docs.map((doc) {
      final List<dynamic> participants = doc.get('participants');
      return participants.cast<String>();
    }).toList();

    return participantsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => const Home(isloggedin: true));
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '스터디 상세 페이지',
          ),
        ),
      ),
      body: FutureBuilder<List<List<String>>>(
        future: getMyStudyParticipantList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final participantsList = snapshot.data!;
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: participantsList
                        .expand((list) => list) // 각 list를 풀어서 하나의 리스트로 만듦
                        .toSet() // 중복 제거
                        .map((value) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  const CircleAvatar(
                                    radius: 35,
                                    backgroundImage: AssetImage(
                                        'assets/images/default_profile_image.png'),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    value,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('에러가 발생했습니다.'));
          }
        },
      ),
    );
  }
}
