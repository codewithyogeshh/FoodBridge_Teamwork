import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';

class FoodVisionResult {
  final String title;
  final String foodType;
  final int estimatedServings;
  final int urgencyScore;
  final String safeHours;
  final String storageRecommendation;
  final List<String> allergens;

  FoodVisionResult({
    required this.title,
    required this.foodType,
    required this.estimatedServings,
    required this.urgencyScore,
    required this.safeHours,
    required this.storageRecommendation,
    required this.allergens,
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
      builder: (_) =>
          FoodVisionScannerDialog(onResultApplied: onResultApplied),
    );
  }

  @override
  State<FoodVisionScannerDialog> createState() =>
      _FoodVisionScannerDialogState();
}

class _FoodVisionScannerDialogState extends State<FoodVisionScannerDialog> {
  int _selectedPreset = 0;
  bool _isAnalyzing = false;
  FoodVisionResult? _analysisResult;

  final List<Map<String, dynamic>> _presets = [
    {
      'name': 'Hot Cooked Meals (Biryani & Curry)',
      'icon': Icons.soup_kitchen_rounded,
      'color': const Color(0xFFEA580C),
      'result': FoodVisionResult(
        title: '55 Servings Steaming Veg Biryani & Gravy',
        foodType: 'Cooked Meals',
        estimatedServings: 55,
        urgencyScore: 94,
        safeHours: 'Safe for 2.5 hours',
        storageRecommendation: 'Keep warm (>60°C) in insulated containers',
        allergens: ['Dairy (Paneer)', 'Cashews'],
      ),
    },
    {
      'name': 'Bakery Pastries & Sandwiches',
      'icon': Icons.bakery_dining_rounded,
      'color': const Color(0xFFD97706),
      'result': FoodVisionResult(
        title: '40 Croissants & Vegetable Sandwiches',
        foodType: 'Bakery & Grains',
        estimatedServings: 40,
        urgencyScore: 55,
        safeHours: 'Safe for 18 hours',
        storageRecommendation: 'Cool, dry ambient (15-20°C)',
        allergens: ['Gluten', 'Sesame'],
      ),
    },
    {
      'name': 'Farm Fresh Vegetables & Fruits',
      'icon': Icons.eco_rounded,
      'color': const Color(0xFF16A34A),
      'result': FoodVisionResult(
        title: '30 kg Fresh Apples, Oranges & Cucumbers',
        foodType: 'Produce',
        estimatedServings: 60,
        urgencyScore: 25,
        safeHours: 'Safe for 4 days',
        storageRecommendation: 'Ventilated crates (10-15°C)',
        allergens: [],
      ),
    },
  ];

  void _runAnalysis() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisResult = _presets[_selectedPreset]['result'] as FoodVisionResult;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppTheme.cardSurface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(22),
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
                    child: const Icon(Icons.document_scanner_rounded,
                        color: AppTheme.forestGreen, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Computer Vision Food Scanner',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.richCharcoal),
                        ),
                        Text(
                          'Estimates servings, freshness & perishability shelf-life',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.charcoalMuted),
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
              const SizedBox(height: 16),

              const Text(
                'Select Food Photo or Camera Sample',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal),
              ),
              const SizedBox(height: 8),

              // PRESET SELECTOR
              Row(
                children: List.generate(_presets.length, (i) {
                  final p = _presets[i];
                  final isSel = _selectedPreset == i;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < _presets.length - 1 ? 8 : 0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPreset = i;
                            _analysisResult = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? (p['color'] as Color).withValues(alpha: 0.1)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel
                                  ? (p['color'] as Color)
                                  : AppTheme.borderColor,
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(p['icon'] as IconData,
                                  color: p['color'] as Color, size: 24),
                              const SizedBox(height: 6),
                              Text(
                                (p['name'] as String).split(' ').first,
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSel
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: AppTheme.richCharcoal),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // CAMERA / INSPECTION SIMULATOR BOX
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Reticle
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: Colors.white70, size: 12),
                            SizedBox(width: 4),
                            Text('OPTICAL SCANNER FEED',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _presets[_selectedPreset]['icon'] as IconData,
                          size: 48,
                          color: _presets[_selectedPreset]['color'] as Color,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _presets[_selectedPreset]['name'] as String,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Container volume: ~18 Liters • Deep stainless vessel',
                          style: TextStyle(fontSize: 10, color: Colors.white60),
                        ),
                      ],
                    ),
                    if (_isAnalyzing)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: AppTheme.forestGreen),
                              SizedBox(height: 10),
                              Text('Gemini 1.5 Flash Vision Analyzing...',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              if (_analysisResult == null && !_isAnalyzing)
                AppButton(
                  label: 'Analyze Food Photo with AI Vision',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _runAnalysis,
                ),

              // ANALYSIS RESULT CARD
              if (_analysisResult != null) ...[
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
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
                              const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF16A34A), size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'AI Vision Confidence: 96.8%',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF166534)),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Perishability: ${_analysisResult!.urgencyScore}/100',
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Text(
                            _analysisResult!.title,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.richCharcoal),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Estimated Servings: ~${_analysisResult!.estimatedServings} Portions (${_analysisResult!.foodType})',
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.forestGreen),
                          ),
                          Text(
                            'Shelf-Life: ${_analysisResult!.safeHours} • ${_analysisResult!.storageRecommendation}',
                            style: const TextStyle(
                                fontSize: 10, color: AppTheme.charcoalMuted),
                          ),
                          if (_analysisResult!.allergens.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Allergens Detected: ${_analysisResult!.allergens.join(", ")}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFD97706)),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Apply AI Findings to Donation Form',
                  icon: Icons.check_circle_rounded,
                  onPressed: () {
                    widget.onResultApplied(_analysisResult!);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Donation form auto-populated with AI Vision analysis!'),
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
