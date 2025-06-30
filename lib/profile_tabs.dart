import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_screen.dart';
import 'update_book_details_screen.dart';
import 'book_details_screen.dart';


class ProfileTabs extends StatelessWidget {
  final TabController tabController;
  final String name, email, address1, address2, postcode, city, state, phone, profileImagePath;
  final List<String> genres;
  final List<Map<String, dynamic>> userBooks;
  final Future<void> Function() onReloadProfile;

  const ProfileTabs({
    super.key,
    required this.tabController,
    required this.name,
    required this.email,
    required this.address1,
    required this.address2,
    required this.postcode,
    required this.city,
    required this.state,
    required this.phone,
    required this.profileImagePath,
    required this.genres,
    required this.userBooks,
    required this.onReloadProfile,
  });

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      controller: tabController,
      children: [_buildProfileTab(context), _buildBooksTab(context)],
    );
  }

  Widget _buildProfileTab(BuildContext context) {
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      
      child: SingleChildScrollView(
      
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
      
          children: [
            CircleAvatar(radius: 50, backgroundImage: AssetImage(profileImagePath)),
            const SizedBox(height: 24),
      
            _buildInfoRow(Icons.person, 'NAME', name),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.email, 'EMAIL', email),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.home, 'ADDRESS 1', address1),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.home_outlined, 'ADDRESS 2', address2.isEmpty ? '-' : address2),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.location_on, 'POSTCODE', postcode),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.location_city, 'CITY', city),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.map, 'STATE', state),
            const SizedBox(height: 16),
      
            _buildInfoRow(Icons.phone, 'PHONE', '+6$phone'),
            const SizedBox(height: 16),
      
            _buildGenreChips(genres),
            const SizedBox(height: 32),
      
            SizedBox(
              width: double.infinity,
             
              child: ElevatedButton(
             
                onPressed: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()));
                  await onReloadProfile();
                },
             
                child: const Text('EDIT PROFILE'),
             
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooksTab(BuildContext context) {
    if (userBooks.isEmpty) return const Center(child: Text("You haven't uploaded any books yet."));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: userBooks.length,
     
      itemBuilder: (context, index) {
        final book = userBooks[index];
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 10),
          
          child: ListTile(
            leading: book['frontUrl'] != null && book['frontUrl'] != ''
                ? Image.network(book['frontUrl'], width: 50, fit: BoxFit.cover)
                : const Icon(Icons.book, size: 50),
            title: Text(book['title']),
            subtitle: Text(book['author']),
            
            onTap: () => Navigator.push(
              context,
              
              MaterialPageRoute(
                builder: (_) => BookDetailsScreen(
                  title     : book['title'],
                  author    : book['author'],
                  genre     : book['genre'],
                  frontUrl  : book['frontUrl'],
                  topUrl    : book['topUrl'],
                  sideUrl   : book['sideUrl'],
                  synopsis  : book['synopsis'],
                  year      : book['year'],
                  publisher : book['publisher'],
                  language  : book['language'],
                  pages     : book['pages'],
                  ownerId   : FirebaseAuth.instance.currentUser!.uid,
                  ownerName : name,
                ),
              ),
            ),
            
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueAccent),
              tooltip: 'UPDATE BOOK DETAILS',
              
              onPressed: () async {
                
                await Navigator.push(
                  context,
                  
                  MaterialPageRoute(
                    builder: (_) => UpdateBookDetailsScreen(
                      bookData: book,
                      bookId: book['id'],
                    ),
                  ),
                );
                await onReloadProfile();
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    
    return Container(
      padding: const EdgeInsets.all(12),
    
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 167, 154),
        borderRadius: BorderRadius.circular(12),
      ),
    
      child: Row(
    
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
    
          Expanded(
    
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
    
              children: [
                Text(label.toUpperCase(), style: const TextStyle(fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChips(List<String> genres) {
    if (genres.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        const Text('PREFERRED GENRE(S)', style: TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: genres.map((genre) => Chip(label: Text(genre))).toList(),
        ),
      ],
    );
  }
}