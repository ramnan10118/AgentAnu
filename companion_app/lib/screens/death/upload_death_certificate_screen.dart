import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/designation_model.dart';
import '../../providers/assets_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import 'assets_revealed_screen.dart';

class UploadDeathCertificateScreen extends ConsumerStatefulWidget {
  final DesignationModel designation;

  const UploadDeathCertificateScreen({
    super.key,
    required this.designation,
  });

  @override
  ConsumerState<UploadDeathCertificateScreen> createState() =>
      _UploadDeathCertificateScreenState();
}

class _UploadDeathCertificateScreenState
    extends ConsumerState<UploadDeathCertificateScreen> {
  String? _fileName;
  String? _fileData;
  bool _isUploading = false;
  bool _isVerifying = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileData = base64Encode(result.files.single.bytes!);
      });
    }
  }

  Future<void> _uploadCertificate() async {
    if (_fileData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a file first'),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final response = await ApiService().uploadDeathCertificate(
        accountHolderMobile: widget.designation.accountHolderMobile!,
        fileName: _fileName!,
        fileData: _fileData!,
      );

      if (mounted && response['success'] == true) {
        setState(() {
          _isUploading = false;
          _isVerifying = true;
        });

        // Show verification pending
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Certificate uploaded. Verifying...'),
            backgroundColor: AppConstants.successColor,
            duration: Duration(seconds: 3),
          ),
        );

        // Wait for auto-verification (5 seconds as per backend)
        await Future.delayed(const Duration(seconds: 6));

        if (mounted) {
          // Fetch revealed assets
          final assetsSuccess = await ref
              .read(assetsProvider.notifier)
              .getRevealedAssets(widget.designation.accountHolderId);

          setState(() => _isVerifying = false);

          if (assetsSuccess && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AssetsRevealedScreen(
                  designation: widget.designation,
                ),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() => _isUploading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Upload failed'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
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
        title: const Text('Upload Death Certificate'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLG),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              Card(
                color: AppConstants.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info, color: AppConstants.primaryColor),
                          SizedBox(width: AppConstants.spacingMD),
                          Text(
                            'Initiate Asset Retrieval',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      Text(
                        'Account Holder: ${widget.designation.accountHolderName}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: AppConstants.spacingSM),
                      const Text(
                        'Upload a death certificate to access the assets. The certificate will be verified before granting access.',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingXL),
              
              if (_isVerifying) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingXL),
                  child: const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppConstants.spacingLG),
                      Text(
                        'Verifying death certificate...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppConstants.spacingSM),
                      Text(
                        'This usually takes a few seconds',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // File picker
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingLG),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _fileName != null
                          ? AppConstants.successColor
                          : Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _fileName != null ? Icons.check_circle : Icons.upload_file,
                        size: 64,
                        color: _fileName != null
                            ? AppConstants.successColor
                            : Colors.grey,
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      Text(
                        _fileName ?? 'No file selected',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _fileName != null
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMD),
                      OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Select File'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMD),
                
                const Text(
                  'Accepted formats: PDF, JPG, PNG',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Upload button
                ElevatedButton(
                  onPressed: _isUploading || _fileName == null
                      ? null
                      : _uploadCertificate,
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
                  child: _isUploading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Upload Certificate',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: AppConstants.spacingXL),
                
                // Demo note
                Container(
                  padding: const EdgeInsets.all(AppConstants.spacingMD),
                  decoration: BoxDecoration(
                    color: AppConstants.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
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
                        'Any file will be accepted and auto-verified in 5 seconds.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

