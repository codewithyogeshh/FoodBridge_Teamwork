import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'ai_urgency_screen.dart';

class CreateDonationScreen extends StatefulWidget {
  final AppRepository repository;
  final void Function(DonationModel created) onDonationCreated;

  const CreateDonationScreen({
    super.key,
    required this.repository,
    required this.onDonationCreated,
  });

  @override
  State<CreateDonationScreen> createState() => _CreateDonationScreenState();
}

class _CreateDonationScreenState extends State<CreateDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _quantityController = TextEditingController();
  final _servingsController = TextEditingController();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedFoodType = 'Cooked Meals';
  String _selectedStorage = 'Hot Insulated (> 60°C)';
  final List<String> _selectedAllergens = [];
  int _safeHours = 3;
  bool _isAnalyzing = false;

  // ImagePicker state for surplus food donation
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _presetImageUrl;

  Future<void> _pickFoodImage(ImageSource source) async {
    try {
      final XFile? file = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageName = file.name;
          _presetImageUrl = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking food image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/gallery: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  void _selectPresetPhoto(String url, String name) {
    setState(() {
      _presetImageUrl = url;
      _selectedImageBytes = null;
      _selectedImageName = name;
    });
  }

  String _generateOtp() {
    final rand = Random();
    return (1000 + rand.nextInt(9000)).toString();
  }

  String _generateUuid() {
    final rand = Random.secure();
    final values = List<int>.generate(16, (i) => rand.nextInt(256));
    values[6] = (values[6] & 0x0f) | 0x40; // Version 4
    values[8] = (values[8] & 0x3f) | 0x80; // Variant 10xx
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10, 16).join()}';
  }

  void _proceedToAI() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAnalyzing = true);

    String? uploadedImageUrl = _presetImageUrl;
    if (_selectedImageBytes != null) {
      try {
        final safeName = _selectedImageName ??
            'donation_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final uploaded = await widget.repository.uploadImage(
          _selectedImageBytes!,
          safeName,
        );
        if (uploaded != null) {
          uploadedImageUrl = uploaded;
        }
      } catch (e) {
        debugPrint('Image upload notice: $e');
      }
    }

    final now = DateTime.now();
    final safeUntil = now.add(Duration(hours: _safeHours));
    final otp = _generateOtp();

    final donation = DonationModel(
      id: _generateUuid(),
      donorName: widget.repository.currentUser.fullName,
      donorPhone: widget.repository.currentUser.phone,
      title: _titleController.text.trim(),
      foodType: _selectedFoodType,
      quantityLabel: _quantityController.text.trim(),
      quantityServings: int.tryParse(_servingsController.text.trim()) ?? 50,
      preparedAt: now.subtract(const Duration(minutes: 30)),
      safeUntil: safeUntil,
      storageRequirements: _selectedStorage,
      allergens: _selectedAllergens,
      pickupAddress: _addressController.text.trim(),
      pickupLatitude: 12.9716,
      pickupLongitude: 77.5946,
      pickupInstructions: _instructionsController.text.trim(),
      pickupOtp: otp,
      imageUrl: uploadedImageUrl ??
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
      urgencyLevel: _selectedFoodType == 'Cooked Meals'
          ? UrgencyLevel.critical
          : UrgencyLevel.high,
      aiUrgencyScore: 92,
      aiRecommendationSummary: 'Evaluating candidate NGOs...',
      status: DonationStatus.available,
      createdAt: now,
      updatedAt: now,
    );

    // Save to repository & Supabase
    final created = await widget.repository.createDonation(donation);

    if (mounted) {
      setState(() => _isAnalyzing = false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AIUrgencyScreen(
            donation: created,
            repository: widget.repository,
            onConfirmed: () {
              widget.onDonationCreated(created);
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _quantityController.dispose();
    _servingsController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Post Surplus Food'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Food Batch & Handling Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Provide precise preparation and thermal info. FoodBridge AI calculates safe transit thresholds and matches verified receivers.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.charcoalMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Photo Upload Section (ImagePicker)
                      const Text(
                        'Food Photo (Recommended)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_selectedImageBytes != null || _presetImageUrl != null)
                        Container(
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: _selectedImageBytes != null
                                    ? Image.memory(
                                        _selectedImageBytes!,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        _presetImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: AppTheme.emeraldLight,
                                          child: const Center(
                                            child: Icon(Icons.fastfood_rounded,
                                                color: AppTheme.forestGreen,
                                                size: 40),
                                          ),
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.75),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded,
                                          color: AppTheme.emerald, size: 14),
                                      const SizedBox(width: 5),
                                      Text(
                                        _selectedImageName ?? 'Photo Ready for Upload',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: InkWell(
                                  onTap: () => setState(() {
                                    _selectedImageBytes = null;
                                    _selectedImageName = null;
                                    _presetImageUrl = null;
                                  }),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4)
                                      ],
                                    ),
                                    child: const Icon(Icons.close_rounded,
                                        size: 16,
                                        color: AppTheme.statusCritical),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickFoodImage(ImageSource.gallery),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                                    foregroundColor: AppTheme.richCharcoal,
                                    side: const BorderSide(color: AppTheme.borderColor),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                  ),
                                  icon: const Icon(Icons.refresh_rounded, size: 14),
                                  label: const Text('Change Photo',
                                      style: TextStyle(
                                          fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppTheme.emeraldLight,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_a_photo_rounded,
                                    color: AppTheme.forestGreen, size: 26),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Upload photo of food batch',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Shows packaging quality, seals, and portion volume for verified NGOs',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.charcoalMuted,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickFoodImage(ImageSource.camera),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.forestGreen,
                                      side: const BorderSide(
                                          color: AppTheme.forestGreen),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                    ),
                                    icon: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16),
                                    label: const Text('Camera',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 10),
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _pickFoodImage(ImageSource.gallery),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF2563EB),
                                      side: const BorderSide(
                                          color: Color(0xFF2563EB)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                    ),
                                    icon: const Icon(
                                        Icons.photo_library_outlined,
                                        size: 16),
                                    label: const Text('Gallery / Files',
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                '— OR SELECT SAMPLE PHOTO —',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: AppTheme.charcoalLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                alignment: WrapAlignment.center,
                                children: [
                                  ActionChip(
                                    avatar: const Text('🍛'),
                                    label: const Text('Fresh Biryani',
                                        style: TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: AppTheme.borderColor),
                                    onPressed: () => _selectPresetPhoto(
                                      'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
                                      'Fresh Biryani & Curry',
                                    ),
                                  ),
                                  ActionChip(
                                    avatar: const Text('🥐'),
                                    label: const Text('Fresh Bakery',
                                        style: TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: AppTheme.borderColor),
                                    onPressed: () => _selectPresetPhoto(
                                      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop',
                                      'Fresh Bakery & Bread',
                                    ),
                                  ),
                                  ActionChip(
                                    avatar: const Text('🍱'),
                                    label: const Text('Meal Trays',
                                        style: TextStyle(fontSize: 11)),
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: AppTheme.borderColor),
                                    onPressed: () => _selectPresetPhoto(
                                      'https://images.unsplash.com/photo-1574484284002-952d92456975?w=800&auto=format&fit=crop',
                                      'Sealed Meal Trays',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Food Batch Title / Description',
                        hint: 'e.g. Wedding Feast Surplus (Biryani, Dal)',
                        controller: _titleController,
                        prefixIcon: Icons.fastfood_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Food Category',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.foodCategories.map((cat) {
                          final isSelected = _selectedFoodType == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppTheme.emeraldLight,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.forestGreen
                                  : AppTheme.richCharcoal,
                              fontWeight:
                                  isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedFoodType = cat);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              label: 'Portions Count',
                              hint: 'e.g. 65',
                              controller: _servingsController,
                              prefixIcon: Icons.people_outline_rounded,
                              keyboardType: TextInputType.number,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              label: 'Weight / Volume Label',
                              hint: 'e.g. 65 meals (~26 kg)',
                              controller: _quantityController,
                              prefixIcon: Icons.scale_rounded,
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Safe Consumption Slider
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Safe Consumption Window',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              Text(
                                '$_safeHours hours from now',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.forestGreen,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: _safeHours.toDouble(),
                            min: 1,
                            max: 36,
                            divisions: 35,
                            activeColor: _safeHours <= 3
                                ? AppTheme.statusCritical
                                : AppTheme.forestGreen,
                            onChanged: (val) {
                              setState(() => _safeHours = val.toInt());
                            },
                          ),
                          if (_safeHours <= 3)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.statusCriticalBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      size: 16, color: AppTheme.statusCritical),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'High perishability batch! AI will trigger critical alerts to ultra-close NGOs.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.statusCritical,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Storage Requirements Dropdown
                      const Text(
                        'Storage & Transport Requirement',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedStorage,
                            isExpanded: true,
                            items: AppConstants.storageOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(opt,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.richCharcoal)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedStorage = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Allergen checklist
                      const Text(
                        'Known Allergens Present',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: AppConstants.commonAllergens.map((allergen) {
                          final isIncluded =
                              _selectedAllergens.contains(allergen);
                          return FilterChip(
                            label: Text(allergen),
                            selected: isIncluded,
                            selectedColor: AppTheme.limeLight,
                            labelStyle: TextStyle(
                              color: isIncluded
                                  ? AppTheme.forestGreen
                                  : AppTheme.charcoalMuted,
                              fontSize: 12,
                              fontWeight:
                                  isIncluded ? FontWeight.w700 : FontWeight.w500,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedAllergens.add(allergen);
                                } else {
                                  _selectedAllergens.remove(allergen);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Pickup Address',
                        hint: 'e.g. 120 Residency Road, Bengaluru',
                        controller: _addressController,
                        prefixIcon: Icons.location_on_rounded,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Specific Pickup Bay / Gate Instructions',
                        hint: 'e.g. Ring service bell at rear kitchen entrance',
                        controller: _instructionsController,
                        prefixIcon: Icons.info_outline_rounded,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Analyze with AI & Find Verified NGOs',
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _isAnalyzing,
                  onPressed: _proceedToAI,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
