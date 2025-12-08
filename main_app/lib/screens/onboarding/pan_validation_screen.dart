import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';
import '../../config/api_config.dart';
import 'consent_screen.dart';

class PanValidationScreen extends ConsumerStatefulWidget {
  const PanValidationScreen({super.key});

  @override
  ConsumerState<PanValidationScreen> createState() => _PanValidationScreenState();
}

class _PanValidationScreenState extends ConsumerState<PanValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _panController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _panController.dispose();
    super.dispose();
  }

  Future<void> _validatePan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final pan = _panController.text.toUpperCase().trim();
    final success = await ref.read(authProvider.notifier).validatePan(pan);

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ConsentScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PAN validation failed. Please try again.'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Validate PAN'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingLG),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    size: 50,
                    color: AppConstants.primaryColor,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Title
                const Text(
                  'Enter your PAN',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingSM),
                
                // Subtitle
                const Text(
                  'We need your PAN to fetch your financial assets',
                  style: TextStyle(
                    fontSize: 14,
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
                      // PAN input
                      TextFormField(
                        controller: _panController,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 10,
                        validator: Validators.validatePan,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ABCDE1234F',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLG),
                      
                      // Validate button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _validatePan,
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
                                'Continue',
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
                
                // Sample PANs
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🎮 Sample PANs for Demo:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSM),
                      ...ApiConfig.samplePans.map((pan) => Text(
                        '• $pan',
                        style: const TextStyle(fontSize: 14),
                      )),
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

