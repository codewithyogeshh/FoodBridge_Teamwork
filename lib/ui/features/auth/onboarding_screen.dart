import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;

  const OnboardingScreen({super.key, required this.onFinish});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.restaurant_menu_rounded,
      'title': 'Bridge Surplus Meals to Real Community Impact',
      'description':
          'Commercial banquets, bakeries, and kitchens list surplus food within seconds. Eliminate waste while feeding vulnerable populations.',
      'tag': 'ZERO HUNGER',
    },
    {
      'icon': Icons.auto_awesome_rounded,
      'title': 'Signature AI Intelligent Urgency Routing',
      'description':
          'Our AI engine evaluates food thermal sensitivity, travel corridors, and kitchen capacities to recommend the ideal recipient instantly.',
      'tag': 'SMART ALLOCATION',
    },
    {
      'icon': Icons.qr_code_scanner_rounded,
      'title': 'Cryptographic OTP & Atomic Reservation Locks',
      'description':
          'Guarantee food is reserved by only one verified NGO at a time. Verified handoff via one-time digital passcode and live tracking.',
      'tag': 'CHAIN OF CUSTODY',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.botanicalCanvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: widget.onFinish,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppTheme.charcoalMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stylized Illustration Frame with Ambient Glow
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF064E3B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(32),
                              border: Border.all(
                                color: const Color(0xFF4EDEA3).withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              page['icon'] as IconData,
                              size: 64,
                              color: const Color(0xFFD1E8DD),
                            ),
                          ),
                          const SizedBox(height: 36),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.restrainedLime.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              page['tag'] as String,
                              style: const TextStyle(
                                color: AppTheme.restrainedLime,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page['title'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: AppTheme.richCharcoal,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            page['description'] as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.charcoalMuted,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Pagination Dots & CTA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.restrainedLime
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: _currentPage == index
                              ? [
                                  BoxShadow(
                                    color: AppTheme.restrainedLime.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    label: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Continue',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        widget.onFinish();
                      }
                    },
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
