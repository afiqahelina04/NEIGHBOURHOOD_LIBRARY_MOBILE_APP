import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}


class _RegisterScreenState extends State<RegisterScreen> {

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final List<String> _availableGenres = [
    'FANTASY', 'SCI-FI', 'ROMANCE', 'MYSTERY', 'HORROR', 'THRILLER',
    'BIOGRAPHY', 'HISTORY', 'POETRY', 'DRAMA', 'ADVENTURE', 'NON-FICTION',
    'FICTION', 'SELF-HELP', 'YOUNG ADULT', 'COMICS',
  ];

  final List<String> _selectedGenres = [];

  void _addGenre(String genre) {
    if (!_selectedGenres.contains(genre) && _selectedGenres.length < 10) {
      setState(() {
        _selectedGenres.add(genre);
      });
    }
  }

  void _removeGenre(String genre) {
    setState(() {
      _selectedGenres.remove(genre);
    });
  }

  void _register() async {
  if (_selectedGenres.isEmpty || _nameController.text.trim().isEmpty) {
    return;
  }

  FocusScope.of(context).unfocus(); // Move it here only when validation passes
  setState(() => _isLoading = true);

  try {
   
    final UserCredential userCredential = await FirebaseAuth.instance

        .createUserWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

    final user = userCredential.user;

    if (user != null) {
      final uid = user.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': _nameController.text.trim(),
        'genres': _selectedGenres,
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("REGISTRATION SUCCESSFUL!")),
    );

    Navigator.pushReplacementNamed(context, '/home');
  
  } on FirebaseAuthException catch (e) {
  
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: ${e.message}")),
    );
 
  }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
 
    return Scaffold(
      appBar: AppBar(title: const Text('REGISTRATION PAGE'), centerTitle: true),
 
      body: Center(
 
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
 
          child: Column(
 
            children: [
 
              const Text(
                'CREATE YOUR ACCOUNT',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'EMAIL',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'NAME',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'PREFERRED GENRE(S)',
                  prefixIcon: Icon(Icons.book),
                ),
                items: _availableGenres.map((genre) {
                  return DropdownMenuItem(value: genre, child: Text(genre));
                }).toList(),
                onChanged: (value) {
                  if (value != null) _addGenre(value);
                },
              ),
              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                children: _selectedGenres.map((genre) {
                  return Chip(
                    label: Text(genre),
                    deleteIcon: const Icon(Icons.close),
                    onDeleted: () => _removeGenre(genre),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: (_selectedGenres.isEmpty || _nameController.text.trim().isEmpty || _isLoading)
                            ? null
                            : _register,
                        child: const Text('REGISTER'),
                      ),
              ),
              const SizedBox(height: 12),

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'ALREADY HAVE AN ACCOUNT? LOGIN HERE',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            
            ],
          
          ),
       
        ),
      ),
    );
  }

}