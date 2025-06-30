import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';


class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    
    if (currentUserId == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatDocs = snapshot.data?.docs ?? [];

          final myChats = chatDocs.where((doc) {
            final ids = doc.id.split('_');
            return ids.contains(currentUserId);
          }).toList();

          if (myChats.isEmpty) {
            return const Center(child: Text("No chats yet"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            
            children: [
            
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 12),
            
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 233, 189),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
            
                child: const Text(
                  'ALL CHAT',
            
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
            
                ),
            
              ),

              ...myChats.map((chatDoc) {
            
                final docId         = chatDoc.id;
                final userIds       = docId.split('_');
                final chatPartnerId = userIds.firstWhere((id) => id != currentUserId);
                final data          = chatDoc.data() as Map<String, dynamic>;
                final unreadBy      = data.containsKey('unreadBy')
                    ? List<String>.from(data['unreadBy'])
                    : <String>[];
                final isUnread      = unreadBy.contains(currentUserId);

                return FutureBuilder<DocumentSnapshot>(
                  
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .doc(chatPartnerId)
                      .get(),
                  
                  builder: (context, userSnapshot) {
                  
                    if (!userSnapshot.hasData) return const SizedBox();

                    final userName = userSnapshot.data?.get('name') ?? 'User';
                    final profileImage = userSnapshot.data?.get('profileImage') ?? 'assets/default_profile.png';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                  
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 167, 154),
                        borderRadius: BorderRadius.circular(16),
                  
                        boxShadow: [
                  
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(2, 2),
                          ),
                  
                        ],
                  
                      ),
                  
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                  
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: AssetImage(profileImage),
                        ),
                  
                        title: Row(
                  
                          children: [
                  
                            Expanded(
                  
                              child: Text(
                                userName,
                  
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                  
                            ),
                  
                          ],
                  
                        ),
                  
                        subtitle: const Text("Tap to continue chatting"),
                        trailing: isUnread
                            ? const Icon(Icons.mark_chat_unread, color: Colors.red)
                            : const Icon(Icons.arrow_forward_ios),
                  
                        onTap: () {
                  
                          Navigator.push(
                            context,
                  
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                chatPartnerId: chatPartnerId,
                                chatPartnerName: userName,
                              ),
                            ),
                  
                          );
                  
                        },
                  
                      ),
                  
                    );
                  
                  },
                
                );
              
              }),
            ],
          );
        },
      ),
    );
  }
}