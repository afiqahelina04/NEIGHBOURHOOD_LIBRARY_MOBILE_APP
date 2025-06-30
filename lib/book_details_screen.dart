import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_chat_stream.dart';
import 'chat_screen.dart';


class BookDetailsScreen extends StatelessWidget {
  
  final String title;
  final String author;
  final String genre;
  final String ownerId;
  final String ownerName;
  final String? frontUrl;
  final String? topUrl;
  final String? sideUrl;
  final String? synopsis;
  final String? year;
  final String? publisher;
  final String? language;
  final String? pages;

  const BookDetailsScreen({
    super.key,
    required this.title,
    required this.author,
    required this.genre,
    required this.ownerId,
    required this.ownerName,
    this.frontUrl,
    this.topUrl,
    this.sideUrl,
    this.synopsis,
    this.year,
    this.publisher,
    this.language,
    this.pages,
  });

  void sendRequestMessage(BuildContext context) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null || currentUserId == ownerId) return;

    final message =
        'Hi, I would like to borrow your book "$title". Please accept or reject my request.';

    await FirestoreChatService.sendMessage(ownerId, message);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatPartnerId: ownerId,
          chatPartnerName: ownerName,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        '$label: ${value != null && value.isNotEmpty ? value : '-'}',
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = FirebaseAuth.instance.currentUser?.uid == ownerId;

    return Scaffold(

      appBar: AppBar(
        title: const Text('BOOK DETAILS'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          
          children: [
            const Center(child: Icon(Icons.book, size: 100)),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              margin: const EdgeInsets.only(bottom: 20),
             
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 167, 154),
                borderRadius: BorderRadius.circular(16),
              ),
             
              child: Center(
             
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
             
              ),
            
            ),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 218, 200),
                borderRadius: BorderRadius.circular(16),
              ),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              
                children: [
                  _buildDetailRow('Author', author),
                  _buildDetailRow('Genre', genre),
                  _buildDetailRow('Year Published', year),
                  _buildDetailRow('Publisher', publisher),
                  _buildDetailRow('Language', language),
                  _buildDetailRow('Pages', pages),
                ],
             
              ),
            
            ),
            
            if (synopsis != null && synopsis!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 218, 200),
                  borderRadius: BorderRadius.circular(16),
                ),
                
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                 
                  children: [
                    const Text('Synopsis:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                
                    Text(
                      synopsis!,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            
            if (!isOwner)
              Center(
            
                child: ElevatedButton(
                  onPressed: () => sendRequestMessage(context),
            
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 167, 154),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                  ),
                  child: const Text('REQUEST TO BORROW'),
            
                ),
              )
            
            else
              Center(
            
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            
                  decoration: BoxDecoration(
                    color: Colors.brown.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color.fromARGB(255, 8, 8, 8), width: 1.5),
                  ),
            
                  child: const Text(
                    'YOU ARE THE OWNER OF THIS BOOK.',
            
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 6, 6, 6),
                    ),
            
                  ),
            
                ),
            
              ),
          
          ],
        
        ),
      
      ),
    
    );
  
  }

}