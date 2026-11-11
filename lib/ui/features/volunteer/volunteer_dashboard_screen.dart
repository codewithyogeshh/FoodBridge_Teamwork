import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/notification_bell_button.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';

class VolunteerDashboardScreen extends StatefulWidget {
  final AppRepository repository;
  final void Function(UserRole role) onSwitchRole;
  final VoidCallback? onLogout;

  const VolunteerDashboardScreen({
    super.key,
    required this.repository,
    required this.onSwitchRole,
    this.onLogout,
  });

  @override
  State<VolunteerDashboardScreen> createState() =>
      _VolunteerDashboardScreenState();
}

class _VolunteerDashboardScreenState extends State<VolunteerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true;
  final _otpController = TextEditingController();
  bool _isProcessing = false;
  double _currentDistanceToDonorMeters = 340.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: AppTheme.statusCritical),
            SizedBox(width: 10),
            Text('Log Out?'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusCritical,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout?.call();
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _acceptBatchedDelivery(DonationModel d1, DonationModel d2) async {
    setState(() => _isProcessing = true);
    final user = widget.repository.currentUser;
    final s1 = await widget.repository.acceptVolunteerDelivery(
      donationId: d1.id,
      volunteerId: user.id,
      volunteerName: user.fullName,
    );
    final s2 = await widget.repository.acceptVolunteerDelivery(
      donationId: d2.id,
      volunteerId: user.id,
      volunteerName: user.fullName,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);
    if (s1 || s2) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s1 && s2
                ? '2-Stop route accepted! Earn ₹55 for both pickups.'
                : 'Pickup accepted! Go to pickup shop.',
          ),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not accept route. Orders may have expired.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
    }
  }

  void _acceptDelivery(DonationModel donation) async {
    setState(() => _isProcessing = true);
    final user = widget.repository.currentUser;
    final success = await widget.repository.acceptVolunteerDelivery(
      donationId: donation.id,
      volunteerId: user.id,
      volunteerName: user.fullName,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _tabController.animateTo(1);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Trip accepted! Go to ${donation.donorName} for pickup.',
          ),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not accept this trip right now.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
    }
  }

  void _verifyPickup(DonationModel donation) async {
    if (_currentDistanceToDonorMeters > 50) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Go within 50m of the shop before entering the PIN.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 4-digit pickup PIN from the donor.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final success = await widget.repository.confirmVolunteerPickup(
      donationId: donation.id,
      enteredOtp: otp,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _otpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pickup confirmed! Now deliver to ${donation.reservedNgoName ?? "NGO Kitchen"}.',
          ),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wrong PIN. Check the donor PIN and try again.'),
          backgroundColor: AppTheme.statusCritical,
        ),
      );
    }
  }

  void _completeDelivery(DonationModel donation) async {
    setState(() => _isProcessing = true);
    final fee = donation.deliveryFee > 0 ? donation.deliveryFee : 25.0;
    final success = await widget.repository.completeVolunteerDelivery(
      donationId: donation.id,
    );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                color: AppTheme.emerald,
                size: 28,
              ),
              SizedBox(width: 10),
              Text('Delivery Complete!'),
            ],
          ),
          content: Text(
            'Great job! Food handed over to ${donation.reservedNgoName ?? "NGO Kitchen"}.\n\n'
            '₹${fee.toStringAsFixed(0)} added to your earnings!',
            style: const TextStyle(fontSize: 13.5, height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.forestGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _tabController.animateTo(2);
              },
              child: const Text('See Earnings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final available = widget.repository.availableVolunteerDeliveries;
        final active = widget.repository.myActiveDeliveries;
        final completed = widget.repository.myCompletedDeliveries;
        final earnings = widget.repository.volunteerTotalEarnings;

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Delivery Helper',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  widget.repository.currentUser.fullName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
              ],
            ),
            actions: [
              NotificationBellButton(repository: widget.repository),
              IconButton(
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Switch Role',
                onPressed: () => _showRoleSwitchDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Log Out',
                onPressed: () => _confirmLogout(context),
              ),
            ],
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
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Jobs'),
                      if (available.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${available.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('My Trip'),
                      if (active.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.forestGreen,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${active.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Earnings'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAvailableTab(available),
              _buildActiveTab(active),
              _buildEarningsTab(completed, earnings),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailableTab(List<DonationModel> available) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Duty Status Banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _isOnline ? const Color(0xFFECFDF5) : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isOnline ? AppTheme.forestGreen : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isOnline ? AppTheme.emerald : Colors.grey,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isOnline
                          ? 'Online • Ready for Pickups'
                          : 'Offline • Paused',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const Text(
                      'Earn ₹20–₹30 per trip delivering food for NGOs.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isOnline,
                activeThumbColor: AppTheme.forestGreen,
                activeTrackColor: AppTheme.emeraldLight,
                onChanged: (val) => setState(() => _isOnline = val),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // SMART MULTI-STOP BATCH CARD (COMBINED PICKUPS)
        if (available.length >= 2) ...[
          _buildMultiStopBatchCard(available[0], available[1]),
          const SizedBox(height: 16),
        ],

        if (available.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.moped_rounded,
                  size: 48,
                  color: AppTheme.charcoalMuted,
                ),
                SizedBox(height: 12),
                Text(
                  'No Delivery Jobs Right Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'New pickup jobs will show up here when an NGO needs a helper (₹20–₹30).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.charcoalMuted),
                ),
              ],
            ),
          )
        else
          ...available.map((d) => _buildDeliveryCard(d)),
      ],
    );
  }

  Widget _buildDeliveryCard(DonationModel d) {
    final fee = d.deliveryFee > 0 ? d.deliveryFee : 25.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delivery_dining_rounded,
                    color: Color(0xFFEA580C),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.richCharcoal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '${d.foodType} • ${d.quantityServings} plates',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          AppBadge(
                            label: d.status == DonationStatus.reserved
                                ? 'NGO BOOKED'
                                : 'NEW',
                            color: d.status == DonationStatus.reserved
                                ? const Color(0xFFEA580C)
                                : AppTheme.forestGreen,
                            bgColor: d.status == DonationStatus.reserved
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFECFDF5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'PAY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF047857),
                        ),
                      ),
                      Text(
                        '₹${fee.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF047857),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(color: AppTheme.borderColor),
            const SizedBox(height: 8),

            // Pickup & Drop Route
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(
                      Icons.circle,
                      size: 10,
                      color: AppTheme.forestGreen,
                    ),
                    Container(
                      width: 1.5,
                      height: 24,
                      color: Colors.grey.shade300,
                    ),
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFFEA580C),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Pick Up: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${d.donorName} (${d.pickupAddress})',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.charcoalMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Drop Off: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              d.reservedNgoName ?? 'Nearest Verified NGO',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: d.reservedNgoName != null
                                    ? AppTheme.charcoalMuted
                                    : const Color(0xFF047857),
                                fontWeight: d.reservedNgoName != null
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Best Before: ${d.formattedTimeRemaining}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                AppButton(
                  label: 'Accept Trip (₹${fee.toStringAsFixed(0)})',
                  icon: Icons.two_wheeler_rounded,
                  isLoading: _isProcessing,
                  onPressed: () => _acceptDelivery(d),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiStopBatchCard(DonationModel d1, DonationModel d2) {
    final totalServings = d1.quantityServings + d2.quantityServings;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '2-STOP ROUTE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF047857),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'EARN ₹55',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Two nearby pickups going to the same NGO. Pick up both and earn double!',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF78350F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.looks_one_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stop 1: ${d1.donorName} (${d1.title})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${d1.quantityServings} meals',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '│',
                      style: TextStyle(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.looks_two_rounded,
                      size: 18,
                      color: Color(0xFFD97706),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Stop 2: ${d2.donorName} (${d2.title})',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${d2.quantityServings} meals',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '│',
                      style: TextStyle(color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: Color(0xFF047857),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Drop: ${d1.reservedNgoName ?? "Nearest Verified NGO"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: Color(0xFF047857),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Total $totalServings plates',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.electric_moped_rounded, size: 18),
              label: const Text(
                'Accept Both Pickups (Earn ₹55)',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              ),
              onPressed: () => _acceptBatchedDelivery(d1, d2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTab(List<DonationModel> active) {
    if (active.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 54,
                color: AppTheme.forestGreen,
              ),
              const SizedBox(height: 14),
              const Text(
                'No Active Trip',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pick a job from the "Jobs" tab to start delivery and earn ₹20–₹30.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.charcoalMuted),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'See Jobs',
                icon: Icons.explore_rounded,
                onPressed: () => _tabController.animateTo(0),
              ),
            ],
          ),
        ),
      );
    }

    final d = active.first;
    final fee = d.deliveryFee > 0 ? d.deliveryFee : 25.0;
    final isPickedUp = d.status == DonationStatus.pickupVerified;
    final withinRange = _currentDistanceToDonorMeters <= 50;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delivery_dining_rounded,
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
                          d.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Pay: ₹${fee.toStringAsFixed(0)} after delivery',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppBadge(
                    label: isPickedUp ? 'ON THE WAY' : 'AT SHOP',
                    color: isPickedUp
                        ? const Color(0xFF0284C7)
                        : const Color(0xFFD97706),
                    bgColor: isPickedUp
                        ? const Color(0xFFE0F2FE)
                        : const Color(0xFFFEF3C7),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Stepper Flow
              _buildStepItem(
                step: 1,
                title: 'Step 1: Pick Up Food',
                subtitle: '${d.donorName} • ${d.pickupAddress}',
                isDone: isPickedUp,
                isActive: !isPickedUp,
                action: !isPickedUp
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),

                          // SHOP DISTANCE CHECK BADGE
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: withinRange
                                  ? const Color(0xFFECFDF5)
                                  : const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: withinRange
                                    ? AppTheme.forestGreen
                                    : const Color(0xFFD97706),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  withinRange
                                      ? Icons.verified_user_rounded
                                      : Icons.fmd_bad_rounded,
                                  color: withinRange
                                      ? AppTheme.forestGreen
                                      : const Color(0xFFD97706),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        withinRange
                                            ? 'AT PICKUP SHOP (${_currentDistanceToDonorMeters.toInt()}m)'
                                            : 'REACH SHOP FIRST (${_currentDistanceToDonorMeters.toInt()}m away)',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: withinRange
                                              ? AppTheme.forestGreen
                                              : const Color(0xFFD97706),
                                        ),
                                      ),
                                      Text(
                                        withinRange
                                            ? 'Location matched. Enter the 4-digit PIN below.'
                                            : 'Must be within 50m of shop to enter pickup PIN.',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          color: AppTheme.charcoalMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    minimumSize: const Size(50, 26),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _currentDistanceToDonorMeters =
                                          withinRange ? 340.0 : 18.0;
                                    });
                                  },
                                  child: Text(
                                    withinRange
                                        ? 'Reset Demo'
                                        : 'Demo: Reach Shop',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  enabled: withinRange,
                                  decoration: InputDecoration(
                                    hintText: withinRange
                                        ? 'Enter 4-digit PIN'
                                        : 'Reach shop (within 50m)',
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.forestGreen,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: (_isProcessing || !withinRange)
                                    ? null
                                    : () => _verifyPickup(d),
                                child: const Text('Verify'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Demo Pickup PIN: ${d.pickupOtp}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                        ],
                      )
                    : null,
              ),

              const SizedBox(height: 14),
              _buildStepItem(
                step: 2,
                title: 'Step 2: Deliver to NGO',
                subtitle: 'Drop at: ${d.reservedNgoName ?? "NGO Kitchen"}',
                isDone: false,
                isActive: isPickedUp,
                action: isPickedUp
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: AppButton(
                          label:
                              'Mark Delivered & Earn ₹${fee.toStringAsFixed(0)}',
                          icon: Icons.check_circle_rounded,
                          isLoading: _isProcessing,
                          onPressed: () => _completeDelivery(d),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({
    required int step,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isActive,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.emeraldLight.withValues(alpha: 0.2)
            : isDone
            ? Colors.grey.shade50
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? AppTheme.forestGreen
              : isDone
              ? Colors.grey.shade300
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: isDone
                    ? AppTheme.forestGreen
                    : isActive
                    ? const Color(0xFFEA580C)
                    : Colors.grey.shade300,
                child: isDone
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '$step',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? AppTheme.richCharcoal
                        : isDone
                        ? AppTheme.forestGreen
                        : AppTheme.charcoalMuted,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 32, top: 4),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.charcoalMuted,
              ),
            ),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 8),
              child: action,
            ),
        ],
      ),
    );
  }

  Widget _buildEarningsTab(
    List<DonationModel> completed,
    double totalEarnings,
  ) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // Earnings Stats Grid
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL EARNINGS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${totalEarnings.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF047857),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '₹20–₹30 per trip',
                      style: TextStyle(fontSize: 10, color: Color(0xFF065F46)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF3B82F6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TRIPS COMPLETED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${completed.length + 2}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1D4ED8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Completed trips',
                      style: TextStyle(fontSize: 10, color: Color(0xFF1E40AF)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        const Text(
          'Past Deliveries',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.richCharcoal,
          ),
        ),
        const SizedBox(height: 10),

        if (completed.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: AppTheme.charcoalMuted,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'Your completed trips will show here',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Earn ₹20–₹30 for each completed food delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.charcoalMuted,
                  ),
                ),
              ],
            ),
          )
        else
          ...completed.map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'To: ${c.reservedNgoName ?? "NGO Kitchen"}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.charcoalMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '+₹${(c.deliveryFee > 0 ? c.deliveryFee : 25.0).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.forestGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showRoleSwitchDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Switch Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: AppTheme.forestGreen,
              ),
              title: const Text('Food Donor (Hotels & Kitchens)'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSwitchRole(UserRole.donor);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.volunteer_activism_rounded,
                color: Color(0xFFD97706),
              ),
              title: const Text('Community Giver'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSwitchRole(UserRole.community);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.soup_kitchen_rounded,
                color: Color(0xFF0D9488),
              ),
              title: const Text('NGO Kitchen'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSwitchRole(UserRole.ngo);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.admin_panel_settings_rounded,
                color: Color(0xFF4F46E5),
              ),
              title: const Text('Admin'),
              onTap: () {
                Navigator.pop(ctx);
                widget.onSwitchRole(UserRole.admin);
              },
            ),
          ],
        ),
      ),
    );
  }
}
