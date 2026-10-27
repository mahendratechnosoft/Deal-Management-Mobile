import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/Lead/data/model/all_lead_model.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/activity_log_view.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/all_lead_card.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/details_card.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/proposal_card.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/reminders_view.dart';
import 'package:xpertbiz/features/app_route_name.dart';

class AllLeadDetailsScreen extends StatefulWidget {
  final LeadModel lead;
  const AllLeadDetailsScreen({super.key, required this.lead});

  @override
  State<AllLeadDetailsScreen> createState() => _AllLeadDetailsScreenState();
}

class _AllLeadDetailsScreenState extends State<AllLeadDetailsScreen> {
  String selectedTab = 'Profile';

  static const List<Map<String, dynamic>> _tabItems = [
    {'title': 'Profile', 'icon': Icons.person_outline_rounded},
    {'title': 'Proposal', 'icon': Icons.description_outlined},
    {'title': 'Activity Log', 'icon': Icons.history_rounded},
    {'title': 'Reminders', 'icon': Icons.alarm_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LeadBloc>().add(LeadDetailsEvent(leadId: widget.lead.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        final leadDetails =
            state is AllLeadState ? state.leadDetailsModel : null;
        final clientName =
            (leadDetails?.lead.clientName.trim().isNotEmpty == true)
                ? leadDetails!.lead.clientName.trim()
                : (widget.lead.clientName?.trim() ?? '');
        final leadId = (leadDetails?.lead.id.isNotEmpty == true)
            ? leadDetails!.lead.id
            : widget.lead.id;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: CommonAppBar(
            title: clientName.isNotEmpty ? '$clientName Details' : 'Lead Details',
            actions: [
              IconButton(
                tooltip: 'Edit Lead',
                icon: const Icon(Icons.edit_outlined, color: Colors.white),
                onPressed: () async {
                  final result = await context.push(
                    AppRouteName.createLead,
                    extra: leadDetails?.lead ?? widget.lead,
                  );
                  if (result == true && context.mounted) {
                    context.read<LeadBloc>().add(
                          LeadDetailsEvent(leadId: leadId),
                        );
                  }
                },
              ),
            ],
          ),
          body: _buildContent(context, state),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, LeadState state) {
    if (state is LeadLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    if (state is LeadError) {
      return _buildError(state);
    }

    if (state is! AllLeadState) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    if (state.leadDetailsLoader) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      );
    }

    final leadDetails = state.leadDetailsModel;
    if (leadDetails == null) {
      return _buildEmpty(context, state);
    }

    return Column(
      children: [
        // 1. Top Profile Summary Banner
        _buildProfileHeader(leadDetails.lead),

        // 2. Segmented Pill Tab Bar
        _buildSegmentedTabBar(context),

        const SizedBox(height: 10),

        // 3. Tab Content View
        Expanded(
          child: _buildSelectedView(state),
        ),
      ],
    );
  }

  /// 🌟 Top Profile Banner Card
  Widget _buildProfileHeader(LeadDetails lead) {
    final statusColor = getLeadStatusColor(lead.status);
    final initials = lead.clientName.trim().isNotEmpty
        ? lead.clientName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lead.clientName.isEmpty ? 'Unnamed Client' : lead.clientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (lead.companyName.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lead.companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  lead.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔘 Horizontal Segmented Pill Tab Bar (Scrollable to prevent RenderFlex overflow)
  Widget _buildSegmentedTabBar(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        itemCount: _tabItems.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = _tabItems[index];
          final String title = tab['title'];
          final IconData icon = tab['icon'];
          final bool isSelected = selectedTab == title;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (selectedTab == title) return;
                setState(() => selectedTab = title);
                _onTabChanged(context, title);
              },
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFCBD5E1),
                    width: 1.1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB)
                                .withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 15,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedView(AllLeadState state) {
    switch (selectedTab) {
      case 'Profile':
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: LeadDetailsCard(
            leadDetails: state.leadDetailsModel!,
          ),
        );

      case 'Proposal':
        return const ProposalView();

      case 'Activity Log':
        return const ActivityLogView();

      case 'Reminders':
        return RemindersView(
          reminders: state.remindermodel ?? [],
          isLoading: state.reminder ?? false,
          lead: state.leadDetailsModel!,
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildError(LeadError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 54, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<LeadBloc>().add(
                      LeadDetailsEvent(leadId: widget.lead.id),
                    );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AllLeadState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 54, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No lead details found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _refreshLead(context, state),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _refreshLead(BuildContext context, AllLeadState state) {
    final leadId = state.leadDetailsModel?.lead.id ?? widget.lead.id;
    context.read<LeadBloc>().add(
          LeadDetailsEvent(leadId: leadId),
        );
  }

  void _onTabChanged(BuildContext context, String tab) {
    final state = context.read<LeadBloc>().state;

    if (tab == 'Activity Log') {
      if (state is AllLeadState && state.leadDetailsModel != null) {
        context.read<LeadBloc>().add(
              FetchLeadActivityEvent(
                state.leadDetailsModel!.lead.id,
              ),
            );
      }
    } else if (tab == 'Reminders') {
      log('Fetching reminders for tab: $tab');
      if (state is AllLeadState && state.leadDetailsModel != null) {
        context.read<LeadBloc>().add(
              FetchReminderEvent(
                state.leadDetailsModel!.lead.id,
              ),
            );
      }
    }
  }
}
