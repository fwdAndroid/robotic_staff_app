import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  Future<DocumentSnapshot?> _getUserDetails(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, requestSnapshot) {
          if (requestSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!requestSnapshot.hasData || requestSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No requests found"));
          }

          final requests = requestSnapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final requestData =
                  requests[index].data() as Map<String, dynamic>;
              final userId = requestData['userId'];

              return FutureBuilder<DocumentSnapshot?>(
                future: _getUserDetails(userId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  if (!userSnapshot.data!.exists) {
                    return const ListTile(title: Text("User not found"));
                  }

                  final userData =
                      userSnapshot.data!.data() as Map<String, dynamic>;
                  final name = userData['name'] ?? 'Unknown';
                  final profileImage = userData['profileImage'] ?? '';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profileImage.isNotEmpty
                            ? NetworkImage(profileImage)
                            : const AssetImage(
                                    'assets/images/default_avatar.png',
                                  )
                                  as ImageProvider,
                      ),
                      title: Text(name),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // ✅ Handle Join button action here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Joined with $name")),
                          );
                        },
                        child: const Text("Join"),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
