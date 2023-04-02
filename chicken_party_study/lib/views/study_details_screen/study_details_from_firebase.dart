// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../../services/firebase_service.dart';

// class StudyDetailsScreen extends StatefulWidget {
//   final String newGroupId;

//   const StudyDetailsScreen({Key? key, required this.newGroupId})
//       : super(key: key);

//   @override
//   StudyDetailsScreenState createState() => StudyDetailsScreenState();
// }

// class StudyDetailsScreenState extends State<StudyDetailsScreen> {
//   late Map<String, dynamic> studyDetails;

//   // ignore: prefer_typing_uninitialized_variables
//   var newGroupId;

//   @override
//   void initState() {
//     super.initState();
//     loadStudyDetails(newGroupId);
//   }

//   Future<void> loadStudyDetails(newGroupId) async {
//     try {
//       final DocumentSnapshot<Map<String, dynamic>> snapshot =
//           await FirebaseService().getStudyDetails(widget.newGroupId);
//       if (snapshot.exists) {
//         setState(() {
//           studyDetails = snapshot.data()!;
//         });
//       }
//     } catch (e) {
//       // ignore: avoid_print
//       print(e.toString());
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // ignore: unnecessary_null_comparison
//     if (studyDetails == null) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     final groupName = studyDetails['groupName'];
//     final groupDescription = studyDetails['groupDescription'];
//     final studyGoal = studyDetails['studyGoal'];
//     // ignore: unused_local_variable
//     final isPublic = studyDetails['isPublic'];
//     final numberOfDefaultParticipants =
//         studyDetails['numberOfDefaultParticipants'];
//     final studyPeriodInDays = studyDetails['studyPeriod'];
//     final tags = studyDetails['selectedTags'];
//     final formattedStartDate = studyDetails['startDate'];
//     final formattedEndDate = studyDetails['endDate'];
//     final nickname = studyDetails['studyLeader'];

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(groupName),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Group Description',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(groupDescription),
//               const SizedBox(height: 16),
//               const Text('Study Goal',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(studyGoal),
//               const SizedBox(height: 16),
//               const Text('Number of Default Participants',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(numberOfDefaultParticipants.toString()),
//               const SizedBox(height: 16),
//               const Text('Study Period',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text('$studyPeriodInDays days'),
//               const Text('Selected Tags',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Wrap(
//                 spacing: 8,
//                 children: tags.map<Widget>((tag) {
//                   return Chip(
//                     label: Text(tag),
//                     backgroundColor: Colors.grey[300],
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 16),
//               const Text('Start Date',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(formattedStartDate),
//               const SizedBox(height: 16),
//               const Text('End Date',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(formattedEndDate),
//               const SizedBox(height: 16),
//               const Text('Study Leader',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               Text(nickname),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
