import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:robotic_staff_app/screens/chat/video_chat.dart';

class UserRequestScreen extends StatefulWidget {
  final String staffId; // pass the staff document ID
  final String staffName;

  const UserRequestScreen({
    super.key,
    required this.staffId,
    required this.staffName,
  });

  @override
  State<UserRequestScreen> createState() => _UserRequestScreenState();
}

class _UserRequestScreenState extends State<UserRequestScreen> {
  List<String> joinedUids = [];

  @override
  void initState() {
    super.initState();
    _loadJoinedUsers();
  }

  Future<void> _loadJoinedUsers() async {
    final staffDoc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.staffId)
        .get();

    if (staffDoc.exists) {
      final data = staffDoc.data();
      if (data != null && data['joinedIds'] != null) {
        setState(() {
          joinedUids = List<String>.from(data['joinedIds']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.staffName, style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 2,
      ),
      body: joinedUids.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.info, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No joined users found"),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: joinedUids)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No users found"),
                      ],
                    ),
                  );
                }

                final users = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData =
                        users[index].data() as Map<String, dynamic>;
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(userData['username'] ?? 'No Name'),
                      subtitle: Text(userData['email'] ?? 'No Email'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => VideoChat(
                                callID: widget.staffId,
                                staffName: widget.staffName,
                                staffId: widget.staffId,
                                userId:
                                    userData['uid'], // Replace with actual user ID
                                userName: userData['username'],
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Join",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
