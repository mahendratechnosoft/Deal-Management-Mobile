import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/custom_card.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/customers/bloc/customer_bloc.dart';
import 'package:xpertbiz/features/customers/bloc/customer_event.dart';
import 'package:xpertbiz/features/customers/bloc/customer_state.dart';
import 'package:xpertbiz/features/customers/presentation/Compliance_screen.dart';

class ContactScreen extends StatefulWidget {
  final String customerId;

  const ContactScreen({
    super.key,
    required this.customerId,
  });

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  @override
  void initState() {
    super.initState();

    /// Fetch contacts for customer
    context.read<CustomerBloc>().add(
          ContactLoadEvent(id: widget.customerId),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryDark,
        onPressed: () {},
        child: Icon(Icons.add, color: AppColors.background),
      ),
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Contacts'),
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          /// 🔹 Loading
          if (state is ContactLoadingState) {
            return const Center(
              child: SkeletonCard(isLoading: true),
            );
          }

          /// 🔹 Error
          if (state is ContactError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          /// 🔹 Loaded
          if (state is ContactLoaded) {
            if (state.contacts.isEmpty) {
              return const Center(
                child: Text(
                  'No contacts found',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.contacts.length,
              itemBuilder: (context, index) {
                final contact = state.contacts[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: PremiumInfoCard(
                    headerTitle: contact.name,
                    headerSubtitle: contact.position ?? '—',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplianceScreen(),
                        ),
                      );
                    },
                    editAction: CardActionConfig(
                      icon: Icons.edit_outlined,
                      color: AppColors.primaryDark,
                      onTap: () {
                        // TODO: Edit contact
                      },
                    ),
                    deleteAction: CardActionConfig(
                      icon: Icons.delete_outline,
                      color: Colors.redAccent,
                      onTap: () {
                        // TODO: Delete contact
                      },
                    ),
                    items: [
                      if (contact.phone != null)
                        InfoItem(
                          label: "Mobile",
                          value: contact.phone!,
                          icon: Icons.phone,
                        ),
                      if (contact.email != null)
                        InfoItem(
                          label: "Email",
                          value: contact.email!,
                          icon: Icons.email_outlined,
                        ),
                    ],
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
