import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_dialog.dart';


class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isAdmin = currentUser?.email == 'admin@gmail.com';

    return Scaffold(
      resizeToAvoidBottomInset: true,
      
      appBar: AppBar(
        centerTitle: true,
      
        title: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      
          decoration: BoxDecoration(
            color: const Color(0xFFFFA79A),
            borderRadius: BorderRadius.circular(12),
          ),
      
          child: const Text(
            'SHARE YOUR THOUGHTS!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      
      body: SafeArea(
      
        child: Column(
      
          children: [
      
            Expanded(
      
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('community_posts')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
      
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final posts = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: posts.length + 1,
      
                    itemBuilder: (context, index) {
                      if (index == 0) return const SizedBox(height: 40);

                      final doc = posts[index - 1];
                      final post = doc.data() as Map<String, dynamic>;
                      final likes = List<String>.from(post['likes'] ?? []);
                      final currentUserId = currentUser?.uid;

                      return Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: post['authorEmail'] == 'admin@gmail.com'
                              ? const Color.fromARGB(255, 131, 224, 255)
                              : const Color.fromARGB(255, 255, 222, 217),
                          borderRadius: BorderRadius.circular(12),
                        ),
                     
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                     
                          children: [
                     
                            Row(
                     
                              children: [
                     
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: _getProfileImageProvider(post['authorProfilePic']),
                                ),
                                const SizedBox(width: 8),
                     
                                Expanded(
                                  child: Text(
                                    post['authorName'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: post['authorEmail'] == 'admin@gmail.com'
                                          ? Colors.red
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                                if (isAdmin)
                              
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    tooltip: 'Delete Post',
                                    onPressed: () => _confirmDeletePost(context, doc.id),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          
                            Text(post['content'] ?? '', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 8),
                          
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    likes.contains(currentUserId)
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: likes.contains(currentUserId) ? Colors.red : Colors.black,
                                  ),
                                  onPressed: () async {
                                    if (currentUserId == null) return;
                                    final docRef = doc.reference;
                                    if (likes.contains(currentUserId)) {
                                      await docRef.update({
                                        'likes': FieldValue.arrayRemove([currentUserId])
                                      });
                                    } else {
                                      await docRef.update({
                                        'likes': FieldValue.arrayUnion([currentUserId])
                                      });
                                    }
                                  },
                                ),
                                Text('${likes.length}'),
                              ],
                            ),

                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const PostDialog(),
        ),
        icon: const Icon(Icons.edit),
        label: const Text('NEW POST'),
        backgroundColor: const Color(0xFFFFA79A),
      ),
    );
  }

  static void _confirmDeletePost(BuildContext context, String docId) async {
    
    final confirm = await showDialog<bool>(
      context: context,
    
      builder: (context) => AlertDialog(
        title: const Text('DELETE POST'),
        content: const Text('Are you sure you want to delete this post?'),
    
        actions: [
    
          TextButton(
            child: const Text('CANCEL'),
            onPressed: () => Navigator.pop(context, false),
          ),
    
          TextButton(
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseFirestore.instance.collection('community_posts').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted')),
      );
    }
  }

  static ImageProvider _getProfileImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return const AssetImage('assets/default_profile.png');
    }
    if (imagePath.startsWith('http')) {
      return NetworkImage(imagePath);
    }
    return AssetImage(imagePath);
  }
}