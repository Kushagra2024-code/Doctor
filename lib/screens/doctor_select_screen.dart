import 'package:flutter/material.dart';
import '../data/doctors.dart';
import '../models/doctor.dart';
import '../widgets/doctor_card.dart';
import '../services/auth_service.dart';
import 'consultation_screen.dart';
import 'login_screen.dart';

/// Doctor selection screen
class DoctorSelectScreen extends StatelessWidget {
  const DoctorSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authService = AuthService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Doctor'),
        actions: [
          // User profile icon
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _showProfileDialog(context, authService),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'Choose Your AI Doctor',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a doctor specialization for your consultation',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Doctor Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: availableDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = availableDoctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    onTap: () => _selectDoctor(context, doctor),
                  );
                },
              ),
            ),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              color: theme.colorScheme.errorContainer.withOpacity(0.3),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This app provides information only, not medical advice. Always consult a real healthcare provider.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDoctor(BuildContext context, Doctor doctor) {
    if (doctor.isPremium) {
      // Show locked dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.lock, size: 48),
          title: const Text('Premium Doctor'),
          content: Text(
            '${doctor.name} is a premium doctor.\n\n'
            'Upgrade not available (Demo restriction).\n\n'
            'In a real app, you could implement a payment system here.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Navigate to consultation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ConsultationScreen(doctor: doctor),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, AuthService authService) {
    final user = authService.currentUser;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text('Email: ${user.email ?? "Anonymous"}'),
              Text('User ID: ${user.uid.substring(0, 8)}...'),
            ] else ...[
              const Text('Not logged in'),
            ],
          ],
        ),
        actions: [
          if (user != null)
            TextButton(
              onPressed: () async {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Logout'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
