import 'dart:typed_data'; // FIXED: Universal byte support (No dart:io!)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart'; // FIXED: Cross-platform file/PDF picker
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../theme.dart';

class StartupOnboardingScreen extends StatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  State<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState extends State<StartupOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  
  // FIXED: Store platform-agnostic byte streams instead of a File path object
  Uint8List? _certBytes;
  String? _certName;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  // FIXED: Replaced ImagePicker with FilePicker to handle images and PDFs on any device
  Future<void> _pickCert() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    
    if (result != null && result.files.first.bytes != null) {
      setState(() {
        _certBytes = result.files.first.bytes; // Native memory bytes
        _certName = result.files.first.name;   // e.g. "irembo_certificate.pdf"
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_certBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your registration certificate')),
      );
      return;
    }

    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final startupProvider = context.read<StartupProvider>();

    try {
      // FIXED: Handing over bytes and name parameters to the refactored StartupProvider method
      await startupProvider.createStartup(
        founderUid: auth.user!.uid,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        certBytes: _certBytes!,
        certName: _certName!,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/startup-dashboard');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Set Up Your Startup'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.pending),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your startup will be reviewed before you can publish opportunities. This usually takes 24–48 hours.',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: AppColors.onBackground),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Startup Name',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter startup name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'What does your startup do?',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        v == null || v.length < 20 ? 'Please write at least 20 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  Text('Registration Certificate',
                      style: GoogleFonts.poppins(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    'Upload your Irembo or equivalent registration document',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickCert,
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _certBytes != null
                              ? AppColors.verified
                              : AppColors.divider,
                          width: _certBytes != null ? 2 : 1,
                        ),
                      ),
                    
                      child: _certBytes != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 36, color: AppColors.verified),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    _certName ?? 'Document loaded successfully',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.onBackground),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.upload_file_outlined,
                                    size: 32, color: AppColors.textSecondary),
                                const SizedBox(height: 8),
                                Text('Tap to upload certificate',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                          child: const Text('Submit for Verification'),
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
