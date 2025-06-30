import 'package:flutter/material.dart';
import 'chat_body.dart';
import 'user_profile_screen.dart';

class ChatScreen extends StatelessWidget {
  final String chatPartnerId;
  final String chatPartnerName;

  const ChatScreen({
    required this.chatPartnerId,
    required this.chatPartnerName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 215, 135),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('CHAT WITH ${chatPartnerName.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserProfileScreen(userId: chatPartnerId),
              ),
            ),
          ),
        ],
      ),
      body: ChatBody(
        chatPartnerId: chatPartnerId,
        chatPartnerName: chatPartnerName,
      ),
    );
  }
}