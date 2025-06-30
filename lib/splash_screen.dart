import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dart:async';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override _SplashScreenState createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen>

    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
   
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
   
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => LoginScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
   
      body: Center(
   
        child: FadeTransition(
          opacity: _animation,
   
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
   
            children: const [
              
              Text(
                'NHL \nMOBILE APP',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(207, 173, 232, 1.0)
                ),
              ),
              
              SizedBox(height: 20),
              CircularProgressIndicator(color: Color.fromRGBO(255, 250, 240, 1.0)),
            ],
   
          ),
        ),
   
      ),
   
    );
  
  }

}