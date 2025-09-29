import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationStatus();
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      // Add a small delay for better UX
      await Future.delayed(const Duration(seconds: 2));

      // Check if user is already authenticated
      final authResult = await AuthService.autoLogin();

      if (mounted) {
        if (authResult != null && authResult.isSuccess) {
          // User is authenticated, go to home
          context.go('/home');
        } else {
          // User is not authenticated, go to auth screen
          context.go('/auth');
        }
      }
    } catch (e) {
      // If there's an error, go to auth screen
      if (mounted) {
        context.go('/auth');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/medinote_logo.png',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
            const SizedBox(height: 32),
            Text(
              'MediNote',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI-Powered Medical Transcription',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade500),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.blueGrey.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Initializing...',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
