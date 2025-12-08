import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/assets_provider.dart';
import '../../utils/constants.dart';
import 'asset_loading_screen.dart';

class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreed = false;
  bool _isLoading = false;

  Future<void> _grantConsent() async {
    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to terms to continue'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await ref.read(assetsProvider.notifier).grantConsent();

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AssetLoadingScreen(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to grant consent'),
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
        title: const Text('Grant Consent'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(
                        Icons.security,
                        size: 80,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),
                      
                      const Text(
                        'Account Aggregator Consent',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      
                      const Text(
                        'We need your permission to fetch your financial assets through the Account Aggregator framework.',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingXL),
                      
                      // Consent details card
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingMD),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What we will access:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: AppConstants.spacingMD),
                            _ConsentItem(
                              icon: Icons.account_balance,
                              text: 'Bank Accounts',
                            ),
                            _ConsentItem(
                              icon: Icons.trending_up,
                              text: 'Mutual Funds',
                            ),
                            _ConsentItem(
                              icon: Icons.security,
                              text: 'Insurance Policies',
                            ),
                            _ConsentItem(
                              icon: Icons.savings,
                              text: 'Fixed Deposits',
                            ),
                            _ConsentItem(
                              icon: Icons.account_balance_wallet,
                              text: 'NPS Accounts',
                            ),
                            _ConsentItem(
                              icon: Icons.show_chart,
                              text: 'Securities',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingLG),
                      
                      // Privacy note
                      Container(
                        padding: const EdgeInsets.all(AppConstants.spacingMD),
                        decoration: BoxDecoration(
                          color: AppConstants.successColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock, color: AppConstants.successColor),
                            SizedBox(width: AppConstants.spacingMD),
                            Expanded(
                              child: Text(
                                'Your data is encrypted and secure. We only access read-only information.',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Agreement checkbox
              CheckboxListTile(
                value: _agreed,
                onChanged: (value) => setState(() => _agreed = value ?? false),
                title: const Text(
                  'I agree to share my financial data through Account Aggregator',
                  style: TextStyle(fontSize: 14),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppConstants.primaryColor,
              ),
              const SizedBox(height: AppConstants.spacingMD),
              
              // Grant consent button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _grantConsent,
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
                          'Grant Consent',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ConsentItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingSM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppConstants.primaryColor),
          const SizedBox(width: AppConstants.spacingMD),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

