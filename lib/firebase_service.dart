import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<User?> registerUser(
    
    String email,
    String password,
    String name,
 
  ) async {
 
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload(); // Update the user's info immediately
      }

      return user;
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  
  }

  static Future<void> uploadBookData({
    required String title,
    required String author,
    required String genre,
    String? synopsis,
    String? year,
    String? publisher,
    String? language,
    String? pages,
  
  }) async {
    final user = _auth.currentUser!;
  
    final bookData = {
      'title'     : title,
      'author'    : author,
      'genre'     : genre,
      'ownerId'   : user.uid,
      'ownerName' : user.displayName ?? 'Anonymous',
      'synopsis'  : synopsis,
      'year'      : year,
      'publisher' : publisher,
      'language'  : language,
      'pages'     : pages,
      'timestamp' : FieldValue.serverTimestamp(),
    };

    await _firestore.collection('books').add(bookData);
  }

  static Future<void> updateBookData({
    
    required String bookId,
    required String title,
    required String author,
    required String genre,
    String? synopsis,
    String? year,
    String? publisher,
    String? language,
    String? pages,
 
  }) async {
 
    final user = _auth.currentUser!;
    final bookData = {
      'title'     : title,
      'author'    : author,
      'genre'     : genre,
      'ownerId'   : user.uid,
      'ownerName' : user.displayName ?? 'Anonymous',
      'synopsis'  : synopsis,
      'year'      : year,
      'publisher' : publisher,
      'language'  : language,
      'pages'     : pages,
      'timestamp' : FieldValue.serverTimestamp(),
    };

    await _firestore.collection('books').doc(bookId).update(bookData);
  
  }

  static Stream<QuerySnapshot> fetchBooks() {
    return _firestore
        .collection('books')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  
}