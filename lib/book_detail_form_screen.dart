import 'package:flutter/material.dart';
import 'firebase_service.dart';


class BookDetailFormScreen extends StatefulWidget {
  const BookDetailFormScreen({super.key});

  @override
  State<BookDetailFormScreen> createState() => _BookDetailFormScreenState();
}


class _BookDetailFormScreenState extends State<BookDetailFormScreen> {
 
  bool isUploading = false;
  final _formKey = GlobalKey<FormState>();
 
  final TextEditingController titleController     = TextEditingController();
  final TextEditingController authorController    = TextEditingController();
  final TextEditingController synopsisController  = TextEditingController();
  final TextEditingController yearController      = TextEditingController();
  final TextEditingController publisherController = TextEditingController();
  final TextEditingController languageController  = TextEditingController();
  final TextEditingController pagesController     = TextEditingController();
 
  final List<String> selectedGenres   = [];
 
  final List<String> _availableGenres = [
    'FANTASY', 'SCI-FI', 'ROMANCE', 'MYSTERY', 'HORROR', 'THRILLER',
    'BIOGRAPHY', 'HISTORY', 'POETRY', 'DRAMA', 'ADVENTURE', 'NON-FICTION',
    'FICTION', 'SELF-HELP', 'YOUNG ADULT', 'COMICS',
  ];

  Future<void> submitDetails() async {
    
    if (_formKey.currentState!.validate()) {
    
      if (selectedGenres.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PLEASE SELECT AT LEAST ONE GENRE')),
        );
        return;
      }

      setState(() => isUploading = true);

      try {
        await FirebaseService.uploadBookData(
          title     : titleController.text.trim(),
          author    : authorController.text.trim(),
          genre     : selectedGenres.join(', '),
          synopsis  : synopsisController.text.trim(),
          year      : yearController.text.trim(),
          publisher : publisherController.text.trim(),
          language  : languageController.text.trim(),
          pages     : pagesController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('BOOK UPLOADED SUCCESSFULLY.')),
        );

        if (mounted) {
          Navigator.popUntil(context, ModalRoute.withName('/home'));
        }

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR UPLOADING BOOK: $e')),
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
        title: const Text("ENTER BOOK DETAILS"),
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
                validator: (value) =>
                    value!.isEmpty ? 'ENTER BOOK TITLE' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: authorController,
                decoration: const InputDecoration(labelText: "AUTHOR"),
                validator: (value) =>
                    value!.isEmpty ? 'ENTER AUTHOR NAME' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'PREFERRED GENRE(S)',
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
                      icon: const Icon(Icons.check),
                      label: const Text("SUBMIT DETAILS"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 167, 154),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 16,
                        ),
                      ),
                      onPressed: submitDetails,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}