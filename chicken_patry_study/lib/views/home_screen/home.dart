import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart' as intl;

import '../../widgets/appbar_widget.dart';
import '../study_details/study_details.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: homeAppbarWidget(context),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('studiesOnRecruiting')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
      ),
    );
  }
}
