import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/all_lead_card.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/lead_delete.dart';
import 'package:xpertbiz/features/app_route_name.dart';

class AllLeadScreen extends StatefulWidget {
  final String? status;

  const AllLeadScreen({super.key, this.status});

  @override
  State<AllLeadScreen> createState() => _AllLeadScreenState();
}

class _AllLeadScreenState extends State<AllLeadScreen> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String? _currentStatus;

  static const List<String> _statusFilters = [
    'All',
    'New Lead',
    'Contacted',
    'Qualified',
    'Proposal',
    'Negotiation',
    'Converted',
    'Won',
    'Lost',
  ];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;

    context.read<LeadBloc>().add(FetchAllLeadsEvent(
          status: _currentStatus,
        ));

    _controller.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _onScroll() {
    final bloc = context.read<LeadBloc>();
    final state = bloc.state;

    if (state is AllLeadState &&
        state.hasMore &&
        !state.isSearching &&
        !state.isDateFiltered &&
        _controller.position.pixels >=
            _controller.position.maxScrollExtent - 200) {
      bloc.add(FetchAllLeadsEvent(
        loadMore: true,
        status: _currentStatus,
      ));
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      context.read<LeadBloc>().add(SearchLeadsEvent(query, status: _currentStatus));
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<LeadBloc>().add(const ClearSearchEvent());
  }

  void _clearAllFilters() {
    _searchController.clear();
    setState(() {
      _currentStatus = null;
    });
    context.read<LeadBloc>().add(const ClearAllFiltersEvent());
  }

  void _onStatusFilterSelected(String status) {
    setState(() {
      _currentStatus = status == 'All' ? null : status;
    });
    context.read<LeadBloc>().add(
          FetchAllLeadsEvent(status: _currentStatus),
        );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _controller.removeListener(_onScroll);
    _controller.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: _currentStatus != null ? _currentStatus! : 'All Leads',
        actions: [
          IconButton(
            tooltip: 'Add Lead',
            icon: const Icon(Icons.add_circle_outline_rounded,
                color: Colors.white),
            onPressed: () async {
              final result = await context.push(
                AppRouteName.createLead,
                extra: false,
              );
              if (result == true && context.mounted) {
                context.read<LeadBloc>().add(
                      FetchAllLeadsEvent(status: _currentStatus),
                    );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) {
            return SkeletonCard(isLoading: true, itemCount: 8);
          }

          if (state is AllLeadState) {
            return _buildLeadContent(context, state);
          }

          if (state is LeadError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.red.shade400),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        context.read<LeadBloc>().add(
                              FetchAllLeadsEvent(status: _currentStatus),
                            );
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLeadContent(BuildContext context, AllLeadState state) {
    final displayLeads = state.filteredLeads;
    final hasActiveFilters =
        state.isSearching || _currentStatus != null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeadBloc>().add(RefreshLeads(status: _currentStatus));
      },
      child: Column(
        children: [
          // 1. Full-width Search Bar (Date filter hidden as requested)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            color: Colors.white,
            child: SizedBox(
              height: 42,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search leads...',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: Color(0xFF94A3B8)),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 19, color: Color(0xFF94A3B8)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 16),
                          onPressed: _clearSearch,
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // 2. Horizontally Scrollable Status Chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              itemCount: _statusFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusFilters[index];
                final isSelected = status == 'All'
                    ? _currentStatus == null
                    : _currentStatus == status;

                return InkWell(
                  onTap: () => _onStatusFilterSelected(status),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. Active Filters Counter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF8FAFC),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${displayLeads.length} leads found',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                if (hasActiveFilters)
                  InkWell(
                    onTap: _clearAllFilters,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close_rounded,
                            size: 14, color: Color(0xFF2563EB)),
                        SizedBox(width: 4),
                        Text(
                          'Clear Filters',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 4. Leads List / Empty State
          Expanded(
            child: displayLeads.isEmpty
                ? _buildEmptyState(hasActiveFilters)
                : ListView.builder(
                    controller: _controller,
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                    itemCount: displayLeads.length + (state.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == displayLeads.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final lead = displayLeads[index];
                      return PremiumLeadCard(
                        clientName: lead.clientName ?? '',
                        companyName: lead.companyName ?? '',
                        email: lead.email ?? '',
                        phone: lead.mobileNumber ?? '',
                        status: lead.status,
                        createdDate: lead.createdDate ?? DateTime.now(),
                        onTap: () {
                          context
                              .read<LeadBloc>()
                              .add(LeadDetailsEvent(leadId: lead.id));
                          context.push(AppRouteName.leadDetails, extra: lead);
                        },
                        onPressed: () async {
                          context
                              .read<LeadBloc>()
                              .add(LeadDetailsEvent(leadId: lead.id));
                          final result = await context.push(
                            AppRouteName.createLead,
                            extra: true,
                          );
                          if (result == true && context.mounted) {
                            context.read<LeadBloc>().add(
                                  FetchAllLeadsEvent(status: _currentStatus),
                                );
                          }
                        },
                        delete: () async {
                          final result = await leadDelete(context, lead.id);
                          if (result == true && context.mounted) {
                            context.read<LeadBloc>().add(
                                  FetchAllLeadsEvent(status: _currentStatus),
                                );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 44,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Leads Found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              hasFilters
                  ? 'Try adjusting your search query or status filter.'
                  : 'There are currently no leads available.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset All Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
