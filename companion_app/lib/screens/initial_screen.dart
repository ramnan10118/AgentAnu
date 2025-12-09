import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/socket_service.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/bottom_notification_card.dart';
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
  bool _showNotification = false;

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
          _showNotification = true;
        });
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


  @override
  void dispose() {
    _timer?.cancel();
    // Don't disconnect socket - keep it running
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/gradient_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Main content (clock + waiting text)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Waiting for notifications...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // Bottom notification card with animation
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            bottom: _showNotification ? 0 : -300,
            left: 0,
            right: 0,
            child: _pendingDesignation != null
                ? BottomNotificationCard(
                    title: _pendingDesignation!['accountHolderName'] ?? 'Someone',
                    subtitle: 'has designated you as NOK',
                    statusText: 'Relationship: ${(_pendingDesignation!['relationship'] ?? 'next of kin').toString().toUpperCase()}',
                    onTap: () {
                      setState(() {
                        _showNotification = false;
                      });
                      // Optional: Navigate to details after delay
                      Future.delayed(const Duration(milliseconds: 300), () {
                        if (mounted) {
                          _autoLoginAndShowDetails(_pendingDesignation!);
                        }
                      });
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
