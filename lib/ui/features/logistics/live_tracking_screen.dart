import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';

class LiveTrackingScreen extends StatefulWidget {
  final String donationTitle;
  final String pickupAddress;
  final String destinationNgo;

  const LiveTrackingScreen({
    super.key,
    this.donationTitle = '50 Boxed Hot Gourmet Meals',
    this.pickupAddress = 'Grand Orchid Banquet, MG Road',
    this.destinationNgo = 'City Relief Mission & Shelter',
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  double _progress = 0.35; // 0.0 to 1.0 along route
  int _etaMinutes = 14;
  double _distanceKm = 3.2;
  double _speedKmh = 28.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate live vehicle movement
    _timer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (!mounted) return;
      setState(() {
        if (_progress < 0.95) {
          _progress += 0.03;
          _distanceKm = (_distanceKm - 0.2).clamp(0.2, 5.0);
          _etaMinutes = (_distanceKm * 3.5).round().clamp(1, 20);
          _speedKmh = 26.0 + (DateTime.now().second % 8);
        } else {
          _progress = 1.0;
          _etaMinutes = 0;
          _distanceKm = 0.0;
          _speedKmh = 0.0;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F5),
      appBar: AppBar(
        title: const Text('Live Courier GPS Tracking'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF86EFAC)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.satellite_alt_rounded,
                  size: 14,
                  color: Color(0xFF15803D),
                ),
                SizedBox(width: 4),
                Text(
                  'GPS LOCK ACTIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // LIVE RADAR / MAP CANVAS
              Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Grid & Road Background
                      CustomPaint(
                        size: const Size(double.infinity, 240),
                        painter: _MapGridPainter(progress: _progress),
                      ),

                      // Telemetry Overlay Pill
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.speed_rounded,
                                color: Color(0xFF38BDF8),
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${_speedKmh.toStringAsFixed(0)} km/h • ${_distanceKm.toStringAsFixed(1)} km left',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Status Overlay Pill
                      Positioned(
                        top: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.forestGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _progress >= 0.95
                                ? 'ARRIVED AT SHELTER'
                                : 'EN ROUTE TO PICKUP',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Bottom ETA Bar
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'ESTIMATED ARRIVAL',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _etaMinutes > 0
                                        ? '$_etaMinutes Mins'
                                        : 'Arrived Just Now',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 120,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: _progress,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // DRIVER PROFILE CARD
              AppCard(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.forestGreen.withValues(
                            alpha: 0.15,
                          ),
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            size: 32,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 8,
                            backgroundColor: Color(0xFF22C55E),
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Vikram R. (Verified Courier)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.richCharcoal,
                                ),
                              ),
                              SizedBox(width: 6),
                              Icon(
                                Icons.verified_rounded,
                                size: 14,
                                color: Color(0xFF0284C7),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Van: KA-01-EQ-9812 • FoodGrade Insulated',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '⭐ 4.96 (184 food rescues fulfilled)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.forestGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.call_rounded,
                          color: AppTheme.forestGreen,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Dialing Vikram R. (+91 98450 11200) via masked secure proxy...',
                            ),
                            backgroundColor: AppTheme.forestGreen,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // CHAIN OF CUSTODY TIMELINE
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chain-of-Custody Handoff',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTimelineStep(
                      title: 'Surplus Manifest Logged',
                      subtitle: widget.donationTitle,
                      time: '18 mins ago',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Driver Dispatched & Assigned',
                      subtitle: 'Driver accepted via WhatsApp Bot lock',
                      time: '12 mins ago',
                      isDone: true,
                    ),
                    _buildTimelineStep(
                      title: 'Pickup Location',
                      subtitle: widget.pickupAddress,
                      time: _progress >= 0.5 ? 'Completed' : 'Approaching now',
                      isDone: _progress >= 0.5,
                      isCurrent: _progress < 0.5,
                    ),
                    _buildTimelineStep(
                      title: 'Destination Shelter Kitchen',
                      subtitle: widget.destinationNgo,
                      time: 'ETA: $_etaMinutes mins',
                      isDone: _progress >= 1.0,
                      isCurrent: _progress >= 0.5 && _progress < 1.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: AppTheme.borderColor),
                      ),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Live Link'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Live GPS tracking link copied: https://foodbridge.ngo/track/fb-courier-9812',
                            ),
                            backgroundColor: AppTheme.forestGreen,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: 'Emergency SOS',
                      icon: Icons.shield_rounded,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'FoodBridge 24x7 Safety & Logistics Desk alerted!',
                            ),
                            backgroundColor: AppTheme.statusCritical,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isDone,
    bool isCurrent = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppTheme.forestGreen
                  : isCurrent
                  ? const Color(0xFF0284C7)
                  : Colors.grey.shade300,
            ),
            child: Icon(
              isDone ? Icons.check : Icons.circle,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDone || isCurrent
                            ? AppTheme.richCharcoal
                            : AppTheme.charcoalMuted,
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                  ],
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
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  final double progress;

  _MapGridPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw background grid
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Curved Route Line
    final path = Path();
    path.moveTo(30, size.height - 40);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.8,
      size.width - 40,
      50,
    );

    // Route background line
    final routeBgPaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, routeBgPaint);

    // Active Route line
    final activePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, activePaint);

    // Pickup Marker (Donor)
    final donorPaint = Paint()..color = const Color(0xFF22C55E);
    canvas.drawCircle(Offset(30, size.height - 40), 9, donorPaint);
    canvas.drawCircle(
      Offset(30, size.height - 40),
      14,
      Paint()..color = const Color(0xFF22C55E).withValues(alpha: 0.3),
    );

    // Destination Marker (Shelter)
    final shelterPaint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawCircle(Offset(size.width - 40, 50), 9, shelterPaint);
    canvas.drawCircle(
      Offset(size.width - 40, 50),
      14,
      Paint()..color = const Color(0xFFEF4444).withValues(alpha: 0.3),
    );

    // Vehicle Marker along path
    final pathMetrics = path.computeMetrics().first;
    final tangent = pathMetrics.getTangentForOffset(
      pathMetrics.length * progress,
    );
    if (tangent != null) {
      final vehiclePos = tangent.position;
      final vanPaint = Paint()..color = Colors.white;
      canvas.drawCircle(vehiclePos, 12, vanPaint);
      canvas.drawCircle(
        vehiclePos,
        18,
        Paint()..color = const Color(0xFF38BDF8).withValues(alpha: 0.35),
      );

      final centerDot = Paint()..color = const Color(0xFF0284C7);
      canvas.drawCircle(vehiclePos, 5, centerDot);
    }
  }

  @override
  bool shouldRepaint(covariant _MapGridPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
