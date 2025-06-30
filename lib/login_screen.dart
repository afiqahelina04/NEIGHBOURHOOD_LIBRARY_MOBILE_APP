import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _email    = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading       = false;
  
  void _login() async {
    
      FocusScope.of(context).unfocus(); // Hide keyboard
      setState(() => _isLoading = true);

      try {
        UserCredential result = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        final email = result.user!.email;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful")),
        );

        if (email == 'admin@gmail.com') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      
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
   
      appBar: AppBar(
        title: const Text('NHL MOBILE APP'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
   
      body: Center(
   
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
   
          child: Column(
   
            children: [
              const Text(
                'LOGIN TO CONTINUE',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'EMAIL',
                  labelStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _password,
                obscureText: _obscurePassword,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: 'PASSWORD',
                  labelStyle: const TextStyle(color: Colors.black),
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
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                      ),
                      child: const Text("LOGIN"),
                    ),
            
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: const Text(
                  "DON'T HAVE AN ACCOUNT? REGISTER HERE",
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