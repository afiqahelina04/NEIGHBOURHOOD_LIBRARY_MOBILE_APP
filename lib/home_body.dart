import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'book_details_screen.dart';


class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}


class _HomeBodyState extends State<HomeBody> {
  String userName = '';
  List<Map<String, dynamic>> allFirestoreBooks = [];
  List<Map<String, dynamic>> filteredBooks = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchBooks();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = (userDoc.data()?['name'] ?? 'User').toString().toUpperCase();
      });
    }
  }

  Future<void> fetchBooks() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('books').get();
    final books = querySnapshot.docs.map((doc) => doc.data()).toList();
    setState(() {
      allFirestoreBooks = List<Map<String, dynamic>>.from(books);
      filteredBooks = allFirestoreBooks;
    });
  }

  void searchBooks(String query) {
    final results = allFirestoreBooks.where((book) {
      final title = book['title']?.toLowerCase() ?? '';
      final author = book['author']?.toLowerCase() ?? '';
      return title.contains(query.toLowerCase()) || author.contains(query.toLowerCase());
    }).toList();
    setState(() => filteredBooks = results);
  }

  @override
  Widget build(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.all(16),
    
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
    
        children: [
          Text('HI $userName,', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('BORROW A BOOK!', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
    
          TextField(
            controller: searchController,
            onChanged: searchBooks,
          
            decoration: InputDecoration(
              hintText: 'SEARCH BY TITLE OR AUTHOR',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: const Color.fromARGB(255, 255, 167, 154),
            ),
          ),
          
          if (searchController.text.isNotEmpty && filteredBooks.isNotEmpty)
            
            Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: const Color.fromARGB(180, 255, 167, 154),
                border: Border.all(color: const Color.fromARGB(255, 3, 3, 3)),
                borderRadius: BorderRadius.circular(8),
              ),
            
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredBooks.length,
               
                itemBuilder: (context, index) {
                  final book = filteredBooks[index];
               
                  return ListTile(
                    title: Text(book['title'] ?? 'Untitled'),
                    subtitle: Text('Author: ${book['author'] ?? 'Unknown'}'),
                    onTap: () => navigateToBookDetails(context, book),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          
          const Text('RECOMMENDED FOR YOU', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          Expanded(
           
            child: ListView.builder(
              itemCount: allFirestoreBooks.length, // ALWAYS show all books for recommendations
              
              itemBuilder: (context, index) {
                final book = allFirestoreBooks[index];
               
                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  
                  child: ListTile(
                    title: Text(book['title'] ?? 'Untitled'),
                    subtitle: Text('Author: ${book['author'] ?? 'Unknown'}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => navigateToBookDetails(context, book),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  void navigateToBookDetails(BuildContext context, Map<String, dynamic> book) {
    
    Navigator.push(
      context,
      
      MaterialPageRoute(
        builder: (_) => BookDetailsScreen(
          title     : book['title'] ?? 'Untitled',
          author    : book['author'] ?? 'Unknown',
          genre     : book['genre'] ?? 'N/A',
          ownerId   : book['ownerId'] ?? '',
          ownerName : book['ownerName'] ?? 'Unknown',
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
  }
}