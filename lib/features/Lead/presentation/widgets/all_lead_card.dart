import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';

class PremiumLeadCard extends StatelessWidget {
  final String clientName;
  final String companyName;
  final String email;
  final String phone;
  final String status;
  final DateTime createdDate;
  final VoidCallback? onTap;

  const PremiumLeadCard({
    super.key,
    required this.clientName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdDate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final statusColor = _statusColor(status);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: _statusColor(status)),
              color: AppColors.card,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 22 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              clientName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: .2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _StatusChip(status: status),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// ───────── CONTACT INFO ─────────
                  _InfoItem(
                    icon: Icons.email_outlined,
                    text: email.isEmpty ? 'Not available' : email,
                  ),
                  const SizedBox(height: 10),
                  _InfoItem(
                    icon: Icons.phone_outlined,
                    text: phone.isEmpty ? 'Not available' : phone,
                  ),
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade200),
                  const SizedBox(height: 10),

                  /// ───────── FOOTER ─────────
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('dd MMM yyyy').format(createdDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: statusColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
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
