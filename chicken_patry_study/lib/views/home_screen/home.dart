import 'package:chicken_patry_study/consts/consts.dart';
import 'package:chicken_patry_study/views/auth_screen/signin_screen/signin_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

import '../login_screen/login_screen.dart';
import '../study_details/study_details.dart';

final nicknameProvider = StateProvider<String>((ref) => '');

class Home extends ConsumerWidget {
  const Home({Key? key}) : super(key: key);

//   @override
//   // ignore: library_private_types_in_public_api
//   _HomeState createState() => _HomeState();
// }

// class _HomeState extends State<Home> {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Vx.black,
          automaticallyImplyLeading: false,
          title: (true)
              ? Text(
                  ', 오늘도 치파스!',
                  style: const TextStyle(
                    color: Colors.black, // 글자색 블랙
                    fontWeight: FontWeight.bold, // 글자 굵기 설정
                    fontSize: 20, // 글자 크기 설정
                  ),
                )
              : Text(''),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Get.to(() => const LoginScreen());
              },
              child: const Text('로그인'),
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: const TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Get.to(() => const SigninScreen());
              },
              child: const Text('회원가입'),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('studiesOnRecruiting')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator(); // 로딩 중이면 CircularProgressIndicator 출력
            }
            final studios = snapshot.data!.docs;
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: studios.length,
              itemBuilder: (BuildContext context, int index) {
                final studio = studios[index];
                //파이어스토어 timestamp 포맷 바꾸기
                DateTime fromdate = (studio['fromdate'] as Timestamp).toDate();
                DateTime todate = (studio['todate'] as Timestamp).toDate();

                String formattedFromDate =
                    intl.DateFormat('yyyy-MM-dd').format(fromdate);
                String formattedToDate =
                    intl.DateFormat('yyyy-MM-dd').format(todate);
                return InkWell(
                  onTap: () {
                    Get.to(() => const StudyDetails());
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1,
                          color: Colors.grey[300]!,
                        ),
                      ),
                    ),
                    child: ListTile(
                      title: Text(studio['title']),
                      subtitle: Text(studio['description']),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('시작일: $formattedFromDate'),
                          Text('마감일: $formattedToDate'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ));
  }
}
