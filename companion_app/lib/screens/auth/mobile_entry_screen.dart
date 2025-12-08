import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import 'otp_verification_screen.dart';

class MobileEntryScreen extends ConsumerStatefulWidget {
  const MobileEntryScreen({super.key});

  @override
  ConsumerState<MobileEntryScreen> createState() => _MobileEntryScreenState();
}

class _MobileEntryScreenState extends ConsumerState<MobileEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final mobile = _mobileController.text.trim();
    final success = await ref.read(authProvider.notifier).sendOtp(mobile);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(mobile: mobile),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo/Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    size: 60,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Title
                const Text(
                  'Welcome to Sunset',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSM),
                
                // Subtitle
                const Text(
                  'Secure your financial legacy',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingXL * 2),
                
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Enter your mobile number',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      
                      // Mobile input
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validateMobile,
                        decoration: InputDecoration(
                          hintText: '+919876543210',
                          prefixIcon: const Icon(Icons.phone),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLG),
                      
                      // Send OTP button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.spacingMD,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacingXL),
                
                // Demo info
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                    border: Border.all(
                      color: AppConstants.secondaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎮 Demo Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingSM),
                      Text(
                        'Use any mobile number\nOTP: 123456',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

