import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';
import 'package:xpertbiz/core/widgtes/app_appbar.dart';
import 'package:xpertbiz/core/widgtes/app_text_field.dart';
import 'package:xpertbiz/core/widgtes/custom_card.dart';
import 'package:xpertbiz/core/widgtes/skeleton_widget.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';
import 'package:xpertbiz/features/customers/bloc/customer_bloc.dart';
import 'package:xpertbiz/features/customers/bloc/customer_event.dart';
import 'package:xpertbiz/features/customers/bloc/customer_state.dart';
import 'package:xpertbiz/features/customers/create_customer/screen/create_customer_screen.dart';
import 'package:xpertbiz/features/customers/presentation/contact_screen.dart';

import '../../auth/data/locale_data/hive_service.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool? isCredit;
  LoginResponse? user;

  static const int _pageSize = 10;
  Timer? _debounce;

  late CustomerBloc customerBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    customerBloc = context.read<CustomerBloc>();
  }

  @override
  void initState() {
    user = AuthLocalStorage.getUser();
    isCredit = user?.moduleAccess.customerCreate;

    super.initState();
    context.read<CustomerBloc>().add(
          const FetchCustomersEvent(
            page: 0,
            size: _pageSize,
          ),
        );

    _scrollController.addListener(_onScroll);
  }

  /// Pagination trigger
  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.extentAfter < 300) {
      context.read<CustomerBloc>().add(
            const LoadMoreCustomersEvent(size: _pageSize),
          );
    }
  }

  /// 🔍 Debounced search
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        context.read<CustomerBloc>().add(
              SearchCustomersEvent(value),
            );
      },
    );
  }

  /// 🔄 Pull to refresh
  Future<void> _onRefresh() async {
    context.read<CustomerBloc>().add(
          RefreshCustomersEvent(),
        );
  }

  @override
  void dispose() {
    customerBloc.add(ClearCustomerSearchEvent());
    _debounce?.cancel();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CommonAppBar(title: 'Customers'),
      floatingActionButton: isCredit == false
          ? SizedBox.shrink()
          : FloatingActionButton(
              backgroundColor: AppColors.primaryDark,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CreateCustomerScreen(edit: false)));
              },
              child: Icon(Icons.add, color: AppColors.background),
            ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: AppTextField(
              prefixIcon: const Icon(Icons.factory),
              hint: 'Search customers...',
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              buildWhen: (previous, current) {
                // Prevent rebuilds on typing
                return current is CustomerLoading ||
                    current is CustomerLoaded ||
                    current is CustomerError;
              },
              builder: (context, state) {
                /// Loading (initial/search)
                if (state is CustomerLoading) {
                  return const Center(
                    child: SkeletonCard(isLoading: true),
                  );
                }

                /// Error
                if (state is CustomerError) {
                  return Center(
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                /// Loaded
                if (state is CustomerLoaded) {
                  if (state.customers.isEmpty) {
                    return const Center(
                      child: Text(
                        'No customers found',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount:
                          state.customers.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        /// Bottom pagination loader
                        if (index >= state.customers.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final customer = state.customers[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PremiumInfoCard(
                            headerTitle: customer.companyName,
                            headerSubtitle: customer.industry,
                            onTap: () {},
                            editAction: CardActionConfig(
                              icon: Icons.edit_outlined,
                              color: AppColors.primaryDark,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CreateCustomerScreen(
                                              edit: true,
                                              id: customer.customerId,
                                            )));
                              },
                            ),
                            deleteAction: CardActionConfig(
                              icon: Icons.contact_phone_outlined,
                              color: AppColors.primaryDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ContactScreen(
                                      customerId: customer.customerId,
                                    ),
                                  ),
                                );
                              },
                            ),
                            items: [
                              InfoItem(
                                label: "Mobile",
                                value: customer.mobile,
                                icon: Icons.phone,
                              ),
                              if (customer.website != null)
                                InfoItem(
                                  label: "Website",
                                  value: customer.website!,
                                  icon: Icons.link,
                                ),
                              if (customer.revenue != null)
                                InfoItem(
                                  label: "Revenue",
                                  value: customer.revenue!,
                                  icon: Icons.currency_rupee,
                                ),
                              if (customer.description != null)
                                InfoItem(
                                  label: "Description",
                                  value: customer.description!,
                                  icon: Icons.description_outlined,
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
