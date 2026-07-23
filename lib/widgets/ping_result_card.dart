import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ping_result.dart';
import '../theme/app_theme.dart';

/// Displays a single ping result.
class PingResultCard extends StatelessWidget {
  const PingResultCard({super.key, required this.result});

  final PingResult result;

  @override
  Widget build(BuildContext context) {
    final statusColor = result.success ? AppColors.success : AppColors.danger;
    final ts = result.timestamp ?? DateTime.now();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StatusPillSmall(success: result.success),
                    const SizedBox(width: 8),
                    if (result.latencyMs != null)
                      Text(
                        '${result.latencyMs}ms',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          fontFamily: '.SF Mono',
                          color: statusColor,
                        ),
                      ),
                  ],
                ),
                Text(
                  DateFormat('HH:mm:ss').format(ts),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    fontFamily: '.SF Mono',
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Text(
                result.errorMessage ?? result.responseBody ?? '等待响应…',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: '.SF Mono',
                  color: AppColors.muted,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPillSmall extends StatelessWidget {
  const _StatusPillSmall({required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) {
    final color = success ? AppColors.success : AppColors.danger;
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
            success ? '成功' : '失败',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
