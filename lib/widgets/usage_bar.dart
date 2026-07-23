import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A usage progress bar with label + percent.
class UsageBar extends StatelessWidget {
  const UsageBar({
    super.key,
    required this.used,
    required this.total,
    this.label,
  });

  final int used;
  final int total;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;
    final barColor = pct > 0.8
        ? AppColors.danger
        : (pct > 0.5 ? AppColors.warn : AppColors.success);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.fg,
            ),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(barColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(pct * 100).toInt()}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: '.SF Mono',
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '${_fmt(used)} / ${total <= 0 ? '∞' : _fmt(total)}',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
            fontFamily: '.SF Mono',
          ),
        ),
      ],
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}
