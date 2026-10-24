import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_card.dart';
import '../../../data/models/community_donation_model.dart';
import '../../../data/repositories/app_repository.dart';

class CreateCommunityDonationScreen extends StatefulWidget {
  final AppRepository repository;
  final void Function(CommunityDonationModel created) onDonationSubmitted;

  const CreateCommunityDonationScreen({
    super.key,
    required this.repository,
    required this.onDonationSubmitted,
  });

  @override
  State<CreateCommunityDonationScreen> createState() =>
      _CreateCommunityDonationScreenState();
}

class _CreateCommunityDonationScreenState
    extends State<CreateCommunityDonationScreen> {
  final _formKey = GlobalKey<FormState>();

  CommunityDonationCategory _selectedCategory =
      CommunityDonationCategory.clothes;

  // General Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _addressController = TextEditingController();
  final _donorNameController = TextEditingController();
  final _donorPhoneController = TextEditingController();

  // Monetary Specific
  int _selectedAmount = 500;
  final _panController = TextEditingController();
  final String _paymentMethod = 'UPI (Google Pay / PhonePe / PayTM)';

  // Clothes Specific
  String _condition = 'Gently Used (Clean & Sanitized)';

  // Books Specific
  String _bookGrade = 'High School (Grades 8-10)';

  // Privacy Protection
  bool _isAnonymous = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _donorNameController.text = widget.repository.currentUser.fullName;
    _donorPhoneController.text = widget.repository.currentUser.phone;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    _addressController.dispose();
    _donorNameController.dispose();
    _donorPhoneController.dispose();
    _panController.dispose();
    super.dispose();
  }

  String get _titleHint {
    switch (_selectedCategory) {
      case CommunityDonationCategory.clothes:
        return 'e.g. Warm Winter Clothes & Blankets';
      case CommunityDonationCategory.books:
        return 'e.g. NCERT Textbooks & Stationery Kits';
      case CommunityDonationCategory.monetary:
        return 'e.g. Hot Nutritious Meals Sponsorship';
      case CommunityDonationCategory.essentials:
        return 'e.g. Dry Rations Package (Rice & Lentils)';
    }
  }

  String get _descriptionHint {
    switch (_selectedCategory) {
      case CommunityDonationCategory.clothes:
        return 'e.g. Clean sweaters, thermal wear, or winter blankets...';
      case CommunityDonationCategory.books:
        return 'e.g. Science, Mathematics, or school notebook sets...';
      case CommunityDonationCategory.monetary:
        return 'e.g. Direct sponsorship for fresh meals at local child shelter...';
      case CommunityDonationCategory.essentials:
        return 'e.g. Sealed bags of rice, lentils, or daily hygiene kits...';
    }
  }


  void _onCategoryChanged(CommunityDonationCategory cat) {
    setState(() {
      _selectedCategory = cat;
    });
  }

  void _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategory == CommunityDonationCategory.monetary) {
      if (_panController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Please enter your PAN Card number to generate your official 80G Tax Exemption Certificate.'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final taxReceipt = _selectedCategory == CommunityDonationCategory.monetary
        ? '80G-FB-${DateTime.now().year}-${10000 + DateTime.now().millisecond * 7}'
        : null;

    final donation = CommunityDonationModel(
      id: 'cd-${DateTime.now().millisecondsSinceEpoch}',
      category: _selectedCategory,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      quantityOrAmount: _selectedCategory == CommunityDonationCategory.monetary
          ? '₹$_selectedAmount'
          : _quantityController.text.trim(),
      donorName: _donorNameController.text.trim(),
      donorPhone: _donorPhoneController.text.trim(),
      isAnonymous: _isAnonymous,
      pickupAddress: _selectedCategory == CommunityDonationCategory.monetary
          ? 'Online Contribution ($_paymentMethod)'
          : _addressController.text.trim(),
      status: CommunityDonationStatus.submitted,
      assignedNgoName: 'Annam Kitchen & Shelter Trust',
      tax80GReceiptNumber: taxReceipt,
      paymentTransactionId:
          _selectedCategory == CommunityDonationCategory.monetary
              ? 'TXN-UPI-${DateTime.now().millisecondsSinceEpoch}'
              : null,
      conditionRating: _condition,
      createdAt: DateTime.now(),
    );

    final created = await widget.repository.createCommunityDonation(donation);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (taxReceipt != null) {
        _show80GSuccessModal(created);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isAnonymous
                  ? 'Donation pledged anonymously! Pickup coordinator assigned.'
                  : 'Thank you! Your donation was submitted to verified shelters.',
            ),
            backgroundColor: AppTheme.forestGreen,
          ),
        );
        widget.onDonationSubmitted(created);
      }
    }
  }

  void _show80GSuccessModal(CommunityDonationModel donation) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppTheme.forestGreen, size: 28),
            SizedBox(width: 10),
            Text('80G Tax Exemption Generated'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.emeraldLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: AppTheme.forestGreen, size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CERTIFICATE NUMBER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.forestGreen,
                          ),
                        ),
                        Text(
                          donation.tax80GReceiptNumber ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Amount: ${donation.quantityOrAmount}\nBeneficiary: ${donation.assignedNgoName}\nEligible Deduction: 50% under Section 80G of the Income Tax Act.',
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              _isAnonymous
                  ? '🔒 Anonymous Giving Mode: Your legal receipt is privately sent to your contact details and not publicized.'
                  : 'A copy has been dispatched to your email address.',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.charcoalMuted,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.forestGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDonationSubmitted(donation);
            },
            child: const Text('Download Receipt & Finish'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmIvory,
      appBar: AppBar(
        title: const Text('Donate Items or Funds'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Relief Contribution',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: AppTheme.richCharcoal,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a category below. Our verified logistics network connects your generous gift to local shelters, children homes, and community kitchens.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.charcoalMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // CATEGORY SELECTOR CHIPS
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: CommunityDonationCategory.values.map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat == CommunityDonationCategory.clothes
                                    ? Icons.checkroom_rounded
                                    : cat == CommunityDonationCategory.books
                                        ? Icons.menu_book_rounded
                                        : cat == CommunityDonationCategory.monetary
                                            ? Icons.currency_rupee_rounded
                                            : Icons.inventory_2_rounded,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppTheme.forestGreen,
                              ),
                              const SizedBox(width: 6),
                              Text(cat.label),
                            ],
                          ),
                          selected: isSelected,
                          selectedColor: AppTheme.forestGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.richCharcoal,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          onSelected: (selected) {
                            if (selected) _onCategoryChanged(cat);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // CATEGORY-SPECIFIC FORM
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      AppTextField(
                        label: 'Donation Title',
                        hint: _titleHint,
                        controller: _titleController,
                        prefixIcon: Icons.title_rounded,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required field' : null,
                      ),
                      const SizedBox(height: 14),

                      // CATEGORY SPECIFIC FIELDS
                      if (_selectedCategory ==
                          CommunityDonationCategory.monetary) ...[
                        _buildMonetarySection(),
                      ] else if (_selectedCategory ==
                          CommunityDonationCategory.clothes) ...[
                        _buildClothesSection(),
                      ] else if (_selectedCategory ==
                          CommunityDonationCategory.books) ...[
                        _buildBooksSection(),
                      ] else ...[
                        _buildEssentialsSection(),
                      ],

                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Detailed Description & Handling Instructions',
                        hint: _descriptionHint,
                        controller: _descriptionController,
                        prefixIcon: Icons.description_rounded,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 14),

                      if (_selectedCategory !=
                          CommunityDonationCategory.monetary) ...[
                        AppTextField(
                          label: 'Pickup Address & Landmarks',
                          hint: 'Building name, road, postal code',
                          controller: _addressController,
                          prefixIcon: Icons.location_on_rounded,
                          validator: (v) => v == null || v.isEmpty
                              ? 'Pickup address is required'
                              : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // PRIVACY CONTROLS
                      const Divider(),
                      const SizedBox(height: 10),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeThumbColor: AppTheme.forestGreen,
                        activeTrackColor: AppTheme.forestGreen.withValues(alpha: 0.4),
                        title: const Row(
                          children: [
                            Icon(Icons.visibility_off_rounded,
                                size: 18, color: AppTheme.forestGreen),
                            SizedBox(width: 8),
                            Text(
                              'Donate Anonymously',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.richCharcoal),
                            ),
                          ],
                        ),
                        subtitle: const Text(
                          'Hide your name and phone number on public community walls and recipient rosters.',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.charcoalMuted),
                        ),
                        value: _isAnonymous,
                        onChanged: (val) => setState(() => _isAnonymous = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                AppButton(
                  label: _selectedCategory == CommunityDonationCategory.monetary
                      ? 'Proceed to Secure 80G Contribution (₹$_selectedAmount)'
                      : 'Schedule Pickup & Pledge Donation',
                  icon: _selectedCategory == CommunityDonationCategory.monetary
                      ? Icons.lock_rounded
                      : Icons.arrow_forward_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _submitDonation,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MONETARY 80G FORM SECTION
  Widget _buildMonetarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Sponsorship Tier',
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.richCharcoal),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [250, 500, 1000, 2500].map((amt) {
            final isSel = _selectedAmount == amt;
            return ChoiceChip(
              label: Text('₹$amt'),
              selected: isSel,
              selectedColor: AppTheme.emeraldLight,
              labelStyle: TextStyle(
                color: isSel ? AppTheme.forestGreen : AppTheme.richCharcoal,
                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
              ),
              onSelected: (val) {
                if (val) {
                  setState(() {
                    _selectedAmount = amt;
                  });
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        AppTextField(
          label: 'Permanent Account Number (PAN) • For 80G Tax Exemption',
          hint: 'e.g. ABCDE1234F',
          controller: _panController,
          prefixIcon: Icons.badge_rounded,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.warmIvoryDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.borderColor),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 18, color: AppTheme.forestGreen),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tax certificate is generated instantly upon payment confirmation. 50% eligible deduction under Section 80G.',
                  style: TextStyle(
                      fontSize: 11, color: AppTheme.charcoalMuted, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // CLOTHES FORM SECTION
  Widget _buildClothesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Item Count',
                hint: 'e.g. 15 pcs',
                controller: _quantityController,
                prefixIcon: Icons.format_list_numbered_rounded,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Condition',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.richCharcoal)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _condition,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                              value: 'Brand New (Unused)',
                              child: Text('Brand New',
                                  style: TextStyle(fontSize: 12))),
                          DropdownMenuItem(
                              value: 'Gently Used (Clean & Sanitized)',
                              child: Text('Gently Used',
                                  style: TextStyle(fontSize: 12))),
                        ],
                        onChanged: (v) => setState(() => _condition = v!),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // BOOKS FORM SECTION
  Widget _buildBooksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Quantity (Books / Bundles)',
          hint: 'e.g. 25 Books',
          controller: _quantityController,
          prefixIcon: Icons.book_rounded,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Audience / Educational Level',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.richCharcoal)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _bookGrade,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                        value: 'Primary School (Grades 1-5)',
                        child: Text('Primary (Grades 1-5)',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'High School (Grades 8-10)',
                        child: Text('High School (Grades 8-10)',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'College / Reference',
                        child: Text('College / Reference',
                            style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(
                        value: 'Storybooks & Fiction',
                        child: Text('Storybooks & Literature',
                            style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (v) => setState(() => _bookGrade = v!),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ESSENTIALS FORM SECTION
  Widget _buildEssentialsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          label: 'Weight / Packaging Volume',
          hint: 'e.g. 30 kg Grains or 12 Hygiene Kits',
          controller: _quantityController,
          prefixIcon: Icons.scale_rounded,
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }
}
