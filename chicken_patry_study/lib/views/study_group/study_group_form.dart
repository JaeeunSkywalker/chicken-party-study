import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MakeGroupStudy extends StatefulWidget {
  const MakeGroupStudy({super.key});

  @override
  MakeGroupStudyState createState() => MakeGroupStudyState();
}

class MakeGroupStudyState extends State<MakeGroupStudy> {
  //공부해야 함
  // ignore: unused_field
  final _formKey = GlobalKey<FormState>();

  String groupName = '';
  String groupDescription = '';
  String studyGoal = '';
  bool isPublic = true;
  int numberOfDefaultParticipants = 5; //희망 참여 인원
  Duration studyperiod = const Duration(days: 0); //스프린트를 기본으로 해서 기간 기본값은 7일임
  List<String> tags = [];
  int plannedStudyPeriod = 0;

  // ignore: prefer_typing_uninitialized_variables
  late var formattedStartDate;
  // ignore: prefer_typing_uninitialized_variables
  late var formattedEndDate;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  @override
  Widget build(BuildContext context) {
    //Calendar 관련 작업
    TextEditingController durationController =
        TextEditingController(text: '${studyperiod.inDays.abs() + 1}일');
    plannedStudyPeriod = studyperiod.inDays.abs() + 1;
    //Tag 관련 작업
    TextEditingController tagTextEditingController = TextEditingController();

    void addTag() {
      setState(() {
        String tag = tagTextEditingController.text.trim();
        if (tag.isNotEmpty) {
          tags.add(tag);
          tagTextEditingController.clear();
        }
      });
    }

    void removeTag(String tag) {
      setState(() {
        tags.remove(tag);
        tagTextEditingController.clear();
      });
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: <Widget>[
            TextFormField(
              maxLines: null, // null로 설정하면 자동으로 줄바꿈됩니다.
              decoration: const InputDecoration(
                labelText: '그룹명',
              ),
              onChanged: (value) {
                setState(() {
                  groupName = value.trim();
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "그룹명을 입력해 주세요.";
                }
                return null;
              },
            ),
            TextFormField(
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '스터디 소개',
              ),
              onChanged: (value) {
                setState(() {
                  groupDescription = value.trim();
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "스터디 소개를 입력해 주세요.";
                }
                return null;
              },
            ),
            TextFormField(
              maxLines: null,
              decoration: const InputDecoration(
                labelText: '스터디 목표',
              ),
              onChanged: (value) {
                setState(() {
                  studyGoal = value.trim();
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "스터디 목표를 입력해 주세요.";
                }
                return null;
              },
            ),
            Row(
              children: [
                Radio(
                  value: true,
                  groupValue: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = true;
                    });
                  },
                ),
                const Text('공개'),
                Radio(
                  value: false,
                  groupValue: isPublic,
                  onChanged: (value) {
                    setState(() {
                      isPublic = false;
                    });
                  },
                ),
                const Text('비공개'),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: '희망 참여 인원(최소 2명, 최대 25명)',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final parsedValue = int.tryParse(value);
                if (parsedValue == null ||
                    parsedValue < 2 ||
                    parsedValue > 25) {
                  setState(() {
                    numberOfDefaultParticipants = 5;
                  });
                } else {
                  setState(() {
                    numberOfDefaultParticipants = parsedValue;
                  });
                }
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return "희망 참여 인원을 입력해 주세요.\n권장 인원은 5명입니다.";
                }
                return null;
              },
            ),
            GestureDetector(
              onTap: () async {
                var startDate = DateTime.now();
                var endDate = DateTime.now();
                final DateTimeRange? selectedDateRange =
                    await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2033),
                  initialDateRange: DateTimeRange(
                    start: startDate,
                    end: endDate,
                  ),
                );
                if (selectedDateRange != null) {
                  setState(() {
                    startDate = selectedDateRange.start;
                    //DB에 담기는 값 = formattedStartDate,formattedEndDate
                    // ignore: unused_local_variable
                    formattedStartDate = formatter.format(startDate);
                    endDate = selectedDateRange.end;
                    // ignore: unused_local_variable
                    formattedEndDate = formatter.format(endDate);

                    studyperiod = endDate.difference(startDate);
                    //durationController.text = '${studyPeriod.inDays}일';
                  });
                }
                // alertlog가 닫힌 후 durationController를 clear()
                durationController.clear();
                // 다음 event loop까지 기다리기 위한 delay
                //await Future.delayed(Duration.zero);
              },
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: '스터디 참여 기간',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final parsedValue = int.tryParse(value);
                    if (parsedValue != null) {
                      setState(() {
                        studyperiod = Duration(days: parsedValue);
                        plannedStudyPeriod = studyperiod.inDays;
                        // ignore: unused_local_variable
                      });
                    }
                  },
                  controller: durationController,
                ),
              ),
            ),
            TextFormField(
              controller: tagTextEditingController,
              decoration: const InputDecoration(
                hintText: '스터디 검색 시 적용될 태그를 입력해 주세요',
                prefixText: '#',
              ),
              onFieldSubmitted: (_) => addTag(),
            ),
            Expanded(
              child: Wrap(
                spacing: 8.0, // 각 Chip 사이의 간격 조정
                runSpacing: 4.0, // 줄바꿈 후 위젯 간 간격 조정
                children: tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        deleteIcon: const Icon(Icons.clear),
                        onDeleted: () => removeTag(tag),
                      ),
                    )
                    .toList(),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                //로그인한 사용자만 FAB를 볼 수 있고 스터디를 등록할 수 있음
                FirebaseFirestore firestore = FirebaseFirestore.instance;
                CollectionReference studiesRef =
                    firestore.collection('studiesOnRecruiting');

                studiesRef.add({
                  'groupName': groupName,
                  'groupDescription': groupDescription,
                  'studyGoal': studyGoal,
                  'isPublic': isPublic,
                  'numberOfDefaultParticipants': numberOfDefaultParticipants,
                  'studyPeriod': plannedStudyPeriod,
                  'selectedTags': tags,
                  'startDate': formattedStartDate,
                  'endDate': formattedEndDate,
                }).then((value) {
                  // 데이터 추가 성공
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('스터디를 만들었습니다.'),
                      content: const Text('확인을 누르면 홈 화면으로 이동합니다.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .popUntil((route) => route.isFirst);
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                }).catchError((error) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('스터디를 만들지 못 했습니다.'),
                      content: Text('에러: $error'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: const Text('등록'),
            ),
          ],
        ),
      ),
    );
  }
}
