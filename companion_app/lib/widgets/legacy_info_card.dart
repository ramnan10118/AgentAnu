import 'package:flutter/material.dart';

class LegacyInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isForNok;

  const LegacyInfoCard({
    super.key,
    this.title = 'Your Legacy Plan',
    this.description = 'Give your family peace of mind. When you\'re gone, your beneficiaries get instant, secure access to everything—accounts, assets, documents. No searching. No confusion. Just a clear path forward.',
    this.isForNok = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isForNok 
            ? const Color(0xFFD3F9D8).withOpacity(0.5)
            : const Color(0xFFDBE4FF).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isForNok 
              ? const Color(0xFF40C057).withOpacity(0.3)
              : const Color(0xFF4263EB).withOpacity(0.3),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isForNok
                  ? const Color(0xFF40C057).withOpacity(0.1)
                  : const Color(0xFF4263EB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isForNok ? Icons.verified_user_outlined : Icons.info_outline,
              size: 24,
              color: isForNok 
                  ? const Color(0xFF40C057)
                  : const Color(0xFF4263EB),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isForNok ? 'Assets Revealed' : title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isForNok 
                        ? const Color(0xFF2B8A3E)
                        : const Color(0xFF364FC7),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isForNok 
                      ? 'The death certificate has been verified. You now have access to view and manage the financial assets left behind. Please handle this information responsibly.'
                      : description,
                  style: TextStyle(
                    fontSize: 13,
                    color: isForNok 
                        ? const Color(0xFF2B8A3E).withOpacity(0.8)
                        : const Color(0xFF364FC7).withOpacity(0.8),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFeatureChip(
                      icon: Icons.shield_outlined,
                      label: 'Encrypted & Secure',
                      isForNok: isForNok,
                    ),
                    const SizedBox(width: 16),
                    _buildFeatureChip(
                      icon: isForNok ? Icons.visibility_outlined : Icons.lock_outline,
                      label: isForNok ? 'Full Access' : 'Beneficiary Access',
                      isForNok: isForNok,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required bool isForNok,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: isForNok 
              ? const Color(0xFF2B8A3E).withOpacity(0.7)
              : const Color(0xFF364FC7).withOpacity(0.7),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isForNok 
                ? const Color(0xFF2B8A3E).withOpacity(0.7)
                : const Color(0xFF364FC7).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

