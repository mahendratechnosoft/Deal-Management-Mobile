import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_date_picker.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/lead_delete.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import '../../bloc/bloc.dart';
import '../../bloc/state.dart';
import '../../data/model/all_lead_model.dart';
import '../widgets/all_lead_card.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize with status from query parameter
    context.read<LeadBloc>().add(FetchAllLeadsEvent(
          status: widget.status,
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
        status: widget.status,
      ));
      log('LOAD MORE TRIGGERED');
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text;

    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }

    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      context.read<LeadBloc>().add(SearchLeadsEvent(query));
    });
  }

  void _onDateSelected(DateTime? date) {
    context.read<LeadBloc>().add(FilterByDateEvent(date));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<LeadBloc>().add(const ClearSearchEvent());
  }

  void _clearDate() {
    context.read<LeadBloc>().add(const FilterByDateEvent(null));
  }

  void _clearAllFilters() {
    _searchController.clear();
    context.read<LeadBloc>().add(const ClearAllFiltersEvent());
  }

  // void _clearStatusFilter() {
  //   context.push(AppRouteName.allLead);
  // }

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
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(
        title: widget.status != null ? '${widget.status}' : 'All Leads',
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) {
            return SkeletonCard(isLoading: true, itemCount: 10);
          }

          if (state is AllLeadState) {
            return _buildLeadContent(context, state);
          }

          if (state is LeadError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLeadContent(BuildContext context, AllLeadState state) {
    final displayLeads = state.filteredLeads;
    final hasActiveFilters = state.isSearching || state.isDateFiltered;
    final hasStatusFilter = widget.status != null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeadBloc>().add(RefreshLeads(status: widget.status));
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: AppTextField(
                    prefixIcon: const Icon(Icons.search),
                    hint: 'Search',
                    controller: _searchController,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: _clearSearch,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: CustomDatePicker(
                    hintText: 'Date',
                    selectedDate: state.selectedDate,
                    onDateSelected: _onDateSelected,
                  ),
                ),
                displayLeads.isEmpty
                    ? IconButton(
                        onPressed: _clearDate,
                        icon: Icon(
                          Icons.clear,
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            ),
          ),
          if (hasStatusFilter || hasActiveFilters)
            _buildFilterIndicators(state, hasStatusFilter),
          if (displayLeads.isEmpty && (hasStatusFilter || hasActiveFilters))
            _buildNoResultsMessage(state, hasStatusFilter),
          Expanded(
            child: displayLeads.isEmpty && !hasStatusFilter && !hasActiveFilters
                ? const Center(child: Text('No leads found'))
                : _buildLeadsListView(
                    state, displayLeads, hasStatusFilter || hasActiveFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterIndicators(AllLeadState state, bool hasStatusFilter) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
      child: Column(
        children: [
          if (state.filteredLeads.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Row(
                children: [
                  Text(
                    '${state.filteredLeads.length} result${state.filteredLeads.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  if (state.isSearching ||
                      state.isDateFiltered ||
                      hasStatusFilter)
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: const Text(
                        'Clear All',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsMessage(AllLeadState state, bool hasStatusFilter) {
    String message;

    if (hasStatusFilter && state.isSearching && state.isDateFiltered) {
      message =
          'No ${widget.status!.toLowerCase()} leads found for "${state.searchQuery}" on ${_formatDate(state.selectedDate!)}';
    } else if (hasStatusFilter && state.isSearching) {
      message =
          'No ${widget.status!.toLowerCase()} leads found for "${state.searchQuery}"';
    } else if (hasStatusFilter && state.isDateFiltered) {
      message =
          'No ${widget.status!.toLowerCase()} leads found on ${_formatDate(state.selectedDate!)}';
    } else if (hasStatusFilter) {
      message = 'No ${widget.status!.toLowerCase()} leads found';
    } else if (state.isSearching && state.isDateFiltered) {
      message =
          'No results found for "${state.searchQuery}" on ${_formatDate(state.selectedDate!)}. Try different search terms or date.';
    } else if (state.isSearching) {
      message =
          'No results found for "${state.searchQuery}". Load more leads or try different keywords.';
    } else if (state.isDateFiltered) {
      message =
          'No leads found on ${_formatDate(state.selectedDate!)}. Load more leads or select a different date.';
    } else {
      message = 'No leads found';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.info, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsListView(
    AllLeadState state,
    List<LeadModel> displayLeads,
    bool hasFilters,
  ) {
    final shouldLoadMore = state.hasMore &&
        widget.status == null && // Only load more for all leads
        !state.isSearching &&
        !state.isDateFiltered;

    return ListView.builder(
      controller: _controller,
      itemCount: displayLeads.length + (shouldLoadMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (shouldLoadMore && index >= displayLeads.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
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
          onPressed: () async {
            context.read<LeadBloc>().add(LeadDetailsEvent(leadId: lead.id));
            final result = await context.push(
              AppRouteName.createLead,
              extra: true,
            );
            if (result == true) {
              context.read<LeadBloc>().add(
                    FetchAllLeadsEvent(status: widget.status),
                  );
            }
          },
          onTap: () {
            context.read<LeadBloc>().add(LeadDetailsEvent(leadId: lead.id));
            context.push(AppRouteName.leadDetails, extra: lead);
          },
          delete: () async {
            final result = await leadDelete(context, lead.id);
            Future.delayed(Duration(seconds: 2));
            if (result == true) {
              context.read<LeadBloc>().add(
                    FetchAllLeadsEvent(status: widget.status),
                  );
            }
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
