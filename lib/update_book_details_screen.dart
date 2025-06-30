import 'package:flutter/material.dart';
import 'firebase_service.dart';


class UpdateBookDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> bookData;
  final String bookId;
  const UpdateBookDetailsScreen({
    super.key,
    required this.bookData,
    required this.bookId,
  });

  @override
  State<UpdateBookDetailsScreen> createState() => _UpdateBookDetailsScreenState();
}


class _UpdateBookDetailsScreenState extends State<UpdateBookDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController authorController;
  late TextEditingController synopsisController;
  late TextEditingController yearController;
  late TextEditingController publisherController;
  late TextEditingController languageController;
  late TextEditingController pagesController;

  List<String> selectedGenres = [];
  final List<String> _availableGenres = [
    'FANTASY', 'SCI-FI', 'ROMANCE', 'MYSTERY', 'HORROR', 'THRILLER',
    'BIOGRAPHY', 'HISTORY', 'POETRY', 'DRAMA', 'ADVENTURE', 'NON-FICTION',
    'FICTION', 'SELF-HELP', 'YOUNG ADULT', 'COMICS',
  ];

  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    final data = widget.bookData;
    titleController     = TextEditingController(text: data['title']);
    authorController    = TextEditingController(text: data['author']);
    synopsisController  = TextEditingController(text: data['synopsis']);
    yearController      = TextEditingController(text: data['year']);
    publisherController = TextEditingController(text: data['publisher']);
    languageController  = TextEditingController(text: data['language']);
    pagesController     = TextEditingController(text: data['pages']);
    selectedGenres      = data['genre']?.split(', ') ?? [];
  }

  Future<void> updateBook() async {
    
    if (_formKey.currentState!.validate()) {
      
      if (selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE SELECT AT LEAST ONE GENRE')),
        );
        return;
      }

      setState(() => isUploading = true);

      try {
        
        await FirebaseService.updateBookData(
          bookId: widget.bookId,
          title: titleController.text.trim(),
          author: authorController.text.trim(),
          genre: selectedGenres.join(', '),
          synopsis: synopsisController.text.trim(),
          year: yearController.text.trim(),
          publisher: publisherController.text.trim(),
          language: languageController.text.trim(),
          pages: pagesController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('BOOK UPDATED SUCCESSFULLY.')),
        );

        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR UPDATING BOOK: $e')),
        );
      } finally {
        setState(() => isUploading = false);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    
      appBar: AppBar(
        title: const Text("UPDATE BOOK DETAILS"),
        centerTitle: true,
      ),
    
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
    
        child: Form(
          key: _formKey,
    
          child: Column(
    
            children: [
              const Center(child: Icon(Icons.book, size: 100)),
              const SizedBox(height: 20),

              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "BOOK TITLE"),
                validator: (value) => value!.isEmpty ? 'ENTER BOOK TITLE' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: "AUTHOR"),
                validator: (value) => value!.isEmpty ? 'ENTER AUTHOR NAME' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'GENRE(S)',
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 167, 154),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
                items: _availableGenres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  if (value != null &&
                      !selectedGenres.contains(value) &&
                      selectedGenres.length < 10) {
                    setState(() {
                      selectedGenres.add(value);
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: selectedGenres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () {
                      setState(() {
                        selectedGenres.remove(genre);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: synopsisController,
                maxLines: 5,
                maxLength: 5000,
                decoration: const InputDecoration(labelText: "SYNOPSIS"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: yearController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(labelText: "YEAR OF PUBLISHING"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: publisherController,
                maxLength: 40,
                decoration: const InputDecoration(labelText: "PUBLISHER"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: languageController,
                maxLength: 20,
                decoration: const InputDecoration(labelText: "LANGUAGE"),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: pagesController,
                maxLength: 6,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "PAGES"),
              ),
              const SizedBox(height: 32),

              isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text("UPDATE BOOK"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 167, 154),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      ),
                      onPressed: updateBook,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}