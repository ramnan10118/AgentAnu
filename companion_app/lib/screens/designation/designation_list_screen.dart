import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/nok_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../../models/designation_model.dart';

class DesignationListScreen extends ConsumerWidget {
  const DesignationListScreen({super.key});

  Future<void> _acceptDesignation(
    BuildContext context,
    WidgetRef ref,
    DesignationModel designation,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Designation'),
        content: Text(
          'Do you accept to be the Next of Kin for ${designation.accountHolderName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.successColor,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(nokProvider.notifier)
          .acceptDesignation(designation.id);

      if (success && context.mounted) {
        // Emit socket event
        SocketService().emitNokAccept(designation.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Designation accepted successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  Future<void> _rejectDesignation(
    BuildContext context,
    WidgetRef ref,
    DesignationModel designation,
  ) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Reject Designation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please provide a reason for rejection:'),
              const SizedBox(height: AppConstants.spacingMD),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Reason...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.errorColor,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (reason != null && reason.isNotEmpty && context.mounted) {
      final success = await ref
          .read(nokProvider.notifier)
          .rejectDesignation(designation.id, reason);

      if (success && context.mounted) {
        // Emit socket event
        SocketService().emitNokReject(designation.id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Designation rejected'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nokState = ref.watch(nokProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Designations'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: nokState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : nokState.designations.isEmpty
              ? const Center(child: Text('No designations'))
              : ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  itemCount: nokState.designations.length,
                  itemBuilder: (context, index) {
                    final designation = nokState.designations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppConstants.spacingMD),
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      AppConstants.primaryColor.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.person,
                                    color: AppConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: AppConstants.spacingMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        designation.accountHolderName ?? 'Unknown',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        designation.accountHolderMobile ?? '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppConstants.spacingMD,
                                    vertical: AppConstants.spacingSM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: designation.isPending
                                        ? AppConstants.secondaryColor.withOpacity(0.2)
                                        : designation.isAccepted
                                            ? AppConstants.successColor
                                                .withOpacity(0.2)
                                            : AppConstants.errorColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppConstants.radiusSM,
                                    ),
                                  ),
                                  child: Text(
                                    designation.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: designation.isPending
                                          ? AppConstants.secondaryColor
                                          : designation.isAccepted
                                              ? AppConstants.successColor
                                              : AppConstants.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingMD),
                            const Divider(),
                            const SizedBox(height: AppConstants.spacingMD),
                            Row(
                              children: [
                                const Icon(
                                  Icons.family_restroom,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: AppConstants.spacingSM),
                                Text(
                                  'Relationship: ${designation.relationshipLabel}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spacingSM),
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: AppConstants.spacingSM),
                                Text(
                                  'Designated: ${designation.designatedAt.split('T')[0]}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            if (designation.isPending) ...[
                              const SizedBox(height: AppConstants.spacingLG),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () =>
                                          _rejectDesignation(context, ref, designation),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppConstants.errorColor,
                                        side: const BorderSide(
                                          color: AppConstants.errorColor,
                                        ),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ),
                                  const SizedBox(width: AppConstants.spacingMD),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _acceptDesignation(context, ref, designation),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppConstants.successColor,
                                      ),
                                      child: const Text('Accept'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

