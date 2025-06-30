import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_details_screen.dart';


class UserProfileScreen extends StatelessWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});
 
  Future<Map<String, dynamic>?> fetchUserData() async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  Future<List<Map<String, dynamic>>> fetchUserBooks() async {
    final query = await FirebaseFirestore.instance
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .get();

    return query.docs.map((doc) => doc.data()).toList();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text('USER PROFILE'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 215, 135),
      ),

      body: FutureBuilder(
        future: Future.wait([fetchUserData(), fetchUserBooks()]),

        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data![0] == null) {
            return const Center(child: Text('User not found.'));
          }

          final userData = snapshot.data![0] as Map<String, dynamic>;
          final userBooks = snapshot.data![1] as List<Map<String, dynamic>>;
          final profileImage = userData['profileImage'] ?? 'assets/default_profile.png';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
             
              children: [
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 167, 154),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                  
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundImage: AssetImage(profileImage),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        userData['name'] ?? 'User',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${userData['city'] ?? '-'}, ${userData['state'] ?? '-'}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'PREFERRED GENRES:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                     
                      Align(
                        alignment: Alignment.centerLeft,
                        
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: (userData['genres'] as List<dynamic>? ?? []).map((genre) {
                            return Chip(label: Text(genre.toString()));
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                
                ),
                const SizedBox(height: 30),
                
                const Text('BOOKS:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                
                ...userBooks.map((book) {
                
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                   
                    child: ListTile(
                      title: Text(book['title'] ?? 'Untitled'),
                      subtitle: Text('Author: ${book['author'] ?? 'Unknown'}'),
                   
                      onTap: () {
                   
                        Navigator.push(
                          context,
                   
                          MaterialPageRoute(
                            builder: (_) => BookDetailsScreen(
                              title     : book['title'] ?? '',
                              author    : book['author'] ?? '',
                              genre     : book['genre'] ?? '',
                              ownerId   : userId,
                              ownerName : userData['name'] ?? 'User',
                              frontUrl  : book['frontUrl'],
                              topUrl    : book['topUrl'],
                              sideUrl   : book['sideUrl'],
                              synopsis  : book['synopsis'],
                              year      : book['year'],
                              publisher : book['publisher'],
                              language  : book['language'],
                              pages     : book['pages'],
                            ),
                          ),
                        );
                      
                      },
                    ),
                  );
                
                }),
              
              ],
            ),
          );
        },
      ),
    );
  }

}