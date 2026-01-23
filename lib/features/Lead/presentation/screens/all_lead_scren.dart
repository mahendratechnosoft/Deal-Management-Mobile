import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import '../../bloc/bloc.dart';
import '../widgets/all_lead_card.dart';

class AllLeadScreen extends StatefulWidget {
  const AllLeadScreen({super.key});

  @override
  State<AllLeadScreen> createState() => _AllLeadScreenState();
}

class _AllLeadScreenState extends State<AllLeadScreen> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(FetchAllLeadsEvent());

    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        context.read<LeadBloc>().add(FetchAllLeadsEvent(loadMore: true));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'All Leads'),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) {
            return SkeletonCard(isLoading: true, itemCount: 10);
          }

          if (state is AllLeadState) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeadBloc>().add(RefreshLeads());
              },
              child: ListView.builder(
                controller: _controller,
                itemCount:
                    state.hasMore ? state.leads.length + 1 : state.leads.length,
                itemBuilder: (context, index) {
                  if (index >= state.leads.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final lead = state.leads[index];
                  return PremiumLeadCard(
                    clientName: lead.clientName,
                    companyName: lead.companyName,
                    email: lead.email ?? '',
                    phone: lead.mobileNumber ?? '',
                    status: lead.status,
                    createdDate: lead.createdDate,
                    onTap: () {
                      // Navigate to lead detail
                    },
                  );
                },
              ),
            );
          }

          if (state is LeadError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
