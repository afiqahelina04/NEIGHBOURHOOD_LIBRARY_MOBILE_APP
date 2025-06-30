import 'package:flutter/material.dart';

class EditProfileForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController address1Controller;
  final TextEditingController address2Controller;
  final TextEditingController postcodeController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final List<String> availableGenres;
  final List<String> malaysianStates;
  final List<String> selectedGenres;
  final String? selectedState;
  final String selectedCat;
  final Function(String) onCatSelected;
  final Function(String) onGenreAdd;
  final Function(String) onGenreRemove;
  final Function(String?) onStateChanged;
  final VoidCallback onSave;

  const EditProfileForm({
    super.key,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.address1Controller,
    required this.address2Controller,
    required this.postcodeController,
    required this.cityController,
    required this.phoneController,
    required this.availableGenres,
    required this.malaysianStates,
    required this.selectedGenres,
    required this.selectedState,
    required this.selectedCat,
    required this.onCatSelected,
    required this.onGenreAdd,
    required this.onGenreRemove,
    required this.onStateChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text("CHOOSE YOUR PROFILE PICTURE", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['assets/cat1.png', 'assets/cat2.png', 'assets/cat3.png', 'assets/cat4.png'].map((cat) {
                return GestureDetector(
                  onTap: () => onCatSelected(cat),
                  child: CircleAvatar(
                    radius: selectedCat == cat ? 42 : 36,
                    backgroundColor: selectedCat == cat ? Colors.orangeAccent : Colors.transparent,
                    child: CircleAvatar(radius: 36, backgroundImage: AssetImage(cat)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            TextFormField(
              controller: nameController,
              maxLength: 50,
              decoration: const InputDecoration(
                labelText: 'FULL NAME (max 50 characters)',
                prefixIcon: Icon(Icons.person),
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().isEmpty || value.length > 50
                  ? 'Please enter a name under 50 characters.'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: emailController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'EMAIL (READ ONLY)',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('NEW PASSWORD (LEAVE BLANK TO KEEP CURRENT)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: address1Controller,
              maxLength: 25,
              decoration: const InputDecoration(
                labelText: 'ADDRESS 1 (REQUIRED)',
                prefixIcon: Icon(Icons.home),
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().isEmpty || value.length > 25
                  ? 'Enter address under 25 characters.'
                  : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: address2Controller,
              maxLength: 25,
              decoration: const InputDecoration(
                labelText: 'ADDRESS 2 (OPTIONAL)',
                prefixIcon: Icon(Icons.home_outlined),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: postcodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'POSTCODE',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Postcode is required.';
                if (!RegExp(r'^\d{5}$').hasMatch(trimmed)) return 'Enter a valid numeric postcode.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: cityController,
              maxLength: 20,
              decoration: const InputDecoration(
                labelText: 'CITY',
                prefixIcon: Icon(Icons.location_city),
                counterText: '',
              ),
              validator: (value) => value == null || value.trim().isEmpty || value.length > 20
                  ? 'Enter a valid city name (max 20 characters).'
                  : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: selectedState,
              decoration: const InputDecoration(
                labelText: 'STATE',
                prefixIcon: Icon(Icons.map),
              ),
              items: malaysianStates.map((state) => DropdownMenuItem(value: state, child: Text(state))).toList(),
              onChanged: onStateChanged,
              validator: (value) => value == null ? 'Please select a state.' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.number,
              maxLength: 11,
              decoration: InputDecoration(
                labelText: 'PHONE NUMBER',
                counterText: '',
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(59, 248, 248, 248),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: const Text('+6', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Phone number is required.';
                if (!RegExp(r'^\d+$').hasMatch(value)) return 'Enter digits only.';
                if (value.length < 9 || value.length > 11) return 'Phone number must be 9 to 11 digits.';
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'PREFERRED GENRE(S)',
                prefixIcon: Icon(Icons.book),
              ),
              items: availableGenres.map((genre) => DropdownMenuItem(value: genre, child: Text(genre))).toList(),
              onChanged: (value) => value != null ? onGenreAdd(value) : null,
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: selectedGenres.map((genre) => Chip(
                label: Text(genre),
                deleteIcon: const Icon(Icons.close),
                onDeleted: () => onGenreRemove(genre),
              )).toList(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSave,
                child: const Text('SAVE CHANGES'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}