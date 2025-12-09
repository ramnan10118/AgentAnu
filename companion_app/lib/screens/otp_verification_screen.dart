import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'designation_response_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> designation;

  const OtpVerificationScreen({
    super.key,
    required this.designation,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  String? _error;

  final String _mockOtp = '123456'; // Same as backend mock OTP

  void _verifyOtp() {
    setState(() {
      _isVerifying = true;
      _error = null;
    });

    final enteredOtp = _otpController.text.trim();

    // Simulate verification delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (enteredOtp == _mockOtp) {
        // OTP correct - navigate to accept/reject screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DesignationResponseScreen(
                designation: widget.designation,
              ),
            ),
          );
        }
      } else {
        // OTP incorrect
        setState(() {
          _isVerifying = false;
          _error = 'Incorrect OTP. Try $_mockOtp';
        });
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountHolderName = widget.designation['accountHolderName'] ?? 'Unknown';
    final relationship = widget.designation['relationship'] ?? 'next of kin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const Text(
              'Designation Verification',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            Card(
              color: AppConstants.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingMD),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Designation Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSM),
                    Text(
                      'From: $accountHolderName',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Relationship: ${relationship.toUpperCase()}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),
            const Text(
              'Enter OTP to verify',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingMD),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '------',
                counterText: '',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppConstants.primaryColor,
                    width: 2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppConstants.primaryColor,
                    width: 2,
                  ),
                ),
                errorText: _error,
              ),
              onSubmitted: (_) => _verifyOtp(),
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              'Hint: Use $_mockOtp for testing',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isVerifying
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verify OTP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
