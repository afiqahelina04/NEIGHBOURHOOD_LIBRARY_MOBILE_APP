import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserListScreen extends StatelessWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data!.docs;

        return ListView.builder(
          itemCount: users.length,

          itemBuilder: (context, index) {
            final user = users[index];
            final data = user.data() as Map<String, dynamic>;

            return Card(
              color: const Color.fromARGB(255, 255, 167, 154),
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              
              child: ListTile(
                title: Text(data['name'] ?? 'No Name'),
              
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
              
                  children: [
                    Text(data['email'] ?? 'No Email'),
                    Text('${data['address1'] ?? ''}${data['address2'] != null && data['address2'].toString().isNotEmpty ? ', ${data['address2']}' : ''}'),
                    Text('${data['postcode'] ?? ''}, ${data['city'] ?? ''}, ${data['state'] ?? ''}'),
                    Text('Phone: +6${data['phone'] ?? ''}'),
                  ],
                  
                ),

                isThreeLine: true,

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                 
                  children: [
                 
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                 
                      onPressed: () {
                        _showEditDialog(context, user.id, data);
                      },
                    ),
                 
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('users').doc(user.id).delete();
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

  void _showEditDialog(BuildContext context, String docId, Map<String, dynamic> data) {
    
    final nameController      = TextEditingController(text: data['name']);
    final emailController     = TextEditingController(text: data['email']);
    final address1Controller  = TextEditingController(text: data['address1']);
    final address2Controller  = TextEditingController(text: data['address2']);
    final postcodeController  = TextEditingController(text: data['postcode']);
    final cityController      = TextEditingController(text: data['city']);
    final stateController     = TextEditingController(text: data['state']);
    final phoneController     = TextEditingController(text: data['phone']);

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
              const Text("EDIT USER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'NAME')),
              const SizedBox(height: 12),
              
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'EMAIL')),
              const SizedBox(height: 12),
              
              Row(

                children: [

                  Expanded(

                    child: TextField(
                      readOnly: true,

                      decoration: const InputDecoration(
                        labelText: 'PASSWORD',
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 167, 154),
                      ),

                    ),

                  ),
                  const SizedBox(width: 8),
                  
                  SizedBox(
                    height: 60, // adjust based on TextField height

                    child: ElevatedButton(

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),

                      onPressed: () async {

                        try {
                          
                          final userDoc = await FirebaseFirestore.instance.collection('users').doc(docId).get();
                          final email = userDoc['email'];

                          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Temporary password reset sent to user email.')),
                          );

                        } catch (e) {

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error resetting password: $e')),
                          );

                        }
                      },

                      child: const Text('RESET'),
                    
                    ),
                  ),

                ],

              ),
              const SizedBox(height: 12),

              TextField(controller: address1Controller, decoration: const InputDecoration(labelText: 'ADDRESS 1')),
              const SizedBox(height: 12),

              TextField(controller: address2Controller, decoration: const InputDecoration(labelText: 'ADDRESS 2')),
              const SizedBox(height: 12),
              
              TextField(controller: postcodeController, decoration: const InputDecoration(labelText: 'POSTCODE')),
              const SizedBox(height: 12),
              
              TextField(controller: cityController, decoration: const InputDecoration(labelText: 'CITY')),
              const SizedBox(height: 12),
              
              TextField(controller: stateController, decoration: const InputDecoration(labelText: 'STATE')),
              const SizedBox(height: 12),
              
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'PHONE NUMBER')),
              const SizedBox(height: 24),
              
              ElevatedButton(

                onPressed: () {
                  FirebaseFirestore.instance.collection('users').doc(docId).update({

                    'name'    : nameController.text.trim(),
                    'email'   : emailController.text.trim(),
                    'address1': address1Controller.text.trim(),
                    'address2': address2Controller.text.trim(),
                    'postcode': postcodeController.text.trim(),
                    'city'    : cityController.text.trim(),
                    'state'   : stateController.text.trim(),
                    'phone'   : phoneController.text.trim(),
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