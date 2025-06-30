import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_user_list.dart';
import 'admin_book_list.dart';
import 'login_screen.dart';
import 'community_screen.dart'; 


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}


class _AdminScreenState extends State<AdminScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const UserListScreen(),
    const CommunityScreen(),
    const BookListScreen(),
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 215, 135),
   
      appBar: AppBar(
        title: const Text("ADMIN DASHBOARD"),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 215, 135),
        elevation: 0,
   
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
   
      body: _pages[_currentIndex],
   
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 167, 154),
        onTap: (index) => setState(() => _currentIndex = index),
   
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Community'), 
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
        ],
      ),
    );
  
  }
}