import 'package:flutter/material.dart';


class FpxSuccessScreen extends StatelessWidget {
  const FpxSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    
      appBar: AppBar(
        title: const Text('DONATION SUCCESS'),
        centerTitle: true,
        ),

      body: Center(
    
        child: Padding(
          padding: const EdgeInsets.all(24.0),
    
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
    
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),

              const Text(
                'THANK YOU FOR YOUR DONATION!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              const Text(
                'Your payment has been successfully simulated.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); 
                },
                child: const Text('BACK TO DONATION PAGE'),
             
              ),
            ],
         
          ),
        
        ),
      
      ),
    
    );
  
  }

}