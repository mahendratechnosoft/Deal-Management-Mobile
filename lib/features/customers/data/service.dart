import 'package:dio/dio.dart';
import 'package:xpertbiz/core/constants/api_constants.dart';
import 'package:xpertbiz/features/customers/create_customer/bloc/model/update_customer_model.dart';

import '../create_customer/bloc/model/customer_payload_model.dart';

class CustomerService {
  final Dio dio;

  CustomerService(this.dio);

  Future<Response> getCustomers({
    required int page,
    required int size,
    String? search,
  }) {
    return dio.get(
      "${ApiConstants.allCustomerUrl}/$page/$size",
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
      },
    );
  }

  Future<Response> getContacts({String? taskId}) {
    return dio.get("${ApiConstants.getContactsUrl}/$taskId");
  }

  Future<Response> createCustomer(CustomerModel customer) {
    return dio.post(data: customer.toJson(), ApiConstants.createCustomerUrl);
  }

  Future<Response> updateCustomer(UpdateCustomerRequest customer) {
    return dio.put(data: customer.toJson(), ApiConstants.updateCustomerUrl);
  }

  Future<Response> getCustomerDetails(String id) {
    return dio.get("${ApiConstants.getCustomerDetailsUrl}/$id");
  }
}
