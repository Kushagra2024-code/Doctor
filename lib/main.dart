import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/env.dart';
import 'firebase_options.dart';
import 'app.dart';

/// Main entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await Env.load();

  // Initialize Firebase (FREE tier)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    print('App will continue without Firebase features');
  }

  // Run the app
  runApp(const MyApp());
}
