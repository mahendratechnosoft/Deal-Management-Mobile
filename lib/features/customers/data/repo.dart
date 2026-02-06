import 'package:xpertbiz/features/customers/create_customer/bloc/model/customer_payload_model.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/model/update_customer_model.dart';
import 'package:xpertbiz/features/customers/data/model/customer_list_model.dart';
import '../create_customer/bloc/model/create_customer_model.dart';
import 'model/customer_contect_model.dart';

import 'model/get_customer_details_model.dart';
import 'service.dart';

class CustomerRepository {
  final CustomerService apiService;
  CustomerRepository(this.apiService);

  Future<CustomerListModel> getCustomers({
    required int page,
    required int size,
    String? search,
  }) async {
    final response = await apiService.getCustomers(
      page: page,
      size: size,
      search: search,
    );
    return CustomerListModel.fromJson(response.data);
  }
  //

  Future<List<CustomerContactModel>> getContacts({
    String? taskId,
  }) async {
    final response = await apiService.getContacts(taskId: taskId);
    return customerContactListFromJson(response.data);
  }

  Future<CreateCustomerModel> cretaeCustomer(CustomerModel customer) async {
    final response = await apiService.createCustomer(customer);
    return CreateCustomerModel.fromJson(response.data);
  }

  Future<CreateCustomerModel> updateCustomer(UpdateCustomerRequest customer) async {
    final response = await apiService.updateCustomer(customer);
    return CreateCustomerModel.fromJson(response.data);
  }

  Future<GetCustomerDetailsModel> getCustomerDetails(String id) async {
    final response = await apiService.getCustomerDetails(id);
    return GetCustomerDetailsModel.fromJson(response.data);
  }
}
