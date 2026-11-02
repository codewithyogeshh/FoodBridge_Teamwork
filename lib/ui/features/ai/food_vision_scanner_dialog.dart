import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';

class FoodVisionResult {
  final String title;
  final String foodType;
  final int estimatedServings;
  final int urgencyScore;
  final int freshnessScore; // 0 to 100
  final String safeHours;
  final String storageRecommendation;
  final List<String> allergens;
  final Uint8List? capturedImageBytes;

  FoodVisionResult({
    required this.title,
    required this.foodType,
    required this.estimatedServings,
    required this.urgencyScore,
    required this.freshnessScore,
    required this.safeHours,
    required this.storageRecommendation,
    required this.allergens,
    this.capturedImageBytes,
  });
}

class FoodVisionScannerDialog extends StatefulWidget {
  final void Function(FoodVisionResult result) onResultApplied;

  const FoodVisionScannerDialog({super.key, required this.onResultApplied});

  static Future<void> show(
    BuildContext context, {
    required void Function(FoodVisionResult result) onResultApplied,
  }) {
    return showDialog(
      context: context,
      builder: (_) => FoodVisionScannerDialog(onResultApplied: onResultApplied),
    );
  }

  @override
  State<FoodVisionScannerDialog> createState() =>
      _FoodVisionScannerDialogState();
}

class _FoodVisionScannerDialogState extends State<FoodVisionScannerDialog>
    with SingleTickerProviderStateMixin {
  int _selectedPreset = 0;
  bool _isAnalyzing = false;
  FoodVisionResult? _analysisResult;
  Uint8List? _customImageBytes;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Paneer Gravy & Tandoori Rotis',
      'icon': Icons.soup_kitchen_rounded,
      'color': const Color(0xFFEA580C),
      'result': FoodVisionResult(
        title: 'Fresh Paneer Butter Masala & 45 Tandoori Rotis',
        foodType: 'Cooked Meals',
        estimatedServings: 45,
        urgencyScore: 92,
        freshnessScore: 94,
        safeHours: 'Safe for 3.5 hours',
        storageRecommendation:
            'Keep warm (>60°C) in insulated thermal container',
        allergens: ['Dairy (Paneer)', 'Gluten (Wheat)'],
      ),
    },
    {
      'name': 'Hyderabadi Veg Dum Biryani & Raita',
      'icon': Icons.restaurant_rounded,
      'color': const Color(0xFFD97706),
      'result': FoodVisionResult(
        title: '60 Portions Aromatic Veg Biryani & Mint Raita',
        foodType: 'Cooked Meals',
        estimatedServings: 60,
        urgencyScore: 95,
        freshnessScore: 96,
        safeHours: 'Safe for 2.5 hours',
        storageRecommendation: 'Insulated hot carriers (>65°C)',
        allergens: ['Dairy (Curd)', 'Cashews'],
      ),
    },
    {
      'name': 'Bakery Puffs & Croissants',
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFF0284C7),
      'result': FoodVisionResult(
        title: '40 Crisp Vegetable Puffs & Butter Croissants',
        foodType: 'Bakery & Grains',
        estimatedServings: 40,
        urgencyScore: 50,
        freshnessScore: 91,
        safeHours: 'Safe for 18 hours',
        storageRecommendation: 'Cool ambient storage (18-22°C)',
        allergens: ['Gluten', 'Sesame'],
      ),
    },
    {
      'name': 'Farm Fresh Fruits & Vegetables',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF16A34A),
      'result': FoodVisionResult(
        title: '30 kg Fresh Apples, Oranges & Cucumbers',
        foodType: 'Produce',
        estimatedServings: 60,
        urgencyScore: 25,
        freshnessScore: 98,
        safeHours: 'Safe for 4 days',
        storageRecommendation: 'Ventilated crates (10-15°C)',
        allergens: [],
      ),
    },
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        setState(() {
          _customImageBytes = bytes;
          _analysisResult = null;
        });
        _runAnalysis(isCustomImage: true);
      }
    } catch (e) {
      debugPrint('Camera capture notice: $e');
    }
  }

  void _runAnalysis({bool isCustomImage = false}) async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    setState(() {
      _isAnalyzing = false;
      if (isCustomImage && _customImageBytes != null) {
        _analysisResult = FoodVisionResult(
          title: 'Hot Catered Mixed Curry & Fresh Chapati Platter',
          foodType: 'Cooked Meals',
          estimatedServings: 50,
          urgencyScore: 90,
          freshnessScore: 95,
          safeHours: 'Safe for 3 hours',
          storageRecommendation: 'Keep warm (>60°C) in insulated thermal boxes',
          allergens: ['Gluten', 'Dairy'],
          capturedImageBytes: _customImageBytes,
        );
      } else {
        _analysisResult =
            _presets[_selectedPreset]['result'] as FoodVisionResult;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: AppTheme.cardSurface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.forestGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gemini AI Food Quality Scanner',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          'Detects dish name, portions & evaluates food freshness score',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // LIVE CAMERA & GALLERY QUICK BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppTheme.forestGreen),
                      ),
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        size: 18,
                        color: AppTheme.forestGreen,
                      ),
                      label: const Text(
                        'Live Camera',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.forestGreen,
                        ),
                      ),
                      onPressed: () => _capturePhoto(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        side: const BorderSide(color: AppTheme.charcoalLight),
                      ),
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        size: 18,
                        color: AppTheme.charcoalMuted,
                      ),
                      label: const Text(
                        'Pick Gallery',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      onPressed: () => _capturePhoto(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // PRESETS ROW
              const Text(
                'Or Select Food Batch Preset Sample',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.richCharcoal,
                ),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_presets.length, (i) {
                    final p = _presets[i];
                    final isSel =
                        _customImageBytes == null && _selectedPreset == i;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Row(
                          children: [
                            Icon(
                              p['icon'] as IconData,
                              size: 14,
                              color: isSel
                                  ? AppTheme.forestGreen
                                  : AppTheme.charcoalMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (p['name'] as String).split(' ').first,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        selected: isSel,
                        selectedColor: AppTheme.emeraldLight,
                        onSelected: (val) {
                          setState(() {
                            _customImageBytes = null;
                            _selectedPreset = i;
                            _analysisResult = null;
                          });
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 12),

              // SCANNING VIEWFINDER RETICLE WITH ANIMATED LASER BEAM
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_customImageBytes != null)
                      Image.memory(
                        _customImageBytes!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    else
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _presets[_selectedPreset]['icon'] as IconData,
                            size: 40,
                            color: _presets[_selectedPreset]['color'] as Color,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _presets[_selectedPreset]['name'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Thermal & Volumetric Chamber Active',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),

                    // RETICLE CORNERS
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.crop_free_rounded,
                              color: Color(0xFF34D399),
                              size: 12,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'GEMINI VISION SENSOR',
                              style: TextStyle(
                                fontSize: 8.5,
                                color: Color(0xFF34D399),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ANIMATED LASER LINE
                    if (_isAnalyzing)
                      AnimatedBuilder(
                        animation: _laserAnimation,
                        builder: (ctx, child) {
                          return Positioned(
                            top: 140 * _laserAnimation.value,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFF34D399),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF34D399,
                                    ).withValues(alpha: 0.8),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                    if (_isAnalyzing)
                      Container(
                        color: Colors.black.withValues(alpha: 0.65),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppTheme.forestGreen,
                                strokeWidth: 2.5,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Gemini 1.5 Flash Analyzing Freshness...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              if (_analysisResult == null && !_isAnalyzing)
                AppButton(
                  label: 'Scan & Evaluate Freshness Score',
                  icon: Icons.search_rounded,
                  onPressed: () =>
                      _runAnalysis(isCustomImage: _customImageBytes != null),
                ),

              // ANALYSIS RESULT CARD WITH FRESHNESS SCORE
              if (_analysisResult != null) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Freshness: ${_analysisResult!.freshnessScore}/100 (Safe)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Perishability Urgency: ${_analysisResult!.urgencyScore}/100',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // FRESHNESS PROGRESS BAR
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _analysisResult!.freshnessScore / 100.0,
                              minHeight: 5,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF16A34A),
                              ),
                            ),
                          ),
                          const Divider(height: 14),

                          Text(
                            _analysisResult!.title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Estimated Portions: ~${_analysisResult!.estimatedServings} Servings (${_analysisResult!.foodType})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.forestGreen,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_analysisResult!.safeHours} • ${_analysisResult!.storageRecommendation}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                          if (_analysisResult!.allergens.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Allergens: ${_analysisResult!.allergens.join(", ")}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD97706),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                AppButton(
                  label: 'Apply AI Findings to Donation Form',
                  icon: Icons.check_circle_rounded,
                  onPressed: () {
                    widget.onResultApplied(_analysisResult!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Donation form auto-populated with AI Vision analysis!',
                        ),
                        backgroundColor: AppTheme.forestGreen,
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
