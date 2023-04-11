import 'package:chicken_patry_study/services/firebase_service.dart';
import 'package:chicken_patry_study/views/study_details_screen/study_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../home_screen/home.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  //검색 결과가 저장되는 곳
  late List<Study> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = [];
  }

  Future<void> _search() async {
    final searchValue = _searchController.text.trim();
    if (searchValue.isNotEmpty) {
      final query = searchValue.toLowerCase();
      final studiesRef =
          FirebaseService.firestore.collection('studiesOnRecruiting');
      final snapshot = await studiesRef.get();
      final List<Study> searchResults = [];
      if (snapshot.docs.isNotEmpty) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          if (data['groupName'].toLowerCase().contains(query) ||
              data['groupDescription'].toLowerCase().contains(query) ||
              data['selectedTags'].toString().toLowerCase().contains(query) ||
              data['studyGoal'].toLowerCase().contains(query) ||
              data['studyLeader'].toLowerCase().contains(query)) {
            searchResults.add(Study.fromSnapshot(doc));
          }
        }
      }
      setState(() {
        _searchResults = searchResults;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.to(() => Home(
                isloggedin:
                    FirebaseService.auth.currentUser != null ? true : false));
          },
        ),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '검색',
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              textAlign: TextAlign.left,
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: '검색어를 입력하세요',
                suffixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final study = _searchResults[index];
                return ListTile(
                  title: Text(study.groupName),
                  subtitle: Text(study.groupDescription),
                  onTap: () async {
                    // ignore: unused_local_variable
                    final docSnapshot = await FirebaseFirestore.instance
                        .collection('studiesOnRecruiting')
                        .doc(study.newGroupId)
                        .get();
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => StudyDetailsScreen(
                        study: study,
                        newGroupId: study.newGroupId,
                      ),
                    ));
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Study {
  final String groupDescription;
  final String groupName;
  final List<dynamic> selectedTags;
  final String studyGoal;
  final String studyLeader;
  final String newGroupId;

  Study({
    required this.groupDescription,
    required this.groupName,
    required this.selectedTags,
    required this.studyGoal,
    required this.studyLeader,
    required this.newGroupId,
  });

  factory Study.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Study(
      groupDescription: data['groupDescription'],
      groupName: data['groupName'],
      selectedTags: data['selectedTags'],
      studyGoal: data['studyGoal'],
      studyLeader: data['studyLeader'],
      newGroupId: data['newGroupId'],
    );
  }

  factory Study.fromJson(Map<String, dynamic> json) {
    return Study(
      groupName: json['groupName'],
      groupDescription: json['groupDescription'],
      selectedTags: List<String>.from(json['selectedTags']),
      studyGoal: json['studyGoal'],
      studyLeader: json['studyLeader'],
      newGroupId: json['newGroupId'],
    );
  }
}
