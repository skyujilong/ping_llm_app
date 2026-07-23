import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../theme/app_theme.dart';

/// A single provider row in lists.
class ProviderTile extends StatelessWidget {
  const ProviderTile({
    super.key,
    required this.provider,
    this.onPing,
    this.onEdit,
    this.onDelete,
  });

  final ProviderModel provider;
  final VoidCallback? onPing;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = Color(provider.type.color);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                provider.type.icon,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.effectiveName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  provider.effectiveModel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    fontFamily: '.SF Mono',
                  ),
                ),
              ],
            ),
          ),
          if (onPing != null)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _StatusPill(
                online: provider.online,
                latencyMs: provider.latencyMs,
              ),
            ),
          if (onEdit != null)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.muted,
              ),
              onPressed: onEdit,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: AppColors.danger),
              onPressed: onDelete,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.online, this.latencyMs});
  final bool online;
  final int? latencyMs;

  @override
  Widget build(BuildContext context) {
    final color = online ? AppColors.success : AppColors.danger;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            online ? '在线' : '离线',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          if (latencyMs != null) ...[
            const SizedBox(width: 4),
            Text(
              '${latencyMs}ms',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.muted,
                fontFamily: '.SF Mono',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
