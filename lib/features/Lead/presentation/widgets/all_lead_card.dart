import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xpertbiz/features/auth/data/locale_data/hive_service.dart';
import 'package:xpertbiz/features/auth/data/locale_data/login_response.dart';

class PremiumLeadCard extends StatelessWidget {
  final String clientName;
  final String companyName;
  final String email;
  final String phone;
  final String status;
  final DateTime createdDate;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final VoidCallback? delete;
  final EdgeInsetsGeometry? margin;

  const PremiumLeadCard({
    super.key,
    required this.clientName,
    required this.companyName,
    required this.email,
    required this.phone,
    required this.status,
    required this.createdDate,
    this.onTap,
    this.onPressed,
    this.delete,
    this.margin,
  });

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final LoginResponse? user = AuthLocalStorage.getUser();
    final bool canDelete = user?.moduleAccess.leadDelete ?? false;
    final bool canEdit = user?.moduleAccess.leadEdit ?? true;
    final statusColor = getLeadStatusColor(status);

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 18 : 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name & Company + Status Chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: statusColor.withValues(alpha: 0.12),
                      child: Text(
                        _getInitials(clientName),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName.isEmpty ? 'Unnamed Lead' : clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                          ),
                          if (companyName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(
                                  Icons.business_rounded,
                                  size: 13,
                                  color: Color(0xFF64748B),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    companyName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: status),
                  ],
                ),

                const SizedBox(height: 12),

                // Contact Details Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    if (phone.isNotEmpty)
                      _ContactBadge(
                        icon: Icons.phone_rounded,
                        text: phone,
                      ),
                    if (email.isNotEmpty)
                      _ContactBadge(
                        icon: Icons.email_rounded,
                        text: email,
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 8),

                // Bottom Row: Date & Action Buttons
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('dd MMM yyyy').format(createdDate),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    if (canEdit && onPressed != null)
                      Material(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: onPressed,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Icon(Icons.edit_outlined,
                                size: 14, color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                    if (canDelete && delete != null) ...[
                      const SizedBox(width: 8),
                      Material(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: delete,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 14, color: Color(0xFFDC2626)),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
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
    final color = getLeadStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
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
          const SizedBox(width: 5),
          Text(
            status.isEmpty ? 'Pending' : status,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ContactBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 5),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Color getLeadStatusColor(String status) {
  final s = status.trim().toLowerCase();
  if (s.contains('new') || s.contains('created')) return const Color(0xFF2563EB); // Blue
  if (s.contains('contact')) return const Color(0xFF7C3AED); // Violet
  if (s.contains('qualif')) return const Color(0xFF059669); // Emerald
  if (s.contains('proposal')) return const Color(0xFFD97706); // Amber
  if (s.contains('negotiat')) return const Color(0xFF4F46E5); // Indigo
  if (s.contains('won') || s.contains('convert')) return const Color(0xFF16A34A); // Green
  if (s.contains('lost') || s.contains('junk') || s.contains('cancel')) return const Color(0xFFDC2626); // Red
  return const Color(0xFF64748B); // Slate
}
