import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/socket_service.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'designation_response_screen.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen> {
  final SocketService _socketService = SocketService();
  String _currentTime = '';
  Timer? _timer;
  Map<String, dynamic>? _pendingDesignation;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _startTimer();
    _initializeSocket();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTime();
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateFormat('hh:mm:ss a').format(DateTime.now());
    });
  }

  void _initializeSocket() {
    print('🔌 [INITIAL-SCREEN] Initializing socket (no auth)...');

    // Set up socket listener for NOK designation
    _socketService.onNokDesignated = (data) {
      print('📨 [INITIAL-SCREEN] ✅ Received designation notification!');
      print('📨 [INITIAL-SCREEN] Data: $data');

      if (mounted) {
        setState(() {
          _pendingDesignation = data;
        });

        // Show notification dialog
        _showDesignationNotification(data);
      } else {
        print('⚠️ [INITIAL-SCREEN] Widget not mounted, cannot show notification');
      }
    };

    // Set up authenticated callback
    _socketService.onAuthenticated = (data) {
      print('✅ [INITIAL-SCREEN] Socket connected (anonymous)');
    };

    // Set up error callback
    _socketService.onError = (error) {
      print('❌ [INITIAL-SCREEN] Socket error: $error');
    };

    // Connect socket (no authentication needed)
    print('🔌 [INITIAL-SCREEN] Connecting socket...');
    _socketService.connect();
    print('🔌 [INITIAL-SCREEN] Socket connection initiated');
  }

  Future<void> _autoLoginAndShowDetails(Map<String, dynamic> designation) async {
    final nokMobile = designation['nokMobile'];

    if (nokMobile == null || nokMobile.toString().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No mobile number in designation'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppConstants.primaryColor),
      ),
    );

    try {
      print('🔐 [AUTO-LOGIN] Starting auto-login for $nokMobile');

      // Auto-login with mock OTP
      await ref.read(authProvider.notifier).sendOtp(nokMobile);
      await ref.read(authProvider.notifier).verifyOtp(nokMobile, '123456');

      print('✅ [AUTO-LOGIN] Authentication successful');

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Now navigate to Accept/Reject screen (authenticated)
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DesignationResponseScreen(
              designation: designation,
            ),
          ),
        );
      }
    } catch (error) {
      print('❌ [AUTO-LOGIN] Failed: $error');

      // Close loading and show error
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: $error'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  void _showDesignationNotification(Map<String, dynamic> data) {
    final accountHolderName = data['accountHolderName'] ?? 'Someone';
    final relationship = data['relationship'] ?? 'next of kin';
    final nokMobile = data['nokMobile'] ?? '';
    final nokName = data['nokName'] ?? 'you';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: AppConstants.primaryColor),
            SizedBox(width: 8),
            Text('New Designation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You have been designated!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('From', accountHolderName),
            _buildInfoRow('For', nokName),
            _buildInfoRow('Mobile', nokMobile),
            _buildInfoRow('As', relationship.toUpperCase()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close notification dialog
              _autoLoginAndShowDetails(data); // Auto-login then show details
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppConstants.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    // Don't disconnect socket - keep it running
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentTime,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: AppConstants.textColor,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for notifications...',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 32),
            if (_pendingDesignation != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppConstants.primaryColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.notifications_active,
                      color: AppConstants.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Designation pending',
                      style: TextStyle(
                        color: AppConstants.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _autoLoginAndShowDetails(_pendingDesignation!);
                      },
                      child: const Text('Open'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
