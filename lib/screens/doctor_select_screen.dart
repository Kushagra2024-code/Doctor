import 'package:flutter/material.dart';
import '../data/doctors.dart';
import '../models/doctor.dart';
import '../widgets/doctor_card.dart';
import '../services/auth_service.dart';
import '../services/payment_service.dart';
import 'consultation_screen.dart';
import 'login_screen.dart';

/// Doctor selection screen
class DoctorSelectScreen extends StatefulWidget {
  const DoctorSelectScreen({super.key});

  @override
  State<DoctorSelectScreen> createState() => _DoctorSelectScreenState();
}

class _DoctorSelectScreenState extends State<DoctorSelectScreen> {
  final PaymentService _paymentService = PaymentService();
  List<String> _unlockedDoctorIds = [];
  bool _isLoadingUnlocks = true;

  @override
  void initState() {
    super.initState();
    _loadUnlockedDoctors();
    _setupPaymentCallbacks();
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  Future<void> _loadUnlockedDoctors() async {
    final unlockedIds = await _paymentService.getUnlockedDoctorIds();
    setState(() {
      _unlockedDoctorIds = unlockedIds;
      _isLoadingUnlocks = false;
    });
  }

  void _setupPaymentCallbacks() {
    _paymentService.onPaymentSuccess = (paymentId) async {
      // Payment successful - need to unlock the doctor
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Payment successful! Doctor unlocked.'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadUnlockedDoctors();
      }
    };

    _paymentService.onPaymentError = (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Payment failed: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    };
  }

  bool _isDoctorUnlocked(Doctor doctor) {
    return !doctor.isPremium || _unlockedDoctorIds.contains(doctor.id);
  }

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
              child: _isLoadingUnlocks
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
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
                          isUnlocked: _isDoctorUnlocked(doctor),
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

  void _selectDoctor(BuildContext context, Doctor doctor) async {
    // Check if doctor is unlocked
    final isUnlocked = _isDoctorUnlocked(doctor);
    
    if (doctor.isPremium && !isUnlocked) {
      // Show payment dialog
      _showPaymentDialog(context, doctor);
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

  void _showPaymentDialog(BuildContext context, Doctor doctor) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  doctor.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    doctor.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    doctor.qualification,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 8),
            
            // Features
            _buildFeatureItem(
              icon: Icons.workspace_premium,
              text: 'Specialized AI doctor',
              theme: theme,
            ),
            _buildFeatureItem(
              icon: Icons.chat_bubble_outline,
              text: 'Unlimited consultations',
              theme: theme,
            ),
            _buildFeatureItem(
              icon: Icons.medical_information,
              text: 'Detailed medical reports',
              theme: theme,
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Unlock Price:',
                  style: theme.textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '\$${doctor.pricePerConsultation.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await _initiatePayment(doctor);
            },
            icon: const Icon(Icons.payment),
            label: const Text('Pay Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _initiatePayment(Doctor doctor) async {
    try {
      // Store the current doctor ID for later reference
      final doctorId = doctor.id;
      
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Initiating payment...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Set up success callback to unlock doctor
      final originalCallback = _paymentService.onPaymentSuccess;
      _paymentService.onPaymentSuccess = (paymentId) async {
        // Unlock doctor in Firestore
        await _paymentService.unlockDoctorInFirestore(
          doctorId: doctorId,
          paymentId: paymentId,
        );
        
        // Call original callback
        if (originalCallback != null) {
          originalCallback(paymentId);
        }
        
        // Restore original callback
        _paymentService.onPaymentSuccess = originalCallback;
      };

      // Initiate payment
      await _paymentService.unlockDoctor(
        doctorId: doctor.id,
        doctorName: doctor.name,
        amount: doctor.pricePerConsultation,
        context: context,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initiate payment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
