import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/env.dart';
import 'auth_service.dart';

/// Payment service for handling Razorpay payments
class PaymentService {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Callbacks
  Function(String)? onPaymentSuccess;
  Function(String)? onPaymentError;
  Function()? onPaymentWalletSelected;

  PaymentService() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  /// Initialize payment for unlocking a doctor
  Future<void> unlockDoctor({
    required String doctorId,
    required String doctorName,
    required double amount,
    required BuildContext context,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) {
        onPaymentError?.call('User not logged in');
        return;
      }

      // Convert amount to paise (Razorpay uses smallest currency unit)
      final amountInPaise = (amount * 100).toInt();

      debugPrint('Initiating Razorpay payment...');
      debugPrint('Key: ${Env.razorpayKeyId}');
      debugPrint('Amount: $amountInPaise paise (\$$amount)');

      var options = {
        'key': Env.razorpayKeyId,
        'amount': amountInPaise,
        'currency': 'INR',
        'name': 'AI Medical Assistant',
        'description': 'Unlock $doctorName',
        'prefill': {
          'email': user.email ?? '',
          'contact': '9999999999',
        },
        'theme': {
          'color': '#2196F3',
        },
        'notes': {
          'doctor_id': doctorId,
          'user_id': user.uid,
        },
      };

      debugPrint('Opening Razorpay checkout...');
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Razorpay error: $e');
      onPaymentError?.call('Failed to initialize payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      // Save unlock status to Firestore
      final paymentData = {
        'userId': user.uid,
        'paymentId': response.paymentId,
        'orderId': response.orderId,
        'signature': response.signature,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'success',
      };

      await _firestore
          .collection('payments')
          .doc(response.paymentId)
          .set(paymentData);

      // Get doctor ID from the payment (you might need to fetch this from your backend)
      // For now, we'll call the success callback with the payment ID
      onPaymentSuccess?.call(response.paymentId ?? '');
    } catch (e) {
      debugPrint('Error saving payment: $e');
      onPaymentError?.call('Payment successful but failed to update records');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    onPaymentError?.call(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    onPaymentWalletSelected?.call();
  }

  /// Check if user has unlocked a specific doctor
  Future<bool> hasUnlockedDoctor(String doctorId) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return false;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('unlocked_doctors')
          .doc(doctorId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking unlock status: $e');
      return false;
    }
  }

  /// Unlock a doctor after successful payment
  Future<void> unlockDoctorInFirestore({
    required String doctorId,
    required String paymentId,
  }) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('unlocked_doctors')
          .doc(doctorId)
          .set({
        'unlockedAt': FieldValue.serverTimestamp(),
        'paymentId': paymentId,
      });
    } catch (e) {
      debugPrint('Error unlocking doctor: $e');
      rethrow;
    }
  }

  /// Get all unlocked doctors for current user
  Future<List<String>> getUnlockedDoctorIds() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('unlocked_doctors')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error fetching unlocked doctors: $e');
      return [];
    }
  }

  void dispose() {
    _razorpay.clear();
  }
}
