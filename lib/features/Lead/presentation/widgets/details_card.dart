import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/features/Lead/data/model/lead_details_model.dart';
import 'package:xpertbiz/features/Lead/presentation/widgets/all_lead_card.dart';

class LeadDetailsCard extends StatelessWidget {
  final LeadDetailsModel leadDetails;
  const LeadDetailsCard({super.key, required this.leadDetails});

  @override
  Widget build(BuildContext context) {
    final lead = leadDetails.lead;

    return Column(
      children: [
        // 1. Basic Information Card
        _SectionCard(
          icon: Icons.person_outline_rounded,
          iconColor: const Color(0xFF2563EB),
          title: 'Basic Information',
          children: [
            _row(
              _info('Client Name', lead.clientName),
              _info('Company', lead.companyName),
            ),
            _row(
              _info('Status', lead.status,
                  color: getLeadStatusColor(lead.status)),
              _info('Lead Source', lead.source),
            ),
          ],
        ),

        // 2. Contact Information Card
        _SectionCard(
          icon: Icons.contact_phone_outlined,
          iconColor: const Color(0xFF7C3AED),
          title: 'Contact Information',
          children: [
            _row(
              _info('Email Address', lead.email),
              _info('Mobile Number', lead.mobileNumber),
            ),
            _row(
              _info('Phone Number', lead.phoneNumber),
              _info('Website', lead.website),
            ),
          ],
        ),

        // 3. Address Information Card
        _SectionCard(
          icon: Icons.location_on_outlined,
          iconColor: const Color(0xFF059669),
          title: 'Location & Industry',
          children: [
            _row(
              _info('Street Address', lead.street),
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

        // 4. System & Pipeline Details Card
        _SectionCard(
          icon: Icons.insights_rounded,
          iconColor: const Color(0xFFD97706),
          title: 'Pipeline Tracking',
          children: [
            _row(
              _info('Priority', lead.priority ?? 'Not set'),
              _info('Estimated Revenue', '\$${lead.revenue.toStringAsFixed(2)}'),
            ),
            _row(
              _info('Converted to Client', lead.converted ? 'Yes' : 'No',
                  color: lead.converted
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626)),
              _info('Created Date', _formatDate(lead.createdDate)),
            ),
            _row(
              _info('Last Updated', _formatDate(lead.updatedDate)),
              lead.followUp != null
                  ? _info('Follow Up Date', _formatDate(lead.followUp!))
                  : const SizedBox.shrink(),
            ),
          ],
        ),

        // 5. Description Card
        if (lead.description.isNotEmpty)
          _SectionCard(
            icon: Icons.notes_rounded,
            iconColor: const Color(0xFF475569),
            title: 'Description & Notes',
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  lead.description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _row(Widget left, Widget right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

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
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF64748B),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
