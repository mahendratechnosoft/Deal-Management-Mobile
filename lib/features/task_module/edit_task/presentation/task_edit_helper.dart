import '../../../../core/widgtes/custom_dropdown.dart';
import '../../create_task/bloc/create_task_state.dart';
import '../../create_task/model/assign_model.dart';

String formatDate(DateTime? date) {
  if (date == null) return '';
  return "${date.year.toString().padLeft(4, '0')}-"
      "${date.month.toString().padLeft(2, '0')}-"
      "${date.day.toString().padLeft(2, '0')}";
}

List<DropdownItem> getAssigneeItems(CreateTaskState state) {
  switch (state.relatedTo) {
    case 'Lead':
      return state.leadList
          .where((e) => e.clientName.isNotEmpty)
          .map((e) => DropdownItem(id: e.leadId, name: e.clientName))
          .toList();
    case 'Customer':
      return state.customerList
          .where((e) => e.companyName.isNotEmpty)
          .map((e) => DropdownItem(id: e.id, name: e.companyName))
          .toList();
    case 'Proforma':
      return state.proformList
          .where((e) => e.formatedProformaInvoiceNumber.isNotEmpty)
          .map((e) => DropdownItem(
              id: e.proformaInvoiceId, name: e.formatedProformaInvoiceNumber))
          .toList();
    case 'Proposal':
      return state.proposalList
          .where((e) => e.formatedProposalNumber.isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.proposalId, name: e.formatedProposalNumber))
          .toList();
    case 'Invoice':
      return state.invoiceList
          .where((e) => e.formatedInvoiceNumber.isNotEmpty)
          .map((e) =>
              DropdownItem(id: e.invoiceId, name: e.formatedInvoiceNumber))
          .toList();
    default:
      return [];
  }
}

List<DropdownItem> buildEmployeeDropdown({
  required List<AssignModel> allEmployees,
  required String excludeEmployeeId,
  required String placeholder,
}) {
  return [
    DropdownItem(id: '', name: placeholder),
    ...allEmployees.where((e) => e.employeeId != excludeEmployeeId).map(
          (e) => DropdownItem(
            id: e.employeeId,
            name: e.name,
          ),
        ),
  ];
}
