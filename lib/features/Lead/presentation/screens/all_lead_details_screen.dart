import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/custom_dropdown.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';

import '../../bloc/bloc.dart';
import '../../bloc/state.dart';
import '../../data/model/all_lead_model.dart';
import '../widgets/activity_log_view.dart';
import '../widgets/details_card.dart';
import '../widgets/proposal_card.dart';
import '../widgets/reminders_view.dart';

class AllLeadDetailsScreen extends StatefulWidget {
  final AllLeadModel lead;
  const AllLeadDetailsScreen({super.key, required this.lead});

  @override
  State<AllLeadDetailsScreen> createState() => _AllLeadDetailsScreenState();
}

class _AllLeadDetailsScreenState extends State<AllLeadDetailsScreen> {
  String selectedTab = 'Profile';

  static const List<String> _tabs = [
    'Profile',
    'Proposal',
    'Activity Log',
    'Reminders',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadBloc, LeadState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: CommonAppBar(
            title: state is AllLeadState && state.leadDetailsModel != null
                ? '${state.leadDetailsModel!.lead.status} Details'
                : 'Lead Details',
          ),
          body: _buildContent(context, state),
        );
      },
    );
  }

  // ================= MAIN CONTENT =================

  Widget _buildContent(BuildContext context, LeadState state) {
    if (state is LeadLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LeadError) {
      return _buildError(state);
    }

    if (state is! AllLeadState) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.leadDetailsLoader) {
      return const Center(child: CircularProgressIndicator());
    }

    final leadDetails = state.leadDetailsModel;
    if (leadDetails == null) {
      return _buildEmpty(context, state);
    }

    return Column(
      children: [
        const SizedBox(height: 16),
        _buildTabSelector(context),
        const SizedBox(height: 16),
        Expanded(
          child: _buildSelectedView(state),
        ),
      ],
    );
  }

  // ================= TAB SELECTOR =================

  Widget _buildTabSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: CustomDropdown<String>(
        items: _tabs,
        value: selectedTab,
        showLabel: false,
        onChanged: (value) {
          if (value == null) return;
          setState(() => selectedTab = value);
          _onTabChanged(context, value);
        },
        itemLabel: (item) => item,
      ),
    );
  }

  // ================= TAB CONTENT =================

  Widget _buildSelectedView(AllLeadState state) {
    switch (selectedTab) {
      case 'Profile':
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
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

  // ================= HELPERS =================

  Widget _buildError(LeadError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
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
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No lead details found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
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
    final leadId = state.leadDetailsModel?.lead.id;
    if (leadId != null) {
      context.read<LeadBloc>().add(
            LeadDetailsEvent(leadId: leadId),
          );
    }
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
    } else if ((tab == 'Reminders')) {
      log('Ganesh : $tab');

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
