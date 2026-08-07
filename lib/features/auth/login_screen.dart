import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Add this line

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Left Logo Icon
              // Top Left Logo Icon (Nudged to the left)
              Align(
                alignment: Alignment.topLeft,
                child: Transform.translate(
                  offset: const Offset(-12, 0), // The "-12" pulls it 12 pixels to the left. Adjust this number to your liking!
                  child: Image.asset(
                    'assets/images/logo.png', 
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const Spacer(),

              // Headings
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Analyze any GitHub repository\nin a few clicks.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),

             // GitHub Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                  
                    // Navigate to the select repository screen
                    Navigator.pushNamed(context, '/select_repo');
                  
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // The new Font Awesome GitHub Icon!
                      FaIcon(
                        FontAwesomeIcons.github,
                        color: Colors.white,
                        size: 24,
                      ), 
                      SizedBox(width: 12),
                      Text(
                        'Continue with GitHub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // "or" Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey.shade200, thickness: 1.5),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'or',
                      style: TextStyle(
                        color: Color(0xFF94A3B8), 
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey.shade200, thickness: 1.5),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Paste URL Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/add_repo');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Paste repository URL',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Terms and Privacy Footer
             
            ],
          ),
        ),
      ),
    );
  }
}