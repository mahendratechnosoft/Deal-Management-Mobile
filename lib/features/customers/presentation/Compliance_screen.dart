import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_card.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/customers/bloc/customer_bloc.dart';
import 'package:xpertbiz/features/customers/bloc/customer_state.dart';

class ComplianceScreen extends StatefulWidget {
  const ComplianceScreen({super.key});
  @override
  State<ComplianceScreen> createState() => _ComplianceScreenState();
}

class _ComplianceScreenState extends State<ComplianceScreen> {
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Compliance'),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is ContactLoadingState) {
            return const Center(
              child: SkeletonCard(isLoading: true),
            );
          }
          if (state is ContactError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          if (state is ContactLoaded) {
            if (state.contacts.isEmpty) {
              return const Center(
                child: Text(
                  'No contacts found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  AppTextField(hint: 'search...', controller: controller),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 15),
                      itemCount: state.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = state.contacts[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PremiumInfoCard(
                            headerTitle: 'Aditya Lohar',
                            headerSubtitle: 'Unverified',
                            onTap: () {},
                            items: [
                              if (contact.phone != null)
                                InfoItem(
                                  label: "Joining Date",
                                  value: 'Nov 5,2025',
                                  icon: Icons.access_time,
                                ),
                              if (contact.email != null)
                                InfoItem(
                                  label: "Gender",
                                  value: 'Male',
                                  icon: Icons.male,
                                ),
                              InfoItem(
                                label: "Created Date",
                                value: 'Dec 25',
                                icon: Icons.date_range,
                              ),
                              InfoItem(
                                label: "Customer",
                                value: 'N/A',
                                icon: Icons.date_range,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
