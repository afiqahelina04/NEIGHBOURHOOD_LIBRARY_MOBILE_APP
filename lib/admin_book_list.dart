import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';


class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(

      stream: FirebaseService.fetchBooks(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final books = snapshot.data!.docs;

        return ListView.builder(

          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            final bookData = book.data() as Map<String, dynamic>;

            return Card(

              color: const Color.fromARGB(255, 255, 167, 154),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              child: ListTile(
                title: Text(bookData['title'] ?? 'No Title'),
                subtitle: Text('By ${bookData['author'] ?? 'Unknown'}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        _showEditBookDialog(context, book.id, bookData);
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('books').doc(book.id).delete();
                      },
                    ),
                    
                  ],
                ),
              ),

            );
          },
          
        );
      },
    );
  }

  void _showEditBookDialog(BuildContext context, String docId, Map<String, dynamic> data) {

    final titleController     = TextEditingController(text: data['title']);
    final authorController    = TextEditingController(text: data['author']);
    final genreController     = TextEditingController(text: data['genre']);
    final synopsisController  = TextEditingController(text: data['synopsis']);
    final yearController      = TextEditingController(text: data['year']);
    final publisherController = TextEditingController(text: data['publisher']);
    final languageController  = TextEditingController(text: data['language']);
    final pagesController     = TextEditingController(text: data['pages']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(255, 255, 215, 135),

      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),

        child: SingleChildScrollView(

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text("EDIT BOOK", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'TITLE')),
              const SizedBox(height: 12),
              
              TextField(controller: authorController, decoration: const InputDecoration(labelText: 'AUTHOR')),
              const SizedBox(height: 12),
              
              TextField(controller: genreController, decoration: const InputDecoration(labelText: 'GENRE')),
              const SizedBox(height: 12),
              
              TextField(
                controller: synopsisController,
                decoration: const InputDecoration(labelText: 'SYNOPSIS'),
                maxLines: null,
                minLines: 5,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 12),
              
              TextField(controller: yearController, decoration: const InputDecoration(labelText: 'YEAR')),
              const SizedBox(height: 12),
              
              TextField(controller: publisherController, decoration: const InputDecoration(labelText: 'PUBLISHER')),
              const SizedBox(height: 12),
              
              TextField(controller: languageController, decoration: const InputDecoration(labelText: 'LANGUAGE')),
              const SizedBox(height: 12),
              
              TextField(controller: pagesController, decoration: const InputDecoration(labelText: 'PAGES')),
              const SizedBox(height: 24),
              
              ElevatedButton(

                onPressed: () {
                  FirebaseFirestore.instance.collection('books').doc(docId).update({
                    'title'     : titleController.text.trim(),
                    'author'    : authorController.text.trim(),
                    'genre'     : genreController.text.trim(),
                    'synopsis'  : synopsisController.text.trim(),
                    'year'      : yearController.text.trim(),
                    'publisher' : publisherController.text.trim(),
                    'language'  : languageController.text.trim(),
                    'pages'     : pagesController.text.trim(),
                    'timestamp' : FieldValue.serverTimestamp(),
                  });
                  Navigator.pop(context);
                },
                
                child: const Text("SAVE"),
              ),
            
            ],
          
          ),
        ),
      ),
    );
  }

}