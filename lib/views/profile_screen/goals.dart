import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  //상태 변수 선언
  bool? _shortTermGoalChecked = false; //단기 체크박스
  bool? _mediumTermGoalChecked = false; //중기 체크박스
  bool? _longTermGoalChecked = false; //장기 체크박스

  int _shortTermGoalProgressValue = 0;
  int _mediumTermGoalProgressValue = 0;
  int _longTermGoalProgressValue = 0;
  //int? _lifeGoalProgressValue = 0;

  // initState 함수를 이용해 초기 데이터 로드
  @override
  void initState() {
    super.initState();
    _loadGoalsFromFirestore();
  }

  //파이어스토어 관련 작업
  // 파이어스토어 인스턴스 생성
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // 사용자 uid
  final String _uid = FirebaseService.auth.currentUser!.uid;

  // Firestore에서 데이터 읽어오기
  Future<void> _loadGoalsFromFirestore() async {
    try {
      // 각 목표 컬렉션에서 데이터 읽어오기
      DocumentSnapshot goalStatusSnapshot =
          await _firestore.collection('profiles').doc(_uid).get();
      // 각 필드에서 데이터 추출
      setState(() {
        _shortTermGoalChecked = goalStatusSnapshot['short_term_checked'];
        _shortTermGoalProgressValue = goalStatusSnapshot['short_term_progress'];

        _mediumTermGoalChecked = goalStatusSnapshot['medium_term_checked'];
        _mediumTermGoalProgressValue =
            goalStatusSnapshot['medium_term_progress'];

        _longTermGoalChecked = goalStatusSnapshot['long_term_checked'];
        _longTermGoalProgressValue = goalStatusSnapshot['long_term_progress'];
      });
    } catch (e) {
      // ignore: avoid_print
      print('파이어베이스에서 로딩 중 오류가 발생했습니다.: $e');
    }
  }

  // Firestore에 데이터 저장
  Future<void> _saveGoalsToFirestore() async {
    try {
      await _firestore.collection('profiles').doc(_uid).set(
        {
          'short_term_checked': _shortTermGoalChecked,
          'medium_term_checked': _mediumTermGoalChecked,
          'long_term_checked': _longTermGoalChecked,
          'short_term_progress': _shortTermGoalProgressValue,
          'medium_term_progress': _mediumTermGoalProgressValue,
          'long_term_progress': _longTermGoalProgressValue,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      // ignore: avoid_print
      print('파이어스토어에 데이터를 저장하던 중 오류가 발생했습니다.: $e');
    }
  }

  //각 체크박스가 변경되었을 때 호출될 콜백 함수 정의
  void _onGoalChecked(bool? checked, String goalType) {
    setState(() {
      switch (goalType) {
        case 'short':
          _shortTermGoalChecked = checked!;
          _shortTermGoalChecked == true
              ? _shortTermGoalProgressValue = 100
              : _shortTermGoalProgressValue = 0;
          _saveGoalsToFirestore();
          break;
        case 'medium':
          _mediumTermGoalChecked = checked!;
          _mediumTermGoalChecked == true
              ? _mediumTermGoalProgressValue = 100
              : _mediumTermGoalProgressValue = 0;
          _saveGoalsToFirestore();
          break;
        case 'long':
          _longTermGoalChecked = checked!;
          _longTermGoalChecked == true
              ? _longTermGoalProgressValue = 100
              : _longTermGoalProgressValue = 0;
          _saveGoalsToFirestore();
          break;
      }
    });
  }

  //getter 써서 값 불러 오면 매번 서버에서 데이터 불러 오는 것보다 당연히 더 빠르고
  //사용자에게 부담이 적다
  int get _lifeGoalProgressValue {
    final checkedGoalsCount = [
      _shortTermGoalChecked,
      _mediumTermGoalChecked,
      _longTermGoalChecked
    ].where((element) => element!).length;

    return (checkedGoalsCount == 3)
        ? 100
        : (checkedGoalsCount * 33).clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<DocumentSnapshot>>(
              future: Future.wait([
                FirebaseFirestore.instance
                    .collection('profiles')
                    .doc(FirebaseService.auth.currentUser!.uid)
                    .get(),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  final profileDoc = snapshot.data!;
                  if (profileDoc.isNotEmpty) {
                    final profileData =
                        profileDoc[0].data() as Map<String, dynamic>?;

                    return Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '나 잘하고 있나요?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            '인생 목표: ${profileData?['lifegoal'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.yellow[700],
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _lifeGoalProgressValue / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                '목표 달성률: $_lifeGoalProgressValue%',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '단기 목표: ${profileData?['shorttermgoal'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: _shortTermGoalChecked,
                                onChanged: (checked) =>
                                    _onGoalChecked(checked, 'short'),
                              ),
                              Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.yellow[700],
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _shortTermGoalProgressValue
                                      .toDouble(), // 프로그레스 값 변경
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                '목표 달성률: $_shortTermGoalProgressValue%',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '중기 목표: ${profileData?['midtermgoal'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: _mediumTermGoalChecked,
                                onChanged: (checked) =>
                                    _onGoalChecked(checked, 'medium'),
                              ),
                              Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.yellow[700],
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value:
                                      _mediumTermGoalProgressValue.toDouble() /
                                          100, // 프로그레스 값 변경
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                '목표 달성률: $_mediumTermGoalProgressValue%',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            '장기 목표: ${profileData?['longtermgoal'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Checkbox(
                                value: _longTermGoalChecked,
                                onChanged: (checked) =>
                                    _onGoalChecked(checked, 'long'),
                              ),
                              Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.yellow[700],
                              ),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _longTermGoalProgressValue.toDouble() /
                                      100, // 프로그레스 값 변경
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.pinkAccent,
                                ),
                              ),
                              Text(
                                '목표 달성률: $_longTermGoalProgressValue%',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            '자기 소개',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 24.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            '${profileData?['selfintroduction'] ?? ''}',
                            style: const TextStyle(
                              fontSize: 18.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
