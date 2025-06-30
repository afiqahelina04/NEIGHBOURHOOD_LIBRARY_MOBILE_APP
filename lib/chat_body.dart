import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_chat_stream.dart';
import 'chat_automation.dart';
import 'word_limit_formatter.dart';

class ChatBody extends StatefulWidget {
  final String chatPartnerId;
  final String chatPartnerName;

  const ChatBody({
    required this.chatPartnerId,
    required this.chatPartnerName,
    super.key,
  });

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final TextEditingController messageController = TextEditingController();
  bool _hasResponded = false;
  bool _showAcceptRejectButtons = false;
  DocumentSnapshot? _borrowRequestMessage;
  String? deliveryMethod;
  String? subDeliveryOption;
  String? city;
  String? state;

  @override
  void initState() {
    super.initState();
    markMessagesAsRead();
    fetchPartnerLocation();
  }

  Future<void> markMessagesAsRead() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    final chatId = [currentUser.uid, widget.chatPartnerId]..sort();
    final chatDocId = chatId.join('_');
    final messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatDocId)
        .collection('messages');

    final unreadMessages = await messagesRef
        .where('unreadBy', arrayContains: currentUser.uid)
        .get();

    for (final doc in unreadMessages.docs) {
      await doc.reference.update({
        'unreadBy': FieldValue.arrayRemove([currentUser.uid]),
      });
    }
  }

  Future<void> fetchPartnerLocation() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.chatPartnerId)
        .get();
    if (doc.exists) {
      setState(() {
        city = doc['city'] ?? '-';
        state = doc['state'] ?? '-';
      });
    }
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      handleCommands(text);
      FirestoreChatService.sendMessage(widget.chatPartnerId, text);
      messageController.clear();
    }
  }

  void handleCommands(String text) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final lower = text.toLowerCase();

    if (lower == '/accept' || lower == '/reject') {
      ChatAutomation.respondToRequest(
        borrowerId: widget.chatPartnerId,
        borrowerName: widget.chatPartnerName,
        accept: lower == '/accept',
      );
      setState(() {
        _hasResponded = true;
        _showAcceptRejectButtons = true;
      });
    }
  }

  bool isMe(String senderId) =>
      senderId == FirebaseAuth.instance.currentUser?.uid;

  Widget buildMessageList(AsyncSnapshot<QuerySnapshot> snapshot) {
    final messages = snapshot.data!.docs;
    bool acceptedShown = false;
    bool rejectedShown = false;

    for (final msg in messages) {
      final messageText = msg['message'].toString().toLowerCase();
      final senderId = msg['senderId'];
      final isSender = isMe(senderId);
      if (messageText.contains('i would like to borrow') &&
          !isSender &&
          !_hasResponded) {
        _showAcceptRejectButtons = true;
        _borrowRequestMessage = msg;
        break;
      }
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final message = msg['message'].toString().trim();
        final senderId = msg['senderId'];
        final isSender = isMe(senderId);
        final timestamp = (msg['timestamp'] as Timestamp).toDate();

        if (message == '/accept' || message == '/reject') {
          return const SizedBox.shrink();
        }

        final isAfterAccept = !acceptedShown &&
            index > 0 &&
            messages.sublist(0, index).any((m) =>
                m['message'].toString().toLowerCase() == '/accept');
        if (isAfterAccept) acceptedShown = true;

        final isAfterReject = !rejectedShown &&
            index > 0 &&
            messages.sublist(0, index).any((m) =>
                m['message'].toString().toLowerCase() == '/reject');
        if (isAfterReject) rejectedShown = true;

        return Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (isAfterAccept) buildStatusLabel('ACCEPTED', Colors.green),
            if (isAfterReject) buildStatusLabel('REJECTED', Colors.red),
            Align(
              alignment:
                  isSender ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSender
                      ? const Color.fromRGBO(207, 173, 232, 1.0)
                      : const Color.fromRGBO(171, 229, 188, 1.0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message),
                    const SizedBox(height: 4),
                    Text(timestamp.toString(),
                        style: const TextStyle(
                            fontSize: 10, color: Colors.black54)),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildStatusLabel(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isOwner = currentUser?.uid != widget.chatPartnerId;

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreChatService.getMessages(widget.chatPartnerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('NO MESSAGE YET'));
              }
              return buildMessageList(snapshot);
            },
          ),
        ),
        if (_showAcceptRejectButtons && !_hasResponded && isOwner)
          buildAcceptRejectButtons(),
        if (_hasResponded && isOwner && deliveryMethod == null)
          buildDeliveryButtons(),
        if (deliveryMethod == 'POSTAGE' && subDeliveryOption == null)
          buildSubDeliveryButtons(),
        if (deliveryMethod != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  deliveryMethod == 'MEET-UP'
                      ? Icons.handshake
                      : Icons.local_shipping,
                  color: Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  deliveryMethod!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  inputFormatters: [WordLimitFormatter(500)],
                  decoration: const InputDecoration(
                    hintText: 'TYPE A MESSAGE...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAcceptRejectButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                ChatAutomation.respondToRequest(
                  borrowerId: widget.chatPartnerId,
                  borrowerName: widget.chatPartnerName,
                  accept: true,
                );
                setState(() {
                  _hasResponded = true;
                  _showAcceptRejectButtons = false;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("ACCEPT", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                ChatAutomation.respondToRequest(
                  borrowerId: widget.chatPartnerId,
                  borrowerName: widget.chatPartnerName,
                  accept: false,
                );
                setState(() {
                  _hasResponded = true;
                  _showAcceptRejectButtons = false;
                });
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("REJECT", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

  Widget buildDeliveryButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() => deliveryMethod = 'MEET-UP');
                ChatAutomation.sendMeetupLocation(
                  receiverId: widget.chatPartnerId,
                  city: city ?? '-',
                  state: state ?? '-',
                );
              },
              icon: const Icon(Icons.handshake),
              label: const Text('MEET-UP'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, foregroundColor: Colors.white),
            ),
            ElevatedButton.icon(
              onPressed: () => setState(() => deliveryMethod = 'POSTAGE'),
              icon: const Icon(Icons.local_shipping),
              label: const Text('POSTAGE'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
            ),
          ],
        ),
      );

  Widget buildSubDeliveryButtons() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() => subDeliveryOption = 'FASTEST');
                ChatAutomation.sendFastestDelivery(widget.chatPartnerId);
              },
              child: const Text('FASTEST DELIVERY'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => subDeliveryOption = 'CHEAPEST');
                ChatAutomation.sendCheapestDelivery(widget.chatPartnerId);
              },
              child: const Text('CHEAPEST DELIVERY'),
            ),
          ],
        ),
      );
}