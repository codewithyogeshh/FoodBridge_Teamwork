import 'package:flutter/material.dart';
import '../theme.dart';

class MapPreviewWidget extends StatefulWidget {
  final double height;
  final String locationTitle;
  final String subtitle;
  final bool showRoute;
  final String? destinationTitle;
  final VoidCallback? onExpand;

  const MapPreviewWidget({
    super.key,
    this.height = 220,
    required this.locationTitle,
    required this.subtitle,
    this.showRoute = false,
    this.destinationTitle,
    this.onExpand,
  });

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDE4),
          border: Border.all(color: AppTheme.borderColor),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Custom Vector Map Canvas
            CustomPaint(
              size: Size(double.infinity, widget.height),
              painter: _CityMapPainter(showRoute: widget.showRoute),
            ),

            // Pulsing Origin Beacon
            Positioned(
              left: 80,
              top: widget.height * 0.45,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 32 + (16 * _pulseController.value),
                        height: 32 + (16 * _pulseController.value),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.forestGreen.withValues(
                            alpha: 0.3 * (1 - _pulseController.value),
                          ),
                        ),
                      ),
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.forestGreen,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Destination Pin (if showing route)
            if (widget.showRoute)
              Positioned(
                right: 70,
                top: widget.height * 0.28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreenDark,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: AppTheme.subtleShadow,
                      ),
                      child: Text(
                        widget.destinationTitle ?? 'NGO Kitchen',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 28,
                      color: AppTheme.emeraldDark,
                    ),
                  ],
                ),
              ),

            // Map Overlay Info Bar
            Positioned(
              left: 12,
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.subtleShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.near_me_rounded,
                        size: 16,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.locationTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.richCharcoal,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppTheme.charcoalMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.onExpand != null)
                      IconButton(
                        icon: const Icon(Icons.fullscreen_rounded, size: 20),
                        color: AppTheme.forestGreen,
                        onPressed: widget.onExpand,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),

            // GPS Live Indicator Pill
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed_rounded, size: 12, color: AppTheme.emerald),
                    SizedBox(width: 5),
                    Text(
                      'Live GPS Ground Grid',
                      style: TextStyle(
                        color: AppTheme.richCharcoal,
                        fontSize: 10,
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
    );
  }
}

class _CityMapPainter extends CustomPainter {
  final bool showRoute;

  _CityMapPainter({required this.showRoute});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFFE5DFC9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFEDE8DA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final greenParkPaint = Paint()
      ..color = const Color(0xFFE4EDE2)
      ..style = PaintingStyle.fill;

    // Draw green parks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.1, 70, 50),
        const Radius.circular(8),
      ),
      greenParkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.65, size.height * 0.5, 90, 60),
        const Radius.circular(10),
      ),
      greenParkPaint,
    );

    // Grid of roads
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.7),
      Offset(size.width, size.height * 0.7),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.3, size.height),
      secondaryRoadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7, 0),
      Offset(size.width * 0.7, size.height),
      roadPaint,
    );

    // Diagonal arterial avenue
    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.5,
        size.width,
        size.height * 0.2,
      );
    canvas.drawPath(path, roadPaint);

    // Draw active transit route polyline if requested
    if (showRoute) {
      final routePaint = Paint()
        ..color = AppTheme.forestGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;

      final routePath = Path()
        ..moveTo(90, size.height * 0.45)
        ..lineTo(size.width * 0.3, size.height * 0.45)
        ..lineTo(size.width * 0.5, size.height * 0.35)
        ..lineTo(size.width - 85, size.height * 0.32);

      canvas.drawPath(routePath, routePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) =>
      oldDelegate.showRoute != showRoute;
}
