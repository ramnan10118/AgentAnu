import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/nok_provider.dart';
import '../services/socket_service.dart';
import '../utils/constants.dart';
import 'dashboard/nok_dashboard_screen.dart';
import 'auth/mobile_entry_screen.dart';

class DesignationResponseScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> designation;

  const DesignationResponseScreen({
    super.key,
    required this.designation,
  });

  @override
  ConsumerState<DesignationResponseScreen> createState() =>
      _DesignationResponseScreenState();
}

class _DesignationResponseScreenState
    extends ConsumerState<DesignationResponseScreen> {
  final TextEditingController _rejectionReasonController =
      TextEditingController();
  bool _isProcessing = false;

  Future<void> _acceptDesignation() async {
    setState(() => _isProcessing = true);

    try {
      final designationId = widget.designation['designationId'] as String;
      final success =
          await ref.read(nokProvider.notifier).acceptDesignation(designationId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Designation accepted successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Navigate to NOK dashboard or login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileEntryScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept designation'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _rejectDesignation() async {
    final reason = _rejectionReasonController.text.trim();

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide a reason for rejection'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final designationId = widget.designation['designationId'] as String;
      final success = await ref
          .read(nokProvider.notifier)
          .rejectDesignation(designationId, reason);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Designation rejected'),
            backgroundColor: AppConstants.errorColor,
          ),
        );

        // Navigate back to initial screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MobileEntryScreen()),
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject designation'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showRejectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Designation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a reason for rejection:'),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Enter reason...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectDesignation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountHolderName =
        widget.designation['accountHolderName'] ?? 'Unknown';
    final relationship = widget.designation['relationship'] ?? 'next of kin';
    final designatedAt = widget.designation['designatedAt'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Designation Response'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.person_add,
              size: 80,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: AppConstants.spacingLG),
            const Text(
              'You have been designated as',
              style: TextStyle(
                fontSize: 18,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSM),
            Text(
              relationship.toUpperCase(),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spacingLG),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Designation Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingMD),
                    _buildDetailRow('Account Holder', accountHolderName),
                    const SizedBox(height: AppConstants.spacingSM),
                    _buildDetailRow('Relationship', relationship),
                    const SizedBox(height: AppConstants.spacingSM),
                    _buildDetailRow(
                      'Designated On',
                      designatedAt.isNotEmpty
                          ? DateTime.parse(designatedAt)
                              .toLocal()
                              .toString()
                              .split('.')[0]
                          : 'N/A',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),
            const Text(
              'As Next of Kin, you will have access to manage the account holder\'s financial assets in the event of their passing.',
              style: TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingXL),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _acceptDesignation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.successColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: const Text(
                  'Accept Designation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMD),
            SizedBox(
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _isProcessing ? null : _showRejectDialog,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppConstants.errorColor,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(
                  Icons.cancel,
                  color: AppConstants.errorColor,
                ),
                label: const Text(
                  'Reject Designation',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.errorColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
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
    );
  }
}
