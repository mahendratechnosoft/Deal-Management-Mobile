import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/Lead/bloc/bloc.dart';
import 'package:xpertbiz/features/Lead/bloc/event.dart';
import 'package:xpertbiz/features/Lead/bloc/state.dart';
import 'package:xpertbiz/features/app_route_name.dart';
import 'package:xpertbiz/features/drawer/presentation/custom_drawer.dart';

class LeadScreen extends StatefulWidget {
  const LeadScreen({super.key});

  @override
  State<LeadScreen> createState() => _LeadScreenState();
}

class _LeadScreenState extends State<LeadScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeadBloc>().add(const FetchLeadStatus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if we're coming back to this screen
    if (ModalRoute.of(context)!.isCurrent) {
      context.read<LeadBloc>().add(const FetchLeadStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      drawer: const CustomDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: CommonAppBar(title: 'Leads'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: () async {
          context.push(AppRouteName.createLead);
        },
        child: const Icon(Icons.add, color: AppColors.background),
      ),
      body: BlocBuilder<LeadBloc, LeadState>(
        builder: (context, state) {
          if (state is LeadLoading) {
            return SkeletonCard(isLoading: true, itemCount: 6);
          }

          if (state is LeadError) {
            return Center(child: Text(state.message));
          }

          if (state is LeadLoaded) {
            final totalLeads =
                state.leads.fold<int>(0, (sum, e) => sum + e.count);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeadBloc>().add(const FetchLeadStatus());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                        onTap: () => context.push(AppRouteName.allLead),
                        child: _TotalLeadCard(total: totalLeads)),
                    const SizedBox(height: 20),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.leads.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isTablet ? 3 : 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.4,
                      ),
                      itemBuilder: (_, index) {
                        final item = state.leads[index];
                        return _LeadStatusCard(
                          title: item.status,
                          count: item.count,
                          color: _statusColor(item.status),
                          onTap: () {
                            context.push(
                              '${AppRouteName.allLead}?status=${Uri.encodeComponent(item.status)}',
                            );
                          },
                        );
                      },
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
}

Color _statusColor(String status) {
  switch (status) {
    case 'New Lead':
      return Colors.blue;
    case 'Contacted':
      return Colors.purple;
    case 'Qualified':
      return Colors.green;
    case 'Proposal':
      return Colors.amber;
    case 'Negotiation':
      return Colors.orange;
    case 'Converted':
      return Colors.teal;
    case 'Won':
      return Colors.greenAccent;
    case 'Lost':
      return Colors.redAccent;
    default:
      return Colors.grey;
  }
}

class _TotalLeadCard extends StatelessWidget {
  final int total;

  const _TotalLeadCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.groups,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Leads',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$total',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeadStatusCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const _LeadStatusCard({
    required this.title,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.trending_up,
                  color: color,
                  size: 15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
