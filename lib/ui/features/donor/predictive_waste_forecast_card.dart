import 'package:flutter/material.dart';
import '../../core/widgets/app_button.dart';
import '../../../data/repositories/app_repository.dart';

class PredictiveWasteForecastCard extends StatefulWidget {
  final AppRepository repository;

  const PredictiveWasteForecastCard({super.key, required this.repository});

  @override
  State<PredictiveWasteForecastCard> createState() =>
      _PredictiveWasteForecastCardState();
}

class _PredictiveWasteForecastCardState
    extends State<PredictiveWasteForecastCard> {
  bool _isScheduled = false;

  @override
  Widget build(BuildContext context) {
    final org =
        widget.repository.currentUser.organizationName ?? 'Your Kitchen';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFA5B4FC).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFFA5B4FC),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'TONIGHT\'S FORECAST',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Color(0xFFA5B4FC),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '89% match',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Tonight\'s Extra Food Estimate',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Based on the last 3 weekends at $org, about 35–45 plates of rice and gravy may be left over around 10:30 PM.',
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFFC7D2FE),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // ESTIMATED BENEFICIARY CHIP & TIME
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white24),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      'Estimated Food',
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '~40 Plates',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text('•', style: TextStyle(color: Colors.white38)),
                Column(
                  children: [
                    Text(
                      'Best Pickup Time',
                      style: TextStyle(fontSize: 10, color: Colors.white60),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '10:30 PM - 11:00 PM',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFBBF24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          if (_isScheduled)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF065F46),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF34D399),
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pickup scheduled! A helper will arrive around 10:30 PM.',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            AppButton(
              label: 'Schedule 10:30 PM Pickup',
              icon: Icons.alarm_on_rounded,
              onPressed: () {
                setState(() => _isScheduled = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pickup scheduled for 10:30 PM! Nearby helper notified.',
                    ),
                    backgroundColor: Color(0xFF4338CA),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
