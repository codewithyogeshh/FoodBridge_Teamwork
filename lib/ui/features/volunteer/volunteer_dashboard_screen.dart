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
            Text('Log Out of Volunteer Hub?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your current session and return to the login screen?',
        ),
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
            'डिलिव्हरी स्वीकारली! Proceed to ${donation.donorName} for pickup.',
          ),
          backgroundColor: AppTheme.forestGreen,
        ),
      );
    }
  }

  void _verifyPickup(DonationModel donation) async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 4-digit pickup OTP from donor.'),
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
            'Pickup Verified! Now deliver to ${donation.reservedNgoName ?? "NGO Shelter"}.',
          ),
          backgroundColor: AppTheme.forestGreen,
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
              Text('Delivery Completed!'),
            ],
          ),
          content: Text(
            'Great job! The surplus food was safely handed over to ${donation.reservedNgoName ?? "NGO Kitchen"}.\n\n'
            '₹${fee.toStringAsFixed(0)} delivery fee has been credited to your Volunteer Earnings wallet!',
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
              child: const Text('View Earnings'),
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
                Row(
                  children: [
                    const Text(
                      'Volunteer Courier Desk',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const AppBadge(
                      label: 'HERO',
                      color: AppTheme.forestGreen,
                      bgColor: Color(0xFFECFDF5),
                    ),
                  ],
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
                      const Text('Available'),
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
                      const Text('Active'),
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
                const Tab(text: 'Earnings & Impact'),
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
                          ? 'Duty Status: Online (Ready for Pickups)'
                          : 'Duty Status: Paused',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const Text(
                      'NGOs lacking vehicles request FoodBridge volunteers. Delivery fee (₹20-₹30) paid per trip.',
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
                  'No Deliveries Needing Volunteers Right Now',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'When an NGO without vehicles claims food, it will appear here instantly with guaranteed courier earnings (₹20–₹30).',
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
                      Text(
                        '${d.foodType} • ${d.quantityLabel}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.charcoalMuted,
                        ),
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
                        'EARNINGS',
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
                            'Donor Pickup: ',
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
                            'NGO Drop-off: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.richCharcoal,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              d.reservedNgoName ?? 'Verified NGO Kitchen',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.charcoalMuted,
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
                    'Safe Window: ${d.formattedTimeRemaining}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ),
                AppButton(
                  label: 'Accept Delivery (₹${fee.toStringAsFixed(0)})',
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
                'No Active Deliveries',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Accept a delivery from the "Available" tab to begin pickup and earn delivery fees.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.charcoalMuted),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'View Available Deliveries',
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
                          'Guaranteed Payout: ₹${fee.toStringAsFixed(0)} upon drop-off',
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
                    label: isPickedUp ? 'IN TRANSIT' : 'PICKUP READY',
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
                title: 'Step 1: Pick Up from Donor',
                subtitle: '${d.donorName} • ${d.pickupAddress}',
                isDone: isPickedUp,
                isActive: !isPickedUp,
                action: !isPickedUp
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: 'Enter 4-digit Donor OTP',
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
                                onPressed: _isProcessing
                                    ? null
                                    : () => _verifyPickup(d),
                                child: const Text('Verify Pickup'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Donor Demo OTP: ${d.pickupOtp}',
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
                title: 'Step 2: Deliver to NGO Kitchen',
                subtitle:
                    'Destination: ${d.reservedNgoName ?? "Shelter Kitchen"}',
                isDone: false,
                isActive: isPickedUp,
                action: isPickedUp
                    ? Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: AppButton(
                          label:
                              'Confirm Handover & Collect ₹${fee.toStringAsFixed(0)}',
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
                      'Zero Food Waste Hero',
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
          'Completed Delivery Trips',
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
                  'Past Trips will show here',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Every completed delivery earns ₹20-₹30 paid by NGOs that don\'t have their own fleet.',
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
              'Switch Platform Role',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(
                Icons.storefront_rounded,
                color: AppTheme.forestGreen,
              ),
              title: const Text('Food Donor (Restaurants & Caterers)'),
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
              title: const Text('Community Giver (Donate Clothes / Funds)'),
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
              title: const Text('Verified NGO (Shelter Kitchen)'),
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
              title: const Text('Platform Administrator'),
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
