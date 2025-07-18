import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nslink_new/lecture/lectureDashboard.dart';
import 'package:nslink_new/lecture/singleMeetingViewScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MeetingListScreen extends StatefulWidget {
  const MeetingListScreen({super.key});

  @override
  _MeetingListScreenState createState() => _MeetingListScreenState();
}

class _MeetingListScreenState extends State<MeetingListScreen> {
  List<Map<String, dynamic>> meetingList = [];
  String? lecturerFaculty;

  @override
  void initState() {
    super.initState();
    _loadLecturerFacultyAndMeetings();
  }

  Future<void> _loadLecturerFacultyAndMeetings() async {
    try {
      // Get lecturer's email from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');

      if (email != null) {
        // Get lecturer's faculty from addLecture collection
        final QuerySnapshot lecturerDoc = await FirebaseFirestore.instance
            .collection('addLecture')
            .where('lectureEmail', isEqualTo: email)
            .get();

        if (lecturerDoc.docs.isNotEmpty) {
          lecturerFaculty = lecturerDoc.docs.first['lectureFaculty'];
          await fetchMeetings();
        }
      }
    } catch (e) {
      print('Error loading lecturer faculty: $e');
    }
  }

  Future<void> fetchMeetings() async {
    try {
      if (lecturerFaculty == null) return;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('scheduleMeetings')
          .where('meetingFaculty', isEqualTo: lecturerFaculty)
          .get();

      List<Map<String, dynamic>> fetchedMeetings = querySnapshot.docs.map((
        doc,
      ) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        meetingList = fetchedMeetings;
      });
    } catch (e) {
      print('Error fetching meetings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${lecturerFaculty ?? ''} Staff Meetings"),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LectureDashboard()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child: meetingList.isEmpty
            ? const Center(
                child: Text('No meetings scheduled for your faculty'),
              )
            : ListView.builder(
                itemCount: meetingList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: RequestCard(
                      type: meetingList[index]['meetingType'] ?? 'Unknown',
                      date: meetingList[index]['meetingDate'] ?? 'No Date',
                      time: meetingList[index]['meetingTime'] ?? 'No Time',
                      meetingData: meetingList[index],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final String date;
  final String time;
  final String type;
  final Map<String, dynamic> meetingData;

  const RequestCard({
    super.key,
    required this.date,
    required this.time,
    required this.type,
    required this.meetingData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              date,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: $time',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            Text(
              'Type: $type',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SingleMeetingViewScreen(meeting: meetingData),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF26C485),
                foregroundColor: Colors.white,
                minimumSize: const Size(80, 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              child: const Text('View', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }
}
