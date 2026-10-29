import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/utils/responsive.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/di/injection_container.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_bloc.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_event.dart';
import 'package:xpertbiz/features/leave_request/bloc/leave_request_state.dart';
import 'package:xpertbiz/features/leave_request/presentation/widgets/leave_card.dart';

class LeaveRequestsScreen extends StatelessWidget {
  const LeaveRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthLocalStorage.getUser();
    final bool isAdmin = user?.role == 'ROLE_ADMIN';
    final bool hasViewAll =
        (user?.moduleAccess.leaveRequestViewAll ?? false) || isAdmin;
    final initialViewType = hasViewAll ? 'ALL_LEAVES' : 'MY_LEAVES';

    return BlocProvider(
      create: (_) => sl<LeaveRequestBloc>()
        ..add(FetchLeavesEvent(viewType: initialViewType, page: 0)),
      child: const _LeaveRequestsView(),
    );
  }
}

class _LeaveRequestsView extends StatefulWidget {
  const _LeaveRequestsView();

  @override
  State<_LeaveRequestsView> createState() => _LeaveRequestsViewState();
}

class _LeaveRequestsViewState extends State<_LeaveRequestsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _searchDebounce;

  LoginResponse? _user;
  bool _isAdmin = false;
  bool _canCreate = true;
  bool _hasApproverAccess = false;
  bool _hasViewAllAccess = false;

  final List<String> _tabs = [];
  final List<String> _viewTypes = [];
  int _lastTabIndex = 0;

  String? _selectedStatus; // null means 'ALL'

  @override
  void initState() {
    super.initState();
    _user = AuthLocalStorage.getUser();
    _isAdmin = _user?.role == 'ROLE_ADMIN';
    _canCreate = _user?.moduleAccess.leaveRequestCreate ?? true;
    _hasApproverAccess =
        (_user?.moduleAccess.leaveRequestApprover ?? false) || _isAdmin;
    _hasViewAllAccess =
        (_user?.moduleAccess.leaveRequestViewAll ?? false) || _isAdmin;

    // Tab Sequence as requested: All Leaves -> My Leaves -> Approvals
    if (_isAdmin) {
      _tabs.add('All Leaves');
      _viewTypes.add('ALL_LEAVES');

      if (_hasApproverAccess) {
        _tabs.add('Approvals');
        _viewTypes.add('APPROVALS');
      }
    } else {
      if (_hasViewAllAccess) {
        _tabs.add('All Leaves');
        _viewTypes.add('ALL_LEAVES');
      }

      _tabs.add('My Leaves');
      _viewTypes.add('MY_LEAVES');

      if (_hasApproverAccess) {
        _tabs.add('Approvals');
        _viewTypes.add('APPROVALS');
      }
    }

    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);

    _scrollController.addListener(_onScroll);
  }

  void _handleTabSelection() {
    if (!_tabController.indexIsChanging && _tabController.index != _lastTabIndex) {
      _lastTabIndex = _tabController.index;
      final selectedView = _viewTypes[_tabController.index];
      _selectedStatus = null;
      _searchController.clear();
      context.read<LeaveRequestBloc>().add(SwitchTabEvent(selectedView));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<LeaveRequestBloc>().add(
            const FetchLeavesEvent(isLoadMore: true),
          );
    }
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      context.read<LeaveRequestBloc>().add(
            FilterLeavesEvent(
              status: _selectedStatus,
              search: query.trim(),
            ),
          );
    });
  }

  void _onStatusFilterSelected(String status) {
    setState(() {
      _selectedStatus = status == 'ALL' ? null : status;
    });
    context.read<LeaveRequestBloc>().add(
          FilterLeavesEvent(
            status: _selectedStatus,
            search: _searchController.text.trim(),
          ),
        );
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CommonAppBar(
        title: 'Leave Requests',
        actions: [
          // Apply Leave Button in AppBar only (as requested)
          if (_canCreate)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Responsive.h(8.5),
                horizontal: Responsive.h(8),
              ),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bloc = context.read<LeaveRequestBloc>();
                  final result = await context.push(AppRouteName.applyLeave);
                  if (result == true && mounted) {
                    final currentView = _viewTypes[_tabController.index];
                    bloc.add(
                      FetchLeavesEvent(
                        viewType: currentView,
                        page: 0,
                        isRefresh: true,
                      ),
                    );
                  }
                },
                icon: Icon(
                  Icons.add_rounded,
                  size: Responsive.h(16),
                  color: const Color(0xFF2563EB),
                ),
                label: Text(
                  'Apply',
                  style: TextStyle(
                    fontSize: Responsive.h(12),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: Responsive.h(10)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(8)),
                  ),
                ),
              ),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(Responsive.h(44)),
          child: Container(
            color: AppColors.primaryDark,
            child: TabBar(
              controller: _tabController,
              isScrollable: false,
              tabAlignment: TabAlignment.fill,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
              labelStyle: TextStyle(
                fontSize: Responsive.h(13),
                fontWeight: FontWeight.w700,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: Responsive.h(13),
                fontWeight: FontWeight.w500,
              ),
              onTap: (index) {
                if (index != _lastTabIndex) {
                  _lastTabIndex = index;
                  final selectedView = _viewTypes[index];
                  _selectedStatus = null;
                  _searchController.clear();
                  context.read<LeaveRequestBloc>().add(SwitchTabEvent(selectedView));
                }
              },
              tabs: _tabs.map((title) => Tab(text: title)).toList(),
            ),
          ),
        ),
      ),
      body: BlocConsumer<LeaveRequestBloc, LeaveRequestState>(
        listener: (context, state) {
          if (state is LeaveListLoaded && state.actionMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.actionMessage!),
                backgroundColor: state.isActionSuccess
                    ? const Color(0xFF16A34A)
                    : AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Fixed Top Search Bar with Right Filter Button
              _buildTopSearchFilterBar(),

              // Active filter pill indicator (if any)
              if (_selectedStatus != null) _buildActiveFilterBanner(),

              // Main List Content
              Expanded(
                child: _buildBodyContent(state),
              ),
            ],
          );
        },
      ),
      // FAB removed as requested; action remains in AppBar
      floatingActionButton: null,
    );
  }

  /// Fixed Top Searchbar with Dropdown Filter on the right
  Widget _buildTopSearchFilterBar() {
    final hasActiveFilter = _selectedStatus != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
        Responsive.h(14),
        Responsive.h(10),
        Responsive.h(14),
        Responsive.h(8),
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 0.8),
        ),
      ),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: SizedBox(
              height: Responsive.h(38),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: TextStyle(
                  fontSize: Responsive.h(12.5),
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Search by employee or reason...',
                  hintStyle: TextStyle(
                    fontSize: Responsive.h(12),
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    size: Responsive.h(17),
                    color: const Color(0xFF64748B),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF1F5F9),
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(8)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(width: Responsive.h(8)),

          // Filter Dropdown Button with Modern Custom Menu
          PopupMenuButton<String>(
            tooltip: 'Filter by Status',
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Responsive.h(14)),
              side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
            elevation: 8,
            offset: const Offset(0, 46),
            onSelected: _onStatusFilterSelected,
            itemBuilder: (context) => [
              _buildPopupHeader(),
              const PopupMenuDivider(height: 1),
              _buildPopupItem(
                value: 'ALL',
                label: 'All Statuses',
                icon: Icons.layers_outlined,
                color: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
              _buildPopupItem(
                value: 'PENDING',
                label: 'Pending',
                icon: Icons.schedule_rounded,
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
              _buildPopupItem(
                value: 'APPROVED',
                label: 'Approved',
                icon: Icons.check_circle_outline_rounded,
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
              _buildPopupItem(
                value: 'REJECTED',
                label: 'Rejected',
                icon: Icons.cancel_outlined,
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEE2E2),
              ),
              _buildPopupItem(
                value: 'CANCELLED',
                label: 'Cancelled',
                icon: Icons.remove_circle_outline_rounded,
                color: const Color(0xFF64748B),
                bgColor: const Color(0xFFF1F5F9),
              ),
            ],
            child: Container(
              height: Responsive.h(38),
              width: Responsive.h(38),
              decoration: BoxDecoration(
                color: hasActiveFilter
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(Responsive.h(8)),
                border: Border.all(
                  color: hasActiveFilter
                      ? const Color(0xFF2563EB)
                      : const Color(0xFFE2E8F0),
                  width: 0.8,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.tune_rounded,
                  size: Responsive.h(18),
                  color: hasActiveFilter
                      ? Colors.white
                      : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildPopupHeader() {
    return PopupMenuItem<String>(
      enabled: false,
      height: 32,
      padding: EdgeInsets.symmetric(horizontal: Responsive.h(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'FILTER STATUS',
            style: TextStyle(
              fontSize: Responsive.h(10),
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: const Color(0xFF94A3B8),
            ),
          ),
          if (_selectedStatus != null)
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                _onStatusFilterSelected('ALL');
              },
              child: Text(
                'Reset',
                style: TextStyle(
                  fontSize: Responsive.h(10.5),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildPopupItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final isSelected = (_selectedStatus == null && value == 'ALL') ||
        _selectedStatus == value;

    return PopupMenuItem<String>(
      value: value,
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: Responsive.h(8)),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Responsive.h(8),
          vertical: Responsive.h(5.5),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(Responsive.h(8)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.h(4)),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(Responsive.h(5)),
              ),
              child: Icon(icon, size: Responsive.h(12.5), color: color),
            ),
            SizedBox(width: Responsive.h(8)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: Responsive.h(12),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF1D4ED8)
                      : const Color(0xFF1E293B),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                size: Responsive.h(15),
                color: const Color(0xFF2563EB),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterBanner() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.h(14),
        vertical: Responsive.h(5),
      ),
      color: const Color(0xFFEFF6FF),
      child: Row(
        children: [
          Text(
            'Filtered by: ',
            style: TextStyle(
              fontSize: Responsive.h(11),
              color: const Color(0xFF1D4ED8),
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.h(7),
              vertical: Responsive.h(2),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(Responsive.h(4)),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedStatus!,
                  style: TextStyle(
                    fontSize: Responsive.h(10.5),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
                SizedBox(width: Responsive.h(4)),
                GestureDetector(
                  onTap: () => _onStatusFilterSelected('ALL'),
                  child: Icon(
                    Icons.close_rounded,
                    size: Responsive.h(12),
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _onStatusFilterSelected('ALL'),
            child: Text(
              'Clear',
              style: TextStyle(
                fontSize: Responsive.h(11),
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent(LeaveRequestState state) {
    if (state is LeaveListLoading) {
      return SkeletonCard(isLoading: true, itemCount: 5);
    }

    if (state is LeaveListError) {
      return _buildErrorState(state.message);
    }

    if (state is LeaveListLoaded) {
      if (state.leaves.isEmpty) {
        return _buildEmptyState();
      }

      final isApproverView = state.currentViewType == 'APPROVALS';
      final isMyLeaveView = state.currentViewType == 'MY_LEAVES';

      return RefreshIndicator(
        onRefresh: () async {
          context.read<LeaveRequestBloc>().add(
                FetchLeavesEvent(
                  viewType: state.currentViewType,
                  page: 0,
                  isRefresh: true,
                ),
              );
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(
            vertical: Responsive.h(6),
          ),
          itemCount: state.leaves.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.leaves.length) {
              return Padding(
                padding: EdgeInsets.all(Responsive.h(12)),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final leave = state.leaves[index];
            return LeaveCard(
              leave: leave,
              isApproverView: isApproverView,
              isMyLeaveView: isMyLeaveView,
              onEdit: () async {
                final bloc = context.read<LeaveRequestBloc>();
                final result = await context.push(
                  AppRouteName.applyLeave,
                  extra: leave,
                );
                if (result == true && mounted) {
                  bloc.add(
                    FetchLeavesEvent(
                      viewType: state.currentViewType,
                      page: 0,
                      isRefresh: true,
                    ),
                  );
                }
              },
              onCancel: isMyLeaveView
                  ? () {
                      context
                          .read<LeaveRequestBloc>()
                          .add(CancelLeaveEvent(leave.leaveRequestId));
                    }
                  : null,
              onProcess: (newStatus, remarks) {
                context.read<LeaveRequestBloc>().add(
                      ProcessLeaveEvent(
                        leaveRequestId: leave.leaveRequestId,
                        newStatus: newStatus,
                        remarks: remarks,
                      ),
                    );
              },
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(Responsive.h(28)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(Responsive.h(16)),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_rounded,
                size: Responsive.h(44),
                color: const Color(0xFF3B82F6),
              ),
            ),
            SizedBox(height: Responsive.h(14)),
            Text(
              'No Leave Requests Found',
              style: TextStyle(
                fontSize: Responsive.h(15),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              'No records match your selected view or status filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.h(12),
                color: const Color(0xFF64748B),
              ),
            ),
            if (_canCreate) ...[
              SizedBox(height: Responsive.h(16)),
              ElevatedButton.icon(
                onPressed: () async {
                  final bloc = context.read<LeaveRequestBloc>();
                  final result = await context.push(AppRouteName.applyLeave);
                  if (result == true && mounted) {
                    final currentView = _viewTypes[_tabController.index];
                    bloc.add(
                      FetchLeavesEvent(
                        viewType: currentView,
                        page: 0,
                        isRefresh: true,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Apply for Leave'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.h(16),
                    vertical: Responsive.h(9),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Responsive.h(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(Responsive.h(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: Responsive.h(42),
              color: AppColors.error,
            ),
            SizedBox(height: Responsive.h(10)),
            Text(
              'Failed to Load Leaves',
              style: TextStyle(
                fontSize: Responsive.h(14.5),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: Responsive.h(4)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Responsive.h(11.5),
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: Responsive.h(14)),
            OutlinedButton.icon(
              onPressed: () {
                final currentView = _viewTypes[_tabController.index];
                context.read<LeaveRequestBloc>().add(
                      FetchLeavesEvent(
                        viewType: currentView,
                        page: 0,
                        isRefresh: true,
                      ),
                    );
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
