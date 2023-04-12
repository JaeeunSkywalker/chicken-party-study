import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../services/firebase_service.dart';
import '../../home_screen/home.dart';

class StartedStudyScreen extends StatefulWidget {
  const StartedStudyScreen({Key? key}) : super(key: key);

  @override
  StartedStudyScreenState createState() => StartedStudyScreenState();
}

class StartedStudyScreenState extends State<StartedStudyScreen> {
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
              '스터디 진행 상황',
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
              // return Row(
              //   children: participantsList.map((list) {
              //     return Column(
              //       children: list.map((value) {
              //         return Text(value);
              //       }).toList(),
              //     );
              //   }).toList(),
              // );
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: participantsList
                      .expand((list) => list) // 각 list를 풀어서 하나의 리스트로 만듦
                      .toSet() // 중복 제거
                      .map((value) => Text(value))
                      .map((widget) => CircleAvatar(
                            radius: 30,
                            backgroundImage: const AssetImage(
                                'assets/images/default_profile_image.png'),
                            child: widget,
                          ))
                      .toList(),
                ),
              );
            } else {
              return const Center(child: Text('에러가 발생했습니다.'));
            }
          },
        ));
  }
}
