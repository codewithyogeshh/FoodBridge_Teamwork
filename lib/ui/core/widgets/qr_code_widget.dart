import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class QRCodeWidget extends StatelessWidget {
  final String otpCode;
  final String donationTitle;
  final double size;

  const QRCodeWidget({
    super.key,
    required this.otpCode,
    required this.donationTitle,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.borderColor, width: 1.5),
            boxShadow: AppTheme.subtleShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size - 32, size - 32),
                painter: _QRPainter(code: otpCode),
              ),
              // Center FoodBridge Leaf Emblem
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.forestGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppTheme.limeLight,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.warmIvoryDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pickup OTP: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.charcoalMuted,
                ),
              ),
              Text(
                otpCode,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppTheme.forestGreen,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: otpCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP code copied to clipboard'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.copy_rounded,
                  size: 16,
                  color: AppTheme.forestGreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QRPainter extends CustomPainter {
  final String code;

  _QRPainter({required this.code});

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()
      ..color = AppTheme.richCharcoal
      ..style = PaintingStyle.fill;

    final double step = size.width / 15.0;

    // Corner Finder Patterns (Top-Left, Top-Right, Bottom-Left)
    _drawFinder(canvas, 0, 0, step, darkPaint);
    _drawFinder(canvas, size.width - 5 * step, 0, step, darkPaint);
    _drawFinder(canvas, 0, size.height - 5 * step, step, darkPaint);

    // Pseudorandom static data matrix dots seeded by code
    final seed = code.hashCode;
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        // Skip corner finder areas
        if ((r < 5 && c < 5) ||
            (r < 5 && c >= 10) ||
            (r >= 10 && c < 5)) {
          continue;
        }
        // Skip center logo
        if (r >= 5 && r <= 9 && c >= 5 && c <= 9) {
          continue;
        }

        final val = ((r * 17 + c * 31 + seed) % 7);
        if (val < 4) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * step + 1.5, r * step + 1.5, step - 3, step - 3),
              const Radius.circular(2),
            ),
            darkPaint,
          );
        }
      }
    }
  }

  void _drawFinder(Canvas canvas, double x, double y, double step, Paint paint) {
    // Outer 5x5 box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, 5 * step, 5 * step),
        const Radius.circular(6),
      ),
      paint,
    );
    // Inner 3x3 white cut
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + step, y + step, 3 * step, 3 * step),
        const Radius.circular(4),
      ),
      whitePaint,
    );
    // Center 1x1 dot
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1.7 * step, y + 1.7 * step, 1.6 * step, 1.6 * step),
        const Radius.circular(2),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _QRPainter oldDelegate) =>
      oldDelegate.code != code;
}
