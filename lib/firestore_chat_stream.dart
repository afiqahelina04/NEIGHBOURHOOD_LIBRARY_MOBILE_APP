import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirestoreChatService {

  static final _firestore = FirebaseFirestore.instance;
  static final _auth      = FirebaseAuth.instance;

  // Get chat stream between current user and receiver
  static Stream<QuerySnapshot> getMessages(String receiverId) {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return const Stream.empty();
    final chatId = [senderId, receiverId]..sort(); // ensures consistent order
    final chatDocId = chatId.join('_');
    return _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(String receiverId, String message) async {
    final senderId = _auth.currentUser?.uid;
    if (senderId == null) return;
    final chatId = [senderId, receiverId]..sort(); // ensures consistency
    final chatDocId = chatId.join('_');

    await _firestore.collection('chats').doc(chatDocId).set({
      'participants': chatId,
      'lastUpdated': Timestamp.now(),
      'unreadBy': FieldValue.arrayUnion([receiverId]), 
    }, SetOptions(merge: true)); 

    await _firestore
        .collection('chats')
        .doc(chatDocId)
        .collection('messages')
        .add({
      'senderId': senderId,
      'message': message,
      'timestamp': Timestamp.now(),
      'unreadBy': [receiverId],
    });
  }

}