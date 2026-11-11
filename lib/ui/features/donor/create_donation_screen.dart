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
import '../ai/food_vision_scanner_dialog.dart';
import 'suggested_ngos_screen.dart';

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

  late final TextEditingController _titleController;
  late final TextEditingController _servingsController;
  late final TextEditingController _addressController;
  late final TextEditingController _instructionsController;

  String _selectedFoodType = 'Cooked Meals';
  String _selectedStorage = 'Hot Insulated (> 60°C)';
  final List<String> _selectedAllergens = [];
  int _safeHours = 4;
  bool _isPosting = false;

  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _presetImageUrl;

  static const List<Map<String, String>> _quickDishes = [
    {
      'label': 'Rice & Dal',
      'type': 'Cooked Meals',
      'storage': 'Hot Insulated (> 60°C)',
    },
    {
      'label': 'Roti & Sabzi',
      'type': 'Cooked Meals',
      'storage': 'Hot Insulated (> 60°C)',
    },
    {
      'label': 'Veg Biryani',
      'type': 'Cooked Meals',
      'storage': 'Hot Insulated (> 60°C)',
    },
    {
      'label': 'Bread & Bakery',
      'type': 'Bakery & Grains',
      'storage': 'Cool & Dry (15-20°C)',
    },
    {
      'label': 'Fruits & Veggies',
      'type': 'Produce & Veggies',
      'storage': 'Cool & Dry (15-20°C)',
    },
  ];

  static const List<int> _platePresets = [15, 30, 50, 100];
  static const List<int> _hourPresets = [2, 4, 8, 24];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _servingsController = TextEditingController(text: '30');
    final orgName = widget.repository.currentUser.organizationName;
    _addressController = TextEditingController(
      text: (orgName != null && orgName.isNotEmpty)
          ? '$orgName, MG Road'
          : 'Grand Orchid Banquet, MG Road',
    );
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _servingsController.dispose();
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String _normalizeFoodType(String raw) {
    if (AppConstants.foodCategories.contains(raw)) return raw;
    if (raw.toLowerCase().contains('produce')) return 'Produce & Veggies';
    if (raw.toLowerCase().contains('bakery')) return 'Bakery & Grains';
    if (raw.toLowerCase().contains('dairy')) return 'Dairy & Beverages';
    if (raw.toLowerCase().contains('fruit')) return 'Fruits & Juices';
    if (raw.toLowerCase().contains('pack')) return 'Packaged Goods';
    return 'Cooked Meals';
  }

  String _mapStorageOption(String raw) {
    if (AppConstants.storageOptions.contains(raw)) return raw;
    final lower = raw.toLowerCase();
    if (lower.contains('warm') ||
        lower.contains('60') ||
        lower.contains('hot')) {
      return 'Hot Insulated (> 60°C)';
    }
    if (lower.contains('cool') ||
        lower.contains('crate') ||
        lower.contains('18-22')) {
      return 'Cool & Dry (15-20°C)';
    }
    if (lower.contains('ambient') || lower.contains('room')) {
      return 'Ambient Room Temp';
    }
    if (lower.contains('froz') || lower.contains('-18')) {
      return 'Frozen (< -18°C)';
    }
    return 'Refrigerated (< 4°C)';
  }

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
          const SnackBar(
            content: Text('Could not open camera or gallery right now.'),
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
    values[6] = (values[6] & 0x0f) | 0x40;
    values[8] = (values[8] & 0x3f) | 0x80;
    final hex = values.map((b) => b.toRadixString(16).padLeft(2, '0')).toList();
    return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-${hex.sublist(10, 16).join()}';
  }

  Future<void> _postFoodNow() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    String? uploadedImageUrl = _presetImageUrl;
    if (_selectedImageBytes != null) {
      try {
        final safeName =
            _selectedImageName ??
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
    final servings = int.tryParse(_servingsController.text.trim()) ?? 30;
    final urgency = _safeHours <= 3
        ? UrgencyLevel.critical
        : _safeHours <= 12
        ? UrgencyLevel.high
        : UrgencyLevel.medium;
    final urgencyScore = _safeHours <= 3
        ? 94
        : _safeHours <= 12
        ? 80
        : 55;

    final donation = DonationModel(
      id: _generateUuid(),
      donorName: widget.repository.currentUser.fullName,
      donorPhone: widget.repository.currentUser.phone,
      title: _titleController.text.trim(),
      foodType: _selectedFoodType,
      quantityLabel: '$servings Plates',
      quantityServings: servings,
      preparedAt: now.subtract(const Duration(minutes: 30)),
      safeUntil: safeUntil,
      storageRequirements: _selectedStorage,
      allergens: List<String>.from(_selectedAllergens),
      pickupAddress: _addressController.text.trim(),
      pickupLatitude: 12.9716,
      pickupLongitude: 77.5946,
      pickupInstructions: _instructionsController.text.trim(),
      pickupOtp: otp,
      imageUrl:
          uploadedImageUrl ??
          'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
      urgencyLevel: urgency,
      aiUrgencyScore: urgencyScore,
      aiRecommendationSummary: 'Shared with nearby NGOs.',
      status: DonationStatus.available,
      createdAt: now,
      updatedAt: now,
    );

    final created = await widget.repository.createDonation(donation);
    if (!mounted) return;

    setState(() => _isPosting = false);
    await _showSuccessDialog(created);
  }

  Future<void> _showSuccessDialog(DonationModel created) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.forestGreen,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Food Posted!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${created.title} (${created.quantityLabel})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Nearby NGOs and helpers can see it now.',
                style: TextStyle(fontSize: 13, color: AppTheme.charcoalMuted),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pickup PIN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    Text(
                      created.pickupOtp,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                final analysis = widget.repository.runAIAllocation(created);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SuggestedNGOsScreen(
                      donation: created,
                      analysis: analysis,
                      onConfirmed: () => widget.onDonationCreated(created),
                    ),
                  ),
                );
              },
              child: const Text('See Best NGOs'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogCtx).pop();
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
                widget.onDonationCreated(created);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeStorageValue =
        AppConstants.storageOptions.contains(_selectedStorage)
        ? _selectedStorage
        : AppConstants.storageOptions.first;

    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(title: const Text('Post Extra Food')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Photo Scan Banner (Optional)
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    FoodVisionScannerDialog.show(
                      context,
                      onResultApplied: (result) {
                        setState(() {
                          _titleController.text = result.title;
                          _servingsController.text = result.estimatedServings
                              .toString();
                          _selectedFoodType = _normalizeFoodType(
                            result.foodType,
                          );
                          _selectedStorage = _mapStorageOption(
                            result.storageRecommendation,
                          );
                          if (result.safeHours.contains('18')) {
                            _safeHours = 8;
                          } else if (result.safeHours.contains('4 days')) {
                            _safeHours = 24;
                          } else {
                            _safeHours = 4;
                          }
                          _selectedAllergens
                            ..clear()
                            ..addAll(result.allergens);
                          if (result.capturedImageBytes != null) {
                            _selectedImageBytes = result.capturedImageBytes;
                            _presetImageUrl = null;
                          }
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F392B), Color(0xFF1E5B45)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF34D399),
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scan Food Photo (Auto-fill)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Optional • Auto-fills dish name & plates',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Quick Dish Presets + Food Name
                      const Text(
                        'Quick Pick',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _quickDishes.map((dish) {
                          final label = dish['label']!;
                          final isSelected =
                              _titleController.text.trim() == label;
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            selectedColor: AppTheme.emeraldLight,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.forestGreen
                                  : AppTheme.richCharcoal,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _titleController.text = label;
                                _selectedFoodType = dish['type']!;
                                _selectedStorage = dish['storage']!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'What food is available?',
                        hint: 'e.g. Rice & Dal, Roti & Sabzi',
                        controller: _titleController,
                        prefixIcon: Icons.fastfood_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter the food name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // 2. How many plates?
                      const Text(
                        'How many plates?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _platePresets.map((count) {
                          final isSelected =
                              _servingsController.text.trim() == '$count';
                          return ChoiceChip(
                            label: Text('$count Plates'),
                            selected: isSelected,
                            selectedColor: AppTheme.emeraldLight,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.forestGreen
                                  : AppTheme.richCharcoal,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _servingsController.text = '$count';
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        label: 'Or enter plate count',
                        hint: '30',
                        controller: _servingsController,
                        prefixIcon: Icons.people_outline_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) {
                            return 'Enter a valid number of plates';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 3. Good for how long?
                      const Text(
                        'Good for how long?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _hourPresets.map((hrs) {
                          final isSelected = _safeHours == hrs;
                          return ChoiceChip(
                            label: Text('$hrs hrs'),
                            selected: isSelected,
                            selectedColor: AppTheme.emeraldLight,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.forestGreen
                                  : AppTheme.richCharcoal,
                            ),
                            onSelected: (_) => setState(() => _safeHours = hrs),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 4. Prefilled Pickup Address
                      AppTextField(
                        label: 'Pickup Address',
                        hint: 'Hotel, banquet, or kitchen address',
                        controller: _addressController,
                        prefixIcon: Icons.location_on_rounded,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Please enter the pickup address'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Collapsed Optional Details
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppTheme.borderColor),
                  ),
                  child: ExpansionTile(
                    title: const Text(
                      'More Details (Optional)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    subtitle: const Text(
                      'Photo, food type, storage, or gate note',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      const SizedBox(height: 8),
                      if (_selectedImageBytes != null ||
                          _presetImageUrl != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 140,
                            width: double.infinity,
                            child: _selectedImageBytes != null
                                ? Image.memory(
                                    _selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _presetImageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: AppTheme.emeraldLight,
                                      child: const Icon(
                                        Icons.fastfood_rounded,
                                        color: AppTheme.forestGreen,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pickFoodImage(ImageSource.camera),
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 16,
                              ),
                              label: const Text('Camera'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () =>
                                  _pickFoodImage(ImageSource.gallery),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 16,
                              ),
                              label: const Text('Gallery'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text(
                              'Sample: Biryani',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () => _selectPresetPhoto(
                              'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800&auto=format&fit=crop',
                              'Biryani Sample',
                            ),
                          ),
                          ActionChip(
                            label: const Text(
                              'Sample: Bakery',
                              style: TextStyle(fontSize: 11),
                            ),
                            onPressed: () => _selectPresetPhoto(
                              'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800&auto=format&fit=crop',
                              'Bakery Sample',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Food Type',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: AppConstants.foodCategories.map((cat) {
                          final isSelected = _selectedFoodType == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            selectedColor: AppTheme.emeraldLight,
                            labelStyle: const TextStyle(fontSize: 11.5),
                            onSelected: (val) {
                              if (val) {
                                setState(() => _selectedFoodType = cat);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'How to Keep Food',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: safeStorageValue,
                            isExpanded: true,
                            items: AppConstants.storageOptions.map((opt) {
                              return DropdownMenuItem(
                                value: opt,
                                child: Text(
                                  opt,
                                  style: const TextStyle(fontSize: 13),
                                ),
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
                      const SizedBox(height: 14),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Allergies (if any)',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: AppConstants.commonAllergens.map((allergen) {
                          final isIncluded = _selectedAllergens.contains(
                            allergen,
                          );
                          return FilterChip(
                            label: Text(allergen),
                            selected: isIncluded,
                            selectedColor: AppTheme.limeLight,
                            labelStyle: const TextStyle(fontSize: 11.5),
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
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Pickup Gate / Note',
                        hint: 'e.g. Ring bell at back kitchen gate',
                        controller: _instructionsController,
                        prefixIcon: Icons.info_outline_rounded,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                AppButton(
                  label: 'Post Food Now',
                  icon: Icons.check_circle_rounded,
                  isLoading: _isPosting,
                  onPressed: _postFoodNow,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
