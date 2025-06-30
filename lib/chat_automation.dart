import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_chat_stream.dart';


class ChatAutomation {

  /// Responds to a borrow request with an accept or reject message
  static Future<void> respondToRequest({

    required String borrowerId,
    required String borrowerName,
    required bool accept,
  
  }) async {
  
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final message = accept
        ? 'Hi $borrowerName, I have accepted your request. Please let me know your preferred method of delivery (meet-up or via postage).\n[This is an auto-generated message]'
        : 'Hi $borrowerName, unfortunately I have to reject your request. You can still chat with me for more info.\n[This is an auto-generated message]';

    await FirestoreChatService.sendMessage(borrowerId, message);
  
  }


  /// Send book owner's location message for meet-up
  static Future<void> sendMeetupLocation({
   
    required String receiverId,
    required String city,
    required String state,
 
  }) async {
  
    final message = "Owner's Area of Living: $city, $state\n[This is an auto-generated message]";
    await FirestoreChatService.sendMessage(receiverId, message);
  
  }


  /// Sends message for fastest delivery method
  static Future<void> sendFastestDelivery(String receiverId) async {
    
    const message = 'Lender will send via third-party (Grab, Lalamove, etc).\n[This is an auto-generated message]';
    await FirestoreChatService.sendMessage(receiverId, message);
 
  }


  /// Sends message for cheapest delivery method
  static Future<void> sendCheapestDelivery(String receiverId) async {
  
    const message = 'Lender will send via postage (PosLaju, DHL, etc).\n[This is an auto-generated message]';
    await FirestoreChatService.sendMessage(receiverId, message);
  
  }


}