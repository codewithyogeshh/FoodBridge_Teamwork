import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/ngo_model.dart';
import '../../../data/repositories/app_repository.dart';

class NGORegisterScreen extends StatefulWidget {
  final AppRepository repository;
  final void Function(NGOModel ngo) onRegistered;
  final void Function(NGOModel ngo)? onExistingSignedIn;
  final VoidCallback? onBackToRoles;

  const NGORegisterScreen({
    super.key,
    required this.repository,
    required this.onRegistered,
    this.onExistingSignedIn,
    this.onBackToRoles,
  });

  @override
  State<NGORegisterScreen> createState() => _NGORegisterScreenState();
}

class _NGORegisterScreenState extends State<NGORegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Existing NGO Sign-in
  final _signInQueryController = TextEditingController();
  bool _isCheckingAccount = false;
  String? _signInError;

  // Registration Controllers (STRICTLY CLEAN: zero pre-filled text from other users)
  final _orgNameController = TextEditingController();
  final _regNumController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _capacityController = TextEditingController();
  final _certIdController = TextEditingController();

  // Compulsory Government Identity
  String _govtIdType = 'Aadhaar Card';
  final _govtIdNumberController = TextEditingController();

  // Real Uploaded Document States (Real file bytes, URLs & upload loading indicators)
  Uint8List? _govtDocBytes;
  String? _govtDocUrl;
  String _govtDocFileName = '';
  String _govtDocFileSize = '';
  bool _govtDocAttached = false;
  bool _isUploadingGovtDoc = false;

  Uint8List? _fssaiDocBytes;
  String? _fssaiDocUrl;
  String _fssaiDocFileName = '';
  String _fssaiDocFileSize = '';
  bool _fssaiDocAttached = false;
  bool _isUploadingFssaiDoc = false;

  bool _isSubmitting = false;

  // Logistics & Volunteer Fleet Setup
  bool _hasOwnVolunteers = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _signInExisting() {
    final query = _signInQueryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _signInError =
            'Please enter your registered phone number or registration number.';
      });
      return;
    }

    setState(() {
      _isCheckingAccount = true;
      _signInError = null;
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final existingNgo = widget.repository.findNGOByPhoneOrReg(query);

      setState(() => _isCheckingAccount = false);

      if (existingNgo != null) {
        if (existingNgo.isVerified) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome back, ${existingNgo.organizationName}! Verification active.',
              ),
              backgroundColor: AppTheme.forestGreen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Account found for ${existingNgo.organizationName}. Awaiting Admin Review.',
              ),
              backgroundColor: const Color(0xFFD97706),
            ),
          );
        }

        if (widget.onExistingSignedIn != null) {
          widget.onExistingSignedIn!(existingNgo);
        } else {
          widget.onRegistered(existingNgo);
        }
      } else {
        setState(() {
          _signInError =
              'No account found matching "$query". Please check your credentials or switch to the Register tab to create an account.';
        });
      }
    });
  }

  String _generateUuid() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (i) => rand.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10, 16).join()}';
  }

  Future<void> _pickAndUploadDocument({
    required bool isGovtId,
    required ImageSource source,
  }) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 90);

      if (picked == null) return;

      setState(() {
        if (isGovtId) {
          _isUploadingGovtDoc = true;
        } else {
          _isUploadingFssaiDoc = true;
        }
      });

      final bytes = await picked.readAsBytes();
      final rawName = picked.name;
      final sizeKb = (bytes.lengthInBytes / 1024).round();
      final sizeStr = sizeKb > 1024
          ? '${(sizeKb / 1024).toStringAsFixed(1)} MB'
          : '$sizeKb KB';

      // Upload directly to public Supabase bucket 'ngo-documents'
      final safeName =
          '${isGovtId ? "govt_id" : "fssai"}_${DateTime.now().millisecondsSinceEpoch}_$rawName';
      final uploadedUrl = await widget.repository.uploadImage(
        bytes,
        safeName,
        bucket: 'ngo-documents',
      );

      if (mounted) {
        setState(() {
          if (isGovtId) {
            _govtDocBytes = bytes;
            _govtDocUrl = uploadedUrl;
            _govtDocFileName = rawName;
            _govtDocFileSize = sizeStr;
            _govtDocAttached = true;
            _isUploadingGovtDoc = false;
          } else {
            _fssaiDocBytes = bytes;
            _fssaiDocUrl = uploadedUrl;
            _fssaiDocFileName = rawName;
            _fssaiDocFileSize = sizeStr;
            _fssaiDocAttached = true;
            _isUploadingFssaiDoc = false;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Document uploaded: $rawName ($sizeStr)',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.forestGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (isGovtId) {
            _isUploadingGovtDoc = false;
          } else {
            _isUploadingFssaiDoc = false;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  void _openDocumentPickerModal({required bool isGovtId}) {
    final title = isGovtId
        ? 'Upload Real $_govtIdType Document'
        : 'Upload Real Food Safety / FSSAI License';
    final subtitle = isGovtId
        ? 'Upload your official Aadhaar / PAN card photo or scan'
        : 'Upload your official FSSAI / Food Safety certificate';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.cloud_upload_rounded,
                      color: AppTheme.forestGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Option 1: Device File / Gallery
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadDocument(
                    isGovtId: isGovtId,
                    source: ImageSource.gallery,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.folder_open_rounded,
                          color: AppTheme.forestGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose Document from Device Files',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Select real document scan, PDF, or image file',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.forestGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Option 2: Camera Capture
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadDocument(
                    isGovtId: isGovtId,
                    source: ImageSource.camera,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppTheme.forestGreen,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Take Photo of Document with Camera',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.richCharcoal,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Snap a clear physical photo of the card or certificate',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: AppTheme.forestGreen,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: AppTheme.forestGreen,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your identity documents are securely encrypted in the dedicated Supabase vault and only reviewed for official NGO verification.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final phoneInput = _phoneController.text.trim();
    final regNumInput = _regNumController.text.trim();

    // Check if account already exists
    final existingNgo =
        widget.repository.findNGOByPhoneOrReg(phoneInput) ??
        widget.repository.findNGOByPhoneOrReg(regNumInput);

    if (existingNgo != null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.account_circle_rounded,
                color: AppTheme.forestGreen,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Account Already Exists'),
            ],
          ),
          content: Text(
            'An organization account is already registered with this phone number or registration ID (${existingNgo.organizationName}).\n\nYou do not need to register again! Would you like to sign in directly to check your verification status or access the portal?',
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Review Form'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (widget.onExistingSignedIn != null) {
                  widget.onExistingSignedIn!(existingNgo);
                } else {
                  widget.onRegistered(existingNgo);
                }
              },
              child: const Text('Sign In Directly'),
            ),
          ],
        ),
      );
      return;
    }

    if (!_govtDocAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compulsory requirement: Please upload your Government Identity document.',
          ),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    if (!_fssaiDocAttached) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Compulsory requirement: Please upload your Food Safety / FSSAI license document.',
          ),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ngo = NGOModel(
      id: _generateUuid(),
      organizationName: _orgNameController.text.trim(),
      registrationNumber: _regNumController.text.trim(),
      contactPerson: _contactPersonController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      latitude: 12.9750,
      longitude: 77.6250,
      verificationStatus: NGOVerificationStatus.pending,
      capacityMealsPerDay: int.tryParse(_capacityController.text.trim()) ?? 250,
      foodSafetyCertId: _certIdController.text.trim(),
      govtIdType: _govtIdType,
      govtIdNumber: _govtIdNumberController.text.trim(),
      govtDocFileName: _govtDocFileName,
      fssaiDocFileName: _fssaiDocFileName,
      docFileSize: _fssaiDocFileSize.isNotEmpty
          ? _fssaiDocFileSize
          : _govtDocFileSize,
      verificationDocumentUrl: _fssaiDocUrl ?? _govtDocUrl ?? '',
      hasOwnVolunteers: _hasOwnVolunteers,
      createdAt: DateTime.now(),
    );

    final saved = await widget.repository.registerNGO(ngo);

    if (mounted) {
      setState(() => _isSubmitting = false);
      widget.onRegistered(saved);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInQueryController.dispose();
    _orgNameController.dispose();
    _regNumController.dispose();
    _contactPersonController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _capacityController.dispose();
    _certIdController.dispose();
    _govtIdNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('NGO Portal Access & Verification'),
        leading: widget.onBackToRoles != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                tooltip: 'Back to Role Selection',
                onPressed: widget.onBackToRoles,
              )
            : null,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.forestGreen,
          unselectedLabelColor: AppTheme.charcoalMuted,
          indicatorColor: AppTheme.forestGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.login_rounded, size: 20),
              text: 'Sign In (Existing NGO)',
            ),
            Tab(
              icon: Icon(Icons.app_registration_rounded, size: 20),
              text: 'Register New NGO',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_buildSignInTab(), _buildRegisterTab()],
        ),
      ),
    );
  }

  Widget _buildDocumentUploadCard({required bool isGovtId}) {
    final bytes = isGovtId ? _govtDocBytes : _fssaiDocBytes;
    final isAttached = isGovtId ? _govtDocAttached : _fssaiDocAttached;
    final isUploading = isGovtId ? _isUploadingGovtDoc : _isUploadingFssaiDoc;
    final fileName = isGovtId ? _govtDocFileName : _fssaiDocFileName;
    final fileSize = isGovtId ? _govtDocFileSize : _fssaiDocFileSize;
    final title = isGovtId
        ? 'Official $_govtIdType Proof'
        : 'Official FSSAI Food Safety Certificate';
    final subtitle = isGovtId
        ? 'Upload official Aadhaar or PAN document proof'
        : 'Upload state food safety authority certificate';

    if (isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.warmIvoryDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.emerald),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppTheme.forestGreen,
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                'Uploading document to Supabase secure compliance vault...',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.forestGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isAttached) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.emeraldLight.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.emerald, width: 1.5),
        ),
        child: Column(
          children: [
            Row(
              children: [
                if (bytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      bytes,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.forestGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.verified_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Vault Upload Verified • $fileSize',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ATTACHED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 16,
                    color: AppTheme.statusCritical,
                  ),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.statusCritical,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      if (isGovtId) {
                        _govtDocAttached = false;
                        _govtDocBytes = null;
                        _govtDocUrl = null;
                        _govtDocFileName = '';
                        _govtDocFileSize = '';
                      } else {
                        _fssaiDocAttached = false;
                        _fssaiDocBytes = null;
                        _fssaiDocUrl = null;
                        _fssaiDocFileName = '';
                        _fssaiDocFileSize = '';
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.change_circle_rounded, size: 16),
                  label: const Text(
                    'Change File',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  onPressed: () => _openDocumentPickerModal(isGovtId: isGovtId),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.warmIvoryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.cloud_upload_rounded,
              color: AppTheme.forestGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.upload_rounded, size: 16),
            label: const Text(
              'Upload',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            onPressed: () => _openDocumentPickerModal(isGovtId: isGovtId),
          ),
        ],
      ),
    );
  }

  // TAB 1: Existing NGO Sign-In (No Re-Registration Required)
  Widget _buildSignInTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.emeraldLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.volunteer_activism_rounded,
              size: 28,
              color: AppTheme.forestGreen,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Sign In to Your NGO Account',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: AppTheme.richCharcoal,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'If your organization has already registered, enter your official phone number or 80G registration ID below. You do not need to register again.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppTheme.charcoalMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Official Phone Number or 80G Registration ID',
                  hint: 'e.g. +91 9XXXXXXXXX or NGO-KA-2024-XXXX',
                  controller: _signInQueryController,
                  prefixIcon: Icons.badge_rounded,
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warmIvoryDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 20,
                        color: AppTheme.forestGreen,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Your credentials are kept strictly private. Enter your registered mobile number or registration ID to access your account.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.charcoalMuted,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_signInError != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.statusCritical),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.statusCritical,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _signInError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.statusCritical,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                AppButton(
                  label: 'Sign In & Verify Access',
                  icon: Icons.arrow_forward_rounded,
                  isLoading: _isCheckingAccount,
                  onPressed: _signInExisting,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: TextButton.icon(
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text(
                'New to FoodBridge? Register Organization here',
              ),
              onPressed: () {
                _tabController.animateTo(1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 2: Clean New Registration (No Pre-filled Data from other users)
  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Register Your Food Rescue Organization',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: AppTheme.richCharcoal,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please complete all fields below and attach your verified government identity and food safety credentials for administrator review.',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.charcoalMuted,
                height: 1.4,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.emeraldLight.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.emerald),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: AppTheme.forestGreen,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Already registered? You do not need to register again.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: const Size(50, 30),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _tabController.animateTo(0),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.forestGreen,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Organization Details',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Organization / Foundation Name',
                    hint: 'e.g. Community Food Relief Trust',
                    controller: _orgNameController,
                    prefixIcon: Icons.business_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Government Registration Number (80G / 12A)',
                    hint: 'e.g. NGO-2024-XXXX',
                    controller: _regNumController,
                    prefixIcon: Icons.verified_user_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Authorized Contact Person',
                          hint: 'Lead coordinator full name',
                          controller: _contactPersonController,
                          prefixIcon: Icons.person_rounded,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'Official Phone',
                          hint: '+91 9XXXXXXXXX',
                          controller: _phoneController,
                          prefixIcon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppTextField(
                    label: 'Kitchen Facility Address & City',
                    hint: 'Full physical delivery / pickup location',
                    controller: _addressController,
                    prefixIcon: Icons.location_on_rounded,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required field' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: 'Daily Meal Capacity',
                          hint: 'e.g. 250',
                          controller: _capacityController,
                          prefixIcon: Icons.soup_kitchen_rounded,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppTextField(
                          label: 'FSSAI License / Safety Cert ID',
                          hint: 'e.g. FSSAI-2024-XXXX',
                          controller: _certIdController,
                          prefixIcon: Icons.health_and_safety_rounded,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Required license ID'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 14),

                  // LOGISTICS & VOLUNTEER FLEET SETUP
                  Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining_rounded,
                        color: AppTheme.forestGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          '2. Food Pickup & Volunteer Logistics (डिलिव्हरी सोय)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Does your NGO have its own volunteers/vehicles for food pickups from donors?\n(तुमच्या संस्थेकडे स्वतःचे स्वयंसेवक / वाहन आहे का?)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.richCharcoal,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option YES: Own Volunteers
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _hasOwnVolunteers = true),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _hasOwnVolunteers
                            ? AppTheme.emeraldLight.withValues(alpha: 0.4)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _hasOwnVolunteers
                              ? AppTheme.forestGreen
                              : AppTheme.borderColor,
                          width: _hasOwnVolunteers ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _hasOwnVolunteers
                                      ? AppTheme.forestGreen
                                      : AppTheme.charcoalMuted.withValues(
                                          alpha: 0.6,
                                        ),
                                  width: 2,
                                ),
                              ),
                              child: _hasOwnVolunteers
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppTheme.forestGreen,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'YES — We have our own volunteer fleet',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.richCharcoal,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '₹0 FEE',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF059669),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'आमचे स्वतःचे स्वयंसेवक आहेत. Our volunteers will pick up donations directly from donors. No delivery fee charged.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.charcoalMuted,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Option NO: FoodBridge Volunteers Needed
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _hasOwnVolunteers = false),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: !_hasOwnVolunteers
                            ? const Color(0xFFFFF7ED)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_hasOwnVolunteers
                              ? const Color(0xFFEA580C)
                              : AppTheme.borderColor,
                          width: !_hasOwnVolunteers ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: !_hasOwnVolunteers
                                      ? const Color(0xFFEA580C)
                                      : AppTheme.charcoalMuted.withValues(
                                          alpha: 0.6,
                                        ),
                                  width: 2,
                                ),
                              ),
                              child: !_hasOwnVolunteers
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFEA580C),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'NO — Provide FoodBridge Volunteers',
                                      style: TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.richCharcoal,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFEDD5),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '₹20 - ₹30 / TRIP',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFFC2410C),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'आमच्याकडे स्वयंसेवक नाहीत. FoodBridge community couriers will deliver food from donor to your shelter. A nominal delivery fee of ₹20 – ₹30 (based on distance) applies to support riders.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.charcoalMuted,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 14),

                  // COMPULSORY GOVERNMENT IDENTITY SECTION
                  Row(
                    children: [
                      const Icon(
                        Icons.badge_rounded,
                        color: AppTheme.forestGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '3. Compulsory Government Identity',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.statusCritical.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'MANDATORY',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.statusCritical,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Upload government-issued identity proof of authorized trustee or organization.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.charcoalMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: const Text('Aadhaar Card (UIDAI)'),
                        selected: _govtIdType == 'Aadhaar Card',
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _govtIdType = 'Aadhaar Card');
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text('PAN Card (Income Tax)'),
                        selected: _govtIdType == 'PAN Card',
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _govtIdType = 'PAN Card');
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: '$_govtIdType Number (Mandatory)',
                    hint: _govtIdType == 'Aadhaar Card'
                        ? 'Enter 12-digit Aadhaar number'
                        : 'Enter 10-character PAN number',
                    controller: _govtIdNumberController,
                    prefixIcon: Icons.credit_card_rounded,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Compulsory government ID number required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Government Identity Real Document Upload Box
                  _buildDocumentUploadCard(isGovtId: true),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 14),

                  // FOOD SAFETY COMPLIANCE SECTION
                  Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety_rounded,
                        color: AppTheme.forestGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '4. Food Safety / FSSAI License Document',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // FSSAI Real Document Upload Box
                  _buildDocumentUploadCard(isGovtId: false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Submit for Compliance Verification',
              isLoading: _isSubmitting,
              icon: Icons.assignment_turned_in_rounded,
              onPressed: _submit,
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.login_rounded, size: 18),
                label: const Text(
                  'Already registered? Sign In to your account',
                ),
                onPressed: () {
                  _tabController.animateTo(0);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
