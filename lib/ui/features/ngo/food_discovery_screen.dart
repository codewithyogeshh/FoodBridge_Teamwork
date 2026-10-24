import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_badge.dart';
import '../../core/widgets/map_preview_widget.dart';
import '../../core/widgets/state_widgets.dart';
import '../../../data/models/donation_model.dart';
import '../../../data/repositories/app_repository.dart';
import 'donation_details_screen.dart';

class FoodDiscoveryScreen extends StatefulWidget {
  final AppRepository repository;

  const FoodDiscoveryScreen({super.key, required this.repository});

  @override
  State<FoodDiscoveryScreen> createState() => _FoodDiscoveryScreenState();
}

class _FoodDiscoveryScreenState extends State<FoodDiscoveryScreen> {
  String _selectedCategory = 'All';
  UrgencyLevel? _selectedUrgency;
  bool _isMapView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.repository,
      builder: (context, _) {
        final allAvailable = widget.repository.availableDonations;

        // Apply filters
        final filtered = allAvailable.where((d) {
          if (_selectedCategory != 'All' && d.foodType != _selectedCategory) {
            return false;
          }
          if (_selectedUrgency != null && d.urgencyLevel != _selectedUrgency) {
            return false;
          }
          if (_searchQuery.isNotEmpty) {
            final q = _searchQuery.toLowerCase();
            return d.title.toLowerCase().contains(q) ||
                d.donorName.toLowerCase().contains(q) ||
                d.foodType.toLowerCase().contains(q) ||
                d.pickupAddress.toLowerCase().contains(q);
          }
          return true;
        }).toList();

        return Scaffold(
          backgroundColor: AppTheme.warmIvory,
          appBar: AppBar(
            title: const Text('Discover Surplus Food'),
            actions: [
              IconButton(
                icon: Icon(
                  _isMapView ? Icons.format_list_bulleted_rounded : Icons.map_rounded,
                  color: AppTheme.forestGreen,
                ),
                tooltip: _isMapView ? 'Switch to List' : 'Switch to Map',
                onPressed: () => setState(() => _isMapView = !_isMapView),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Search food batches, bakeries, banquets...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.charcoalMuted),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),

                // Category Chips
                SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildFilterChip('All', _selectedCategory == 'All', () {
                        setState(() => _selectedCategory = 'All');
                      }),
                      ...AppConstants.foodCategories.map((cat) {
                        return _buildFilterChip(cat, _selectedCategory == cat, () {
                          setState(() => _selectedCategory = cat);
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Urgency Priority Filter
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Text(
                        'Urgency:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() => _selectedUrgency = null),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _selectedUrgency == null
                                ? AppTheme.forestGreen
                                : AppTheme.warmIvoryDark,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'All Priorities',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _selectedUrgency == null
                                  ? Colors.white
                                  : AppTheme.charcoalMuted,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => setState(() => _selectedUrgency =
                            _selectedUrgency == UrgencyLevel.critical
                                ? null
                                : UrgencyLevel.critical),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _selectedUrgency == UrgencyLevel.critical
                                ? AppTheme.statusCritical
                                : AppTheme.statusCriticalBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Critical (< 3h)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _selectedUrgency == UrgencyLevel.critical
                                  ? Colors.white
                                  : AppTheme.statusCritical,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${filtered.length} found',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.charcoalMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Content Area: List View OR Map View
                Expanded(
                  child: _isMapView
                      ? _buildMapView(filtered)
                      : _buildListView(filtered),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppTheme.emeraldLight,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.forestGreen : AppTheme.richCharcoal,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildListView(List<DonationModel> list) {
    if (list.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No Matching Surplus Food',
        message:
            'No surplus batches match your active filters. Try clearing urgency or category filters.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = list[index];
        return AppCard(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DonationDetailsScreen(
                  donation: item,
                  repository: widget.repository,
                ),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  UrgencyBadge(level: item.urgencyLevel, compact: true),
                  const Spacer(),
                  StatusBadge(status: item.status),
                ],
              ),
               const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.imageUrl!,
                        width: 72,
                        height: 72,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fastfood_rounded,
                            color: AppTheme.forestGreen,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.storefront_rounded,
                                size: 14, color: AppTheme.charcoalMuted),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${item.donorName} • ${item.quantityLabel}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.5,
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
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.warmIvoryDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined,
                        size: 14, color: AppTheme.forestGreen),
                    const SizedBox(width: 6),
                    Text(
                      item.formattedTimeRemaining,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.richCharcoal,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: AppTheme.charcoalMuted),
                    const SizedBox(width: 4),
                    const Text(
                      '~1.8 km away',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.charcoalMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<DonationModel> list) {
    return Column(
      children: [
        Expanded(
          child: MapPreviewWidget(
            height: double.infinity,
            locationTitle: 'FoodBridge Regional Surplus Grid',
            subtitle: '${list.length} surplus donation hubs available',
            showRoute: false,
          ),
        ),
        if (list.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: AppCard(
              backgroundColor: AppTheme.warmIvoryDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationDetailsScreen(
                      donation: list.first,
                      repository: widget.repository,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.near_me_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          list.first.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.richCharcoal,
                          ),
                        ),
                        Text(
                          '${list.first.quantityLabel} • Tap to view & reserve',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.charcoalMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppTheme.forestGreen),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
