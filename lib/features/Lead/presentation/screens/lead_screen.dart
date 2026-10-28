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
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  LoginResponse? user;
  bool canCreate = true;
  String? _selectedStatus; // null means 'All Leads'

  @override
  void initState() {
    super.initState();
    user = AuthLocalStorage.getUser();
    canCreate = user?.moduleAccess.leadCreate ?? true;
    final bool hasAccess = user?.moduleAccess.leadAccess ?? false;
    if (hasAccess) {
      _fetchLeads(page: 0);
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchLeads({int page = 0}) {
    context.read<LeadBloc>().add(
          FetchAllLeadsEvent(
            page: page,
            status: _selectedStatus,
            search: _searchController.text.trim().isNotEmpty
                ? _searchController.text.trim()
                : null,
          ),
        );
  }

  void _onSearchChanged(String query) {
    if (_searchDebounce?.isActive ?? false) {
      _searchDebounce!.cancel();
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      context.read<LeadBloc>().add(
            SearchLeadsEvent(
              query,
              status: _selectedStatus,
            ),
          );
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<LeadBloc>().add(
          SearchLeadsEvent(
            '',
            status: _selectedStatus,
          ),
        );
  }

  void _onStatusChanged(String? newStatus) {
    setState(() {
      _selectedStatus =
          (newStatus == 'All' || newStatus == null || newStatus.isEmpty)
              ? null
              : newStatus;
    });
    _fetchLeads(page: 0);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAccess = user?.moduleAccess.leadAccess ?? false;
    if (!hasAccess) {
      return Scaffold(
        drawer: const CustomDrawer(),
        appBar: CommonAppBar(title: 'Leads'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_person_rounded,
                    size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You do not have permission to access the Leads module.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: 'Leads',
        actions: [
          if (canCreate)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await context.push(
                    AppRouteName.createLead,
                    extra: false,
                  );
                  if (result == true && context.mounted) {
                    _fetchLeads(page: 0);
                  }
                },
                icon: const Icon(
                  Icons.add_rounded,
                  size: 17,
                  color: Color(0xFF2563EB),
                ),
                label: const Text(
                  'Lead',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2563EB),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF2563EB),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading || state is AllLeadLoading) {
            return Column(
              children: [
                _buildFilterHeader(state),
                Expanded(child: SkeletonCard(isLoading: true, itemCount: 6)),
              ],
            );
          }

          if (state is AllLeadError) {
            return _buildErrorState(state.message);
          }

          if (state is LeadError) {
            return _buildErrorState(state.message);
          }

          if (state is AllLeadState) {
            return Column(
              children: [
                // 1. Full-width Search Bar & Custom Status Dropdown
                _buildFilterHeader(state),

                // 2. Leads List with pull-to-refresh
                Expanded(
                  child: state.isLoadingPage
                      ? SkeletonCard(isLoading: true, itemCount: 6)
                      : (state.leads.isEmpty
                          ? _buildEmptyState()
                          : _buildLeadsList(state)),
                ),

                // 3. Bottom Pagination Bar (with Jump to Page option)
                if (state.leads.isNotEmpty) _buildPaginationBar(state),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// 🔍 Header Filters: Full-width Search Bar & Custom Status Dropdown
  Widget _buildFilterHeader(LeadState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Column(
        children: [
          // Full-width Search Field
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
              decoration: InputDecoration(
                hintText: 'Search leads by name, company, email...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: Color(0xFF64748B),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Custom Modern Pipeline Stage Dropdown
          _buildCustomStatusDropdown(state),
        ],
      ),
    );
  }

  /// 📊 Custom Modern Pipeline Stage Selector Dropdown
  Widget _buildCustomStatusDropdown(LeadState state) {
    final statusList =
        state is AllLeadState ? state.statusAndCount : <StatusCountModel>[];

    // Filter out duplicate or 'all' entries to prevent count duplication
    final cleanStatusList = statusList
        .where((item) =>
            item.status.trim().toLowerCase() != 'all' &&
            item.status.trim().isNotEmpty)
        .toList();

    // Determine correct total count (avoid doubling to 310)
    int totalCount =
        (state is AllLeadState && state.totalLeads > 0) ? state.totalLeads : 0;
    if (totalCount == 0) {
      final allItem = statusList
          .where((e) => e.status.trim().toLowerCase() == 'all')
          .firstOrNull;
      if (allItem != null && allItem.count > 0) {
        totalCount = allItem.count;
      } else {
        totalCount = cleanStatusList.fold<int>(0, (sum, e) => sum + e.count);
      }
    }

    // Current selection label and count
    final isAll = _selectedStatus == null || _selectedStatus == 'All';
    final currentTitle = isAll ? 'All Leads' : _selectedStatus!;
    final currentColor =
        isAll ? const Color(0xFF2563EB) : getLeadStatusColor(_selectedStatus!);
    final currentCount = isAll
        ? totalCount
        : (cleanStatusList
                .where((e) => e.status == _selectedStatus)
                .firstOrNull
                ?.count ??
            0);

    return InkWell(
      onTap: () => _showStatusPickerBottomSheet(
        cleanStatusList: cleanStatusList,
        totalCount: totalCount,
      ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.1),
        ),
        child: Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Stage: ',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
            Expanded(
              child: Text(
                currentTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: currentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$currentCount',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: currentColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// 📱 Pipeline Stage Picker Bottom Sheet
  void _showStatusPickerBottomSheet({
    required List<StatusCountModel> cleanStatusList,
    required int totalCount,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currentSelection = _selectedStatus ?? 'All';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Title
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Text(
                    'Select Pipeline Stage',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // Options List
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Option 1: All Leads
                        _buildBottomSheetStatusItem(
                          title: 'All Leads',
                          count: totalCount,
                          color: const Color(0xFF2563EB),
                          isSelected: currentSelection == 'All',
                          onTap: () {
                            Navigator.pop(context);
                            _onStatusChanged(null);
                          },
                        ),

                        // Options 2..N: Stages
                        ...cleanStatusList.map((item) {
                          final color = getLeadStatusColor(item.status);
                          final isSelected = currentSelection == item.status;
                          return _buildBottomSheetStatusItem(
                            title: item.status,
                            count: item.count,
                            color: color,
                            isSelected: isSelected,
                            onTap: () {
                              Navigator.pop(context);
                              _onStatusChanged(item.status);
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetStatusItem({
    required String title,
    required int count,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 10),
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2563EB),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 📋 Leads List
  Widget _buildLeadsList(AllLeadState state) {
    return RefreshIndicator(
      color: const Color(0xFF2563EB),
      onRefresh: () async => _fetchLeads(page: state.currentPage),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
        itemCount: state.leads.length,
        itemBuilder: (context, index) {
          final lead = state.leads[index];
          return PremiumLeadCard(
            clientName: lead.clientName ?? '',
            companyName: lead.companyName ?? '',
            email: lead.email ?? '',
            phone: lead.mobileNumber ?? '',
            status: lead.status,
            createdDate: lead.createdDate ?? DateTime.now(),
            onTap: () {
              context.read<LeadBloc>().add(LeadDetailsEvent(leadId: lead.id));
              context.push(AppRouteName.leadDetails, extra: lead);
            },
            onPressed: () async {
              context.read<LeadBloc>().add(LeadDetailsEvent(leadId: lead.id));
              final result = await context.push(
                AppRouteName.createLead,
                extra: true,
              );
              if (result == true && context.mounted) {
                _fetchLeads(page: state.currentPage);
              }
            },
            delete: () async {
              final result = await leadDelete(context, lead.id);
              if (result == true && context.mounted) {
                _fetchLeads(page: state.currentPage);
              }
            },
          );
        },
      ),
    );
  }

  /// ⏭️ Bottom Pagination Controls with Jump to Page
  Widget _buildPaginationBar(AllLeadState state) {
    final currentPage = state.currentPage; // 0-indexed
    final totalPages = state.totalPages > 0 ? state.totalPages : 1;
    final isFirstPage = currentPage <= 0;
    final isLastPage = currentPage >= totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            OutlinedButton.icon(
              onPressed: isFirstPage || state.isLoadingPage
                  ? null
                  : () {
                      _fetchLeads(page: currentPage - 1);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 12),
              label: const Text('Prev'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                disabledForegroundColor: const Color(0xFF94A3B8),
                side: BorderSide(
                  color: isFirstPage
                      ? const Color(0xFFE2E8F0)
                      : const Color(0xFFCBD5E1),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            // Jump to Page Button
            InkWell(
              onTap: () => _showJumpToPageDialog(
                context,
                currentPage: currentPage,
                totalPages: totalPages,
              ),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Page ${currentPage + 1} of $totalPages',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.unfold_more_rounded,
                              size: 14,
                              color: Color(0xFF2563EB),
                            ),
                          ],
                        ),
                        if (state.totalLeads > 0)
                          Text(
                            '${state.totalLeads} total leads',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Next Button
            ElevatedButton.icon(
              onPressed: isLastPage || state.isLoadingPage
                  ? null
                  : () {
                      _fetchLeads(page: currentPage + 1);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                      );
                    },
              label: const Text('Next'),
              icon: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                disabledForegroundColor: const Color(0xFF94A3B8),
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎯 Jump to Page Dialog
  void _showJumpToPageDialog(
    BuildContext context, {
    required int currentPage,
    required int totalPages,
  }) {
    final controller =
        TextEditingController(text: '${currentPage + 1}');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Jump to Page',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter page number (1 to $totalPages):',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                        color: Color(0xFF2563EB), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Quick Jump Chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _quickPageChip('Page 1', 1, controller),
                  if (totalPages >= 5) _quickPageChip('Page 5', 5, controller),
                  if (totalPages >= 10)
                    _quickPageChip('Page 10', 10, controller),
                  if (totalPages > 1)
                    _quickPageChip(
                        'Last ($totalPages)', totalPages, controller),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final input = int.tryParse(controller.text.trim());
                if (input != null && input >= 1 && input <= totalPages) {
                  Navigator.pop(context);
                  _fetchLeads(page: input - 1);
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid page between 1 and $totalPages'),
                      backgroundColor: const Color(0xFFDC2626),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Go to Page',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _quickPageChip(
      String label, int targetPage, TextEditingController controller) {
    return InkWell(
      onTap: () => controller.text = '$targetPage',
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  /// 📭 Empty State
  Widget _buildEmptyState() {
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
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _searchController.text.isNotEmpty
                  ? "No results matching '${_searchController.text}'"
                  : (_selectedStatus != null
                      ? "No leads in '$_selectedStatus' stage"
                      : "You don't have any leads yet."),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 18),
            if (_searchController.text.isNotEmpty || _selectedStatus != null)
              OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _selectedStatus = null);
                  _fetchLeads(page: 0);
                },
                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                label: const Text('Reset Filters'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// ❌ Error State
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 50, color: Colors.red.shade400),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _fetchLeads(page: 0),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
