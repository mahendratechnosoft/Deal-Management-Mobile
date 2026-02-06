import 'package:flutter/material.dart';
import 'package:xpertbiz/core/utils/app_colors.dart';

/// --------------------------------------------
/// Info Item Model
/// --------------------------------------------
class InfoItem {
  final String label;
  final String value;
  final IconData? icon;

  const InfoItem({
    required this.label,
    required this.value,
    this.icon,
  });
}

/// --------------------------------------------
/// Action Config (Edit / Delete / Any Action)
/// --------------------------------------------
class CardActionConfig {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const CardActionConfig({
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// --------------------------------------------
/// Premium Info Card
/// --------------------------------------------
class PremiumInfoCard extends StatelessWidget {
  final List? items;

  final String? headerTitle;
  final String? headerSubtitle;

  final VoidCallback? onTap;

  /// Custom actions
  final CardActionConfig? editAction;
  final CardActionConfig? deleteAction;

  final double? borderRadius;
  final double? elevation;

  const PremiumInfoCard({
    super.key,
    this.items,
    this.headerTitle,
    this.headerSubtitle,
    this.onTap,
    this.editAction,
    this.deleteAction,
    this.borderRadius,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final safeItems = items ?? const [];

    return Material(
      elevation: elevation ?? 1,
      borderRadius: BorderRadius.circular(borderRadius ?? 8),
      color: AppColors.card,
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(borderRadius ?? 8),
                  bottomLeft: Radius.circular(borderRadius ?? 18),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Header(
                      title: headerTitle,
                      subtitle: headerSubtitle,
                      editAction: editAction,
                      deleteAction: deleteAction,
                    ),
                    if (safeItems.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ...safeItems.map(
                        (item) => _InfoRow(item: item),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// --------------------------------------------
/// Header Section
/// --------------------------------------------
class _Header extends StatelessWidget {
  final String? title;
  final String? subtitle;

  final CardActionConfig? editAction;
  final CardActionConfig? deleteAction;

  const _Header({
    this.title,
    this.subtitle,
    this.editAction,
    this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (subtitle != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (editAction != null)
          IconButton(
            icon: Icon(editAction!.icon, color: editAction!.color, size: 20),
            onPressed: editAction!.onTap,
          ),
        if (deleteAction != null)
          IconButton(
            icon:
                Icon(deleteAction!.icon, color: deleteAction!.color, size: 20),
            onPressed: deleteAction!.onTap,
          ),
      ],
    );
  }
}

/// --------------------------------------------
/// Info Row
/// --------------------------------------------
class _InfoRow extends StatelessWidget {
  final InfoItem item;

  const _InfoRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(
                item.icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
          Expanded(
            flex: 4,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              item.value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
