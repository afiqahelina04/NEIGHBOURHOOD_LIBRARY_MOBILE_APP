import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PostDialog extends StatefulWidget {
  const PostDialog({super.key});

  @override
  State<PostDialog> createState() => _PostDialogState();
}


class _PostDialogState extends State<PostDialog> {
  final TextEditingController postController = TextEditingController();
  bool isPostButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    postController.addListener(_onPostTextChanged);
  }

  void _onPostTextChanged() {
    final trimmed = postController.text.trim();
    setState(() {
      isPostButtonEnabled = trimmed.isNotEmpty;
    });
  }

  Future<void> postMessage() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null || postController.text.trim().isEmpty) return;

    final uid = authUser.uid;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};
      final postText = postController.text.trim();

      await FirebaseFirestore.instance.collection('community_posts').add({
        'authorId'        : uid,
        'authorName'      : userData['name'] ?? 'Anonymous',
        'authorEmail'     : authUser.email ?? '',
        'authorProfilePic': userData['profileImage'] ?? 'assets/default_profile.png',
        'content'         : postText,
        'timestamp'       : FieldValue.serverTimestamp(),
        'likes'           : [],
      });

      postController.clear();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post created successfully!')),
        );
      }

    } catch (e) {
      debugPrint('Error posting message: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    postController.removeListener(_onPostTextChanged);
    postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Dialog(
      backgroundColor: const Color(0xFFFFD787),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    
      child: Padding(
        padding: const EdgeInsets.all(20),
    
        child: Column(
          mainAxisSize: MainAxisSize.min,
    
          children: [
    
            const Text(
              'CREATE A POST',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
    
            SizedBox(
              height: 250,
    
              child: TextField(
                controller: postController,
                maxLines: null,
                maxLength: 5000,
                onChanged: (text) => _onPostTextChanged(),
                decoration: InputDecoration(
                  hintText: 'WRITE SOMETHING...',
                  filled: true,
                  fillColor: const Color(0xFFFFA79A),
    
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
    
            ),
            const SizedBox(height: 8),
    
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
    
              children: [
    
                Text(
                  '${postController.text.length} / 5000',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 8),
    
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPostButtonEnabled ? const Color(0xFFFFA79A) : Colors.grey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: isPostButtonEnabled ? postMessage : null,
    
                  child: const Text(
                    'POST',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              
              ],
            ),
          ],
        ),
      ),
    );
  }
}