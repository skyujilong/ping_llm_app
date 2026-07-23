import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dashboard stat card — value + label + optional sub.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
    this.valueStyle,
  });

  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.02,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
                valueStyle ??
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: '.SF Pro Display',
                  letterSpacing: -0.02,
                  color: valueColor ?? AppColors.fg,
                ),
          ),
          if (sub != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                sub!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  fontFamily: '.SF Mono',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
