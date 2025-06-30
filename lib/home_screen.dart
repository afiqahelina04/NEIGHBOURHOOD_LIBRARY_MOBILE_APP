import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'view_profile_screen.dart';
import 'donation_screen.dart';
import 'chat_inbox_screen.dart';
import 'login_screen.dart';
import 'home_body.dart';
import 'community_screen.dart';
import 'book_detail_form_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool hasUnreadMessages = false;

  @override
  void initState() {
    super.initState();
    checkUnreadMessages();
  }

  Future<void> checkUnreadMessages() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;
    final unread = await FirebaseFirestore.instance
        .collection('chats')
        .where('unreadBy', arrayContains: currentUserId)
        .get();
    setState(() {
      hasUnreadMessages = unread.docs.isNotEmpty;
    });
  }

  final List<String> _titles = [
    'HOME',
    'UPLOAD A BOOK',
    'COMMUNITY',
    'DONATE',
    'CHAT',
    'PROFILE',
  ];

  @override
  Widget build(BuildContext context) {
    
    final List<Widget> screens = [
      HomeBody(),
      Container(), // UPLOAD placeholder since we're pushing it directly
      const CommunityScreen(),
      const DonationScreen(),
      const ChatInboxScreen(),
      Container(),
    ];

    return Scaffold(
      
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      body: screens[_currentIndex],
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 122, 101),
        unselectedItemColor: const Color.fromARGB(255, 248, 194, 87),
      
        onTap: (index) {
      
          if (index == 5) {
      
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewProfileScreen()),
            );
      
          } else if (index == 1) {
            
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BookDetailFormScreen()),
            );
          
          } else {
            setState(() => _currentIndex = index);
          }
        },

        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'HOME'),
          const BottomNavigationBarItem(icon: Icon(Icons.upload), label: 'UPLOAD'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'COMMUNITY'),
          const BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'DONATE'),
         
          BottomNavigationBarItem(
           
            icon: Stack(
           
              children: [
                const Icon(Icons.chat),
                if (hasUnreadMessages)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(radius: 6, backgroundColor: Colors.red),
                  ),
              ],
            ),
            label: 'CHAT',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'PROFILE'),
        ],
      ),
    );
  }

}