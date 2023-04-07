import 'package:chicken_patry_study/app_cache/app_cache.dart';
import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/widgets/appbar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../consts/consts.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../study_details_screen/study_details_screen.dart';
import '../study_group/study_group_form.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  final bool isloggedin;
  const Home({Key? key, required this.isloggedin}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  var isloggedin = false;

  @override
  void initState() {
    super.initState();
    isloggedin = widget.isloggedin;
  }

  List<BottomNavigationBarItem> items = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: '홈',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.search),
      label: '검색',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: '내 프로필',
    ),
  ];

  late DateTime startdate;
  late DateTime enddate;
  String newGroupId = '';
  List<dynamic> participants = [];
  bool isParticipant = false;

  Future<bool> getNickname1() async {
    // users 콜렉션에서 nickname 가져오는 메서드
    String uid = FirebaseService.auth.currentUser!.uid;
    DocumentSnapshot<Map<String, dynamic>> nicknameSnapshot =
        await FirebaseService.firestore.collection('users').doc(uid).get();
    final String nickname = nicknameSnapshot.get('nickname');
    bool isParticipant = participants.contains(nickname);
    return isParticipant;
  }

  Future getNickname2() async {
    isParticipant = await getNickname1();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(widget.isloggedin),
        bottomNavigationBar: MainBottomNavigationBar(
          items: items,
        ),
        floatingActionButton: (widget.isloggedin &&
                AppCache.getCachedisLoggedin() == true)
            ? FloatingActionButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        title: Text('스터디 그룹 만들기', textAlign: TextAlign.center),
                        content: MakeGroupStudy(),
                      );
                    },
                  );
                },
                child: const Icon(Icons.add),
              )
            : null,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('studiesOnRecruiting')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                  child: CircularProgressIndicator(
                color: red,
              ));
            }
            final studios = snapshot.data!.docs;
            return Container(
              decoration: BoxDecoration(
                image: const DecorationImage(
                  image: NetworkImage(mainBodyImage),
                  fit: BoxFit.cover,
                ),
                border: Border(
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.grey[300]!,
                  ),
                ),
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: studios.length,
                itemBuilder: (BuildContext context, int index) {
                  final studio = studios[index];
                  String startdate = (studio['startDate']);
                  String enddate = (studio['endDate']);

                  //스터디 공개 유무에 따라 노출 처리
                  //isPublic이 false인 스터디는 참여자에게만 노출된다.
                  bool isPublic = studio['isPublic'];
                  participants = studio['participants'];

                  //public방이거나 내가 참여한 방이어야만 뜬다
                  if (true) {
                    return InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          color: white,
                          border: Border(
                            bottom: BorderSide(
                              width: 2,
                              color: Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(studio['studyGoal']),
                          subtitle: Text(studio['groupDescription']),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('시작일: $startdate'),
                              Text('마감일: $enddate'),
                            ],
                          ),
                          onTap: () async {
                            final docSnapshot = await FirebaseFirestore.instance
                                .collection('studiesOnRecruiting')
                                .doc(studio.id)
                                .get();
                            // 이후 studyData를 study_details_screen으로 전달하여 사용할 수 있다.
                            // ignore: unused_local_variable
                            final studyData = docSnapshot.data();
                            Get.to(() =>
                                StudyDetailsScreen(newGroupId: studio.id));
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
