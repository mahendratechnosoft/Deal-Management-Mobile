import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/model/lead_details_model.dart';

class LeadDetailsCard extends StatelessWidget {
  final LeadDetailsModel leadDetails;
  const LeadDetailsCard({super.key, required this.leadDetails});

  @override
  Widget build(BuildContext context) {
    final lead = leadDetails.lead;

    return Column(
      children: [
        _sectionCard(
          title: 'Basic Information',
          children: [
            _row(
              _info('Client Name', lead.clientName),
              _info('Company', lead.companyName),
            ),
            _row(
              _info('Status', lead.status, color: _getStatusColor(lead.status)),
              _info('Source', lead.source),
            ),
          ],
        ),
        _sectionCard(
          title: 'Contact Information',
          children: [
            _row(
              _info('Email', lead.email),
              _info('Mobile', lead.mobileNumber),
            ),
            _row(
              _info('Phone', lead.phoneNumber),
              _info('Website', lead.website),
            ),
          ],
        ),
        _sectionCard(
          title: 'Address Information',
          children: [
            _row(
              _info('Street', lead.street),
              _info('City', lead.city),
            ),
            _row(
              _info('State', lead.state),
              _info('Country', lead.country),
            ),
            _row(
              _info('Zip Code', lead.zipCode),
              _info('Industry', lead.industry),
            ),
          ],
        ),
        _sectionCard(
          title: 'System Information',
          children: [
            _row(
              _info('Priority', lead.priority ?? 'Not set'),
              _info('Revenue', '\$${lead.revenue.toStringAsFixed(2)}'),
            ),
            _row(
              _info('Converted', lead.converted ? 'Yes' : 'No',
                  color: lead.converted ? Colors.green : Colors.red),
              _info('Created Date', _formatDate(lead.createdDate)),
            ),
            _row(
              _info('Updated Date', _formatDate(lead.updatedDate)),
              lead.followUp != null
                  ? _info('Follow Up', _formatDate(lead.followUp!))
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        if (lead.description.isNotEmpty)
          _sectionCard(
            title: 'Description',
            children: [
              Text(
                lead.description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// ================== SECTION CARD ==================

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// ================== HELPERS ==================

  Widget _row(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(child: left),
          const SizedBox(width: 12),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _info(String label, String value, {Color? color}) {
    return _InfoItem(
      label: label,
      value: value.isNotEmpty ? value : 'Not provided',
      valueColor: color,
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not available';

    try {
      final parsedDate =
          date is DateTime ? date : DateTime.parse(date.toString());

      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new lead':
        return Colors.blue;
      case 'contacted':
        return Colors.purple;
      case 'qualified':
        return Colors.green;
      case 'proposal':
        return Colors.amber;
      case 'negotiation':
        return Colors.orange;
      case 'converted':
        return Colors.teal;
      case 'won':
        return Colors.greenAccent;
      case 'lost':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }
}

/// ================= INFO ITEM =================

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// ================= DECORATION =================

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade300),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.shade200,
        blurRadius: 6,
        offset: const Offset(0, 3),
      ),
    ],
  );
}
