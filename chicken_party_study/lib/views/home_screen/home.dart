import 'package:chicken_patry_study/widgets/appbar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../consts/consts.dart';
import '../../flutter_hooks/app_lifecycle_observer.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../study_details_screen/study_details_screen.dart';
import '../study_group/study_group_form.dart';

// ignore: must_be_immutable
class Home extends StatefulWidget {
  late bool isloggedin;
  String nickname = '';
  Home({Key? key, required this.isloggedin}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final box = GetStorage();
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      box.write('isLoggedin', false);
    }
  }

  //flutter_hooks 적용
  //실행하려면 함수 호출하면 됨
  //일반적으로 이런 함수는 해당 상태를 관리하는 위젯의 클래스 내부에 작성된다.
  void useLogoutOnAppCloseEffect() {
    useEffect(() {
      final box = GetStorage();
      void callback() {
        // 로그인 캐시 삭제 코드
        box.write('isLoggedin', false);
      }

      WidgetsBinding.instance.addObserver(
        AppLifecycleObserver(
          didPause: callback,
          didTerminate: callback,
        ),
      );
      return () {
        WidgetsBinding.instance.removeObserver(this);
      };
    }, []);
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: appBarWidget(widget.isloggedin),
        bottomNavigationBar: MainBottomNavigationBar(
          items: items,
        ),
        floatingActionButton: widget.isloggedin == true
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
                  //isPublic이 false인 스터디는 개설자에게만 노출된다.
                  if (studio['isPublic'] == true) {
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
                  } else {
                    return Container();
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
