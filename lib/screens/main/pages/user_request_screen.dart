import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserRequestScreen extends StatefulWidget {
  final String staffId; // pass the staff document ID

  const UserRequestScreen({super.key, required this.staffId});

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
    // 1. Get staff document
    final staffDoc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.staffId)
        .get();

    if (staffDoc.exists) {
      final data = staffDoc.data();
      if (data != null && data['joinedUuid'] != null) {
        setState(() {
          joinedUids = List<String>.from(data['joinedUuid']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (joinedUids.isEmpty) {
      return const Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.info, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("No joined users found"),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
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
            final userData = users[index].data() as Map<String, dynamic>;
            return ListTile(
              leading: const Icon(Icons.person),
              title: Text(userData['username'] ?? 'No Name'),
              subtitle: Text(userData['email'] ?? 'No Email'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: Text("Join", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            );
          },
        );
      },
    );
  }
}
