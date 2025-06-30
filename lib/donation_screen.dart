import 'package:flutter/material.dart';
import 'fpx_success_screen.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  final TextEditingController amountController = TextEditingController();
  bool isProcessing = false;

  void processDonation() async {
    final amountText = amountController.text.trim();
    
    if (amountText.isEmpty || double.tryParse(amountText) == null) {
      showSnackBar("PLEASE ENTER A VALID AMOUNT IN MYR");
      return;
    }

    setState(() => isProcessing = true);

    // Simulated payment flow
    await Future.delayed(const Duration(seconds: 2));

    setState(() => isProcessing = false);

    showDialog(
      context: context,

      builder: (context) => AlertDialog(

        title: const Text(
          'DONATION SUCCESSFUL!',
          textAlign: TextAlign.center,
        ),

        content: Text(
          'THANK YOU FOR DONATING RM$amountText TO OUR COMMUNITY!',
          textAlign: TextAlign.center,
        ),

        actions: [

          Row(
            mainAxisAlignment: MainAxisAlignment.center, // center the button
            children: [
              
              TextButton(

                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FpxSuccessScreen()),
                  );
                },

                child: const Text('OK'),
              
              ),
            ],
          ),
        
        ],
      
      ),
    
    );

    amountController.clear();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
    
      appBar: AppBar(
        title: const Text("DONATE TO THE COMMUNITY"),
        centerTitle: true,
      ),
    
      body: Padding(
        padding: const EdgeInsets.all(20),
    
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          
          children: [
          
            const Text(
              "SUPPORT BOOK EVENTS AND COMMUNITY GROWTH WITH YOUR DONATION!",
              style: TextStyle(fontSize: 16),
              textAlign:TextAlign.center,
            ),
            const SizedBox(height: 20),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "AMOUNT (MYR)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: isProcessing
                  ? const CircularProgressIndicator()

                  : ElevatedButton.icon(
                      icon: const Icon(Icons.payment),
                      label: const Text("DONATE WITH FPX"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 167, 154),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                      ),
                      onPressed: processDonation,
                    ),
            ),
          ],
        ),
      ),
    );
  
  }

}