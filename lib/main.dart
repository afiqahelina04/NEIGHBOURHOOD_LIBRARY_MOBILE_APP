import 'package:aee_fyp3/book_detail_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'edit_profile_screen.dart';
import 'firebase_options.dart';
import 'register_screen.dart';
import 'donation_screen.dart';
import 'splash_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'NHL MOBILE APP',
      debugShowCheckedModeBanner: false,
     
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color.fromARGB(255, 255, 215, 135),
        primaryColor: const Color.fromARGB(255, 255, 215, 135),
        
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 255, 215, 135),
          secondary: const Color.fromARGB(255, 255, 215, 135),
        ),
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 255, 215, 135),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 255, 167, 154),
            foregroundColor: Colors.black,
        
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
        ),
        
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 167, 154),
        ),
        
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color.fromARGB(255, 10, 10, 10)),
        ),
      ),

      initialRoute: '/',
      
      routes: {
        '/'         : (context) => const SplashScreen(),
        '/login'    : (context) => const LoginScreen(),
        '/register' : (context) => const RegisterScreen(),
        '/home'     : (context) => const HomeScreen(),
        '/upload'   : (context) => const BookDetailFormScreen(),
        '/donate'   : (context) => const DonationScreen(),
        '/profile'  : (context) => const EditProfileScreen(),
        '/admin'    : (context) => const AdminScreen(), 
      },
    
    );
  
  }

}