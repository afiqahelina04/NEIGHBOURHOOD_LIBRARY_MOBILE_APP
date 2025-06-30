import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_tabs.dart';


class ViewProfileScreen extends StatefulWidget {
  const ViewProfileScreen({super.key});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}


class _ViewProfileScreenState extends State<ViewProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String name     = '';
  String email    = '';
  String address1 = '';
  String address2 = '';
  String postcode = '';
  String city     = '';
  String state    = '';
  String phone    = '';
  List<String> genres = [];
  List<Map<String, dynamic>> userBooks = [];
  bool isLoading = true;
  String profileImagePath = 'assets/default_profile.png';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadUserData();
  }

  Future<void> loadUserData() async {

    try {
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        final uid = user.uid;
        final emailFromAuth = user.email ?? 'No email';
        final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
        final doc = await userDocRef.get();
        final booksSnapshot = await FirebaseFirestore.instance
            .collection('books')
            .where('ownerId', isEqualTo: uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
         
          setState(() {
            name              = data['name'] ?? 'Unnamed';
            email             = emailFromAuth;
            address1          = data['address1'] ?? '';
            address2          = data['address2'] ?? '';
            postcode          = data['postcode'] ?? '';
            city              = data['city'] ?? '';
            state             = data['state'] ?? '';
            phone             = data['phone'] ?? '';
            profileImagePath  = data['profileImage'] ?? 'assets/default_profile.png';
            genres            = List<String>.from(data['genres'] ?? []);
            userBooks         = booksSnapshot.docs.map((doc) {
            final bookData = doc.data();
            bookData['id'] = doc.id;
              return bookData;
            }).toList();
            isLoading = false;
          });
        
        } else {
          setState(() => isLoading = false);
        }
      
      } else {
        setState(() => isLoading = false);
      }
    
    } catch (e) {
      print('❌ Error loading user data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    
      appBar: AppBar(
        title: const Text('YOUR PROFILE'),
        centerTitle: true,
    
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.white,
    
          tabs: const [
            Tab(text: 'PROFILE'),
            Tab(text: 'MY BOOKS'),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 255, 215, 135),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProfileTabs(
              tabController   : _tabController,
              name            : name,
              email           : email,
              address1        : address1,
              address2        : address2,
              postcode        : postcode,
              city            : city,
              state           : state,
              phone           : phone,
              profileImagePath: profileImagePath,
              genres          : genres,
              userBooks       : userBooks,
              onReloadProfile : () async {
                setState(() => isLoading = true);
                await loadUserData();
              },
            ),
    );
  }

}