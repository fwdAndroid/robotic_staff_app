import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final CollectionReference chatCollection;
  final String currentUserId;
  final String currentUserName;

  const ChatScreen({
    super.key,
    required this.chatCollection,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController chatController = TextEditingController();

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;
    await widget.chatCollection.add({
      'senderId': widget.currentUserId,
      'senderName': widget.currentUserName,
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    });
  }

  Future<void> pickAndShareFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      final ref = FirebaseStorage.instance.ref('shared_files/$fileName');
      await ref.putFile(file);
      String downloadUrl = await ref.getDownloadURL();

      await widget.chatCollection.add({
        'senderId': widget.currentUserId,
        'senderName': widget.currentUserName,
        'content': downloadUrl,
        'fileName': fileName,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'file',
      });
    }
  }

  Widget buildFilePreview(String fileName, String url) {
    final ext = fileName.toLowerCase();
    if (ext.endsWith('.png') ||
        ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.gif')) {
      return GestureDetector(
        onTap: () => launchUrl(Uri.parse(url)),
        child: Image.network(url, height: 150, fit: BoxFit.cover),
      );
    } else if (ext.endsWith('.pdf')) {
      return ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => launchUrl(Uri.parse(url)),
        ),
      );
    } else {
      return ListTile(
        title: Text(fileName),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => launchUrl(Uri.parse(url)),
        ),
      );
    }
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    final data = doc.data()! as Map<String, dynamic>;
    final sender = data['senderName'] ?? 'Unknown';
    final type = data['type'] ?? 'text';
    final content = data['content'] ?? '';
    if (type == 'file') {
      final fileName = data['fileName'] ?? 'file';
      return ListTile(
        title: Text(
          "$sender sent a file:",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: buildFilePreview(fileName, content),
      );
    } else {
      return ListTile(title: Text("$sender: $content"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.chatCollection
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No messages"));
                }

                var docs = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return buildMessageItem(docs[index]);
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.orange),
                  onPressed: pickAndShareFile,
                ),
                Expanded(
                  child: TextField(
                    controller: chatController,
                    decoration: const InputDecoration(
                      hintText: "Type a message...",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onSubmitted: (val) {
                      sendTextMessage(val);
                      chatController.clear();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    sendTextMessage(chatController.text);
                    chatController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
