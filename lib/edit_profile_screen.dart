import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_form.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController     = TextEditingController();
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _address1Controller = TextEditingController();
  final TextEditingController _address2Controller = TextEditingController();
  final TextEditingController _postcodeController = TextEditingController();
  final TextEditingController _cityController     = TextEditingController();
  final TextEditingController _phoneController    = TextEditingController();

  final List<String> _availableGenres = [
    'FANTASY', 'SCI-FI', 'ROMANCE', 'MYSTERY', 'HORROR', 'THRILLER',
    'BIOGRAPHY', 'HISTORY', 'POETRY', 'DRAMA', 'ADVENTURE', 'NON-FICTION',
    'FICTION', 'SELF-HELP', 'YOUNG ADULT', 'COMICS',
  ];

  final List<String> _malaysianStates = [
    'JOHOR', 'KEDAH', 'KELANTAN', 'MELAKA', 'NEGERI SEMBILAN', 'PAHANG',
    'PENANG', 'PERAK', 'PERLIS', 'SABAH', 'SARAWAK', 'SELANGOR',
    'TERENGGANU', 'KUALA LUMPUR', 'LABUAN', 'PUTRAJAYA',
  ];

  List<String> _selectedGenres = [];
  String? _selectedState;
  String selectedCat = 'assets/cat1.png';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nameController.text      = data['name'] ?? '';
          _emailController.text     = user.email ?? '';
          _selectedGenres           = List<String>.from(data['genres'] ?? []);
          _address1Controller.text  = data['address1'] ?? '';
          _address2Controller.text  = data['address2'] ?? '';
          _postcodeController.text  = data['postcode'] ?? '';
          _cityController.text      = data['city'] ?? '';
          _selectedState            = data['state'];
          _phoneController.text     = data['phone'] ?? '';
          selectedCat               = data['profileImage'] ?? 'assets/cat1.png';
          _isLoading = false;
        });
      }
    }
  }

  void _addGenre(String genre) {
    if (_selectedGenres.length < 10 && !_selectedGenres.contains(genre)) {
      setState(() => _selectedGenres.add(genre));
    }
  }

  void _removeGenre(String genre) {
    setState(() => _selectedGenres.remove(genre));
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final uid = user.uid;
        final newName = _nameController.text.trim();
        final newPassword = _passwordController.text.trim();
        
        try {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'name'        : newName,
            'genres'      : _selectedGenres,
            'address1'    : _address1Controller.text.trim(),
            'address2'    : _address2Controller.text.trim(),
            'postcode'    : _postcodeController.text.trim(),
            'city'        : _cityController.text.trim(),
            'state'       : _selectedState,
            'phone'       : _phoneController.text.trim(),
            'profileImage': selectedCat,
          });

          final userBooks = await FirebaseFirestore.instance
              .collection('books')
              .where('ownerId', isEqualTo: uid)
              .get();

          for (final doc in userBooks.docs) {
            await doc.reference.update({'ownerName': newName});
          }

          if (newPassword.isNotEmpty) {
            await user.updatePassword(newPassword);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('PROFILE UPDATED SUCCESSFULLY!')),
          );

          Navigator.pop(context);
        
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('ERROR UPDATING PROFILE: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(title: const Text('EDIT PROFILE'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : EditProfileForm(
              formKey: _formKey,
              nameController    : _nameController,
              emailController   : _emailController,
              passwordController: _passwordController,
              address1Controller: _address1Controller,
              address2Controller: _address2Controller,
              postcodeController: _postcodeController,
              cityController    : _cityController,
              phoneController   : _phoneController,
              availableGenres   : _availableGenres,
              malaysianStates   : _malaysianStates,
              selectedGenres    : _selectedGenres,
              selectedState     : _selectedState,
              selectedCat       : selectedCat,
              onCatSelected     : (cat) => setState(() => selectedCat = cat),
              onGenreAdd        : _addGenre,
              onGenreRemove     : _removeGenre,
              onStateChanged    : (state) => setState(() => _selectedState = state),
              onSave            : _saveProfile,
            ),
    );
  }
}