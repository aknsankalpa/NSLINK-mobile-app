import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nslink_new/admin/homeScreen.dart';
import 'package:nslink_new/admin/singleLeaveView.dart';

class ViewLeaveScreen extends StatefulWidget {
  const ViewLeaveScreen({super.key});

  @override
  _ViewLeaveScreenState createState() => _ViewLeaveScreenState();
}

class _ViewLeaveScreenState extends State<ViewLeaveScreen> {
  List<Map<String, dynamic>> leaveRequests = [];

  @override
  void initState() {
    super.initState();
    fetchLeaveRequests();
  }

  Future<void> fetchLeaveRequests() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('requestLeave').get();

      List<Map<String, dynamic>> requests =
          querySnapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            return data;
          }).toList();

      print(requests); // For debugging

      setState(() {
        leaveRequests = requests;
      });
    } catch (e) {
      print('Error fetching leave requests: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leave requests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Leaves"),
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);  // Changed from pushReplacement
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
        child:
            leaveRequests.isEmpty
                ? const Center(child: Text('No leave requests pending'))
                : ListView.builder(
                  itemCount: leaveRequests.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: RequestCard(
                        leaveData: leaveRequests[index],
                        onView: () async {
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => SingleLeaveViewScreen(
                                    leaveData: leaveRequests[index],
                                  ),
                            ),
                          );
                          if (shouldRefresh == true) {
                            fetchLeaveRequests(); // Refresh the list
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

class RequestCard extends StatelessWidget {
  final Map<String, dynamic> leaveData;
  final VoidCallback onView;

  const RequestCard({super.key, required this.leaveData, required this.onView});

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
              leaveData['LeaveFrom'] ?? 'Unknown Date',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              leaveData['leaveId'] ?? 'No ID',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onView,
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
