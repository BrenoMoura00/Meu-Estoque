import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/waste_mock_data.dart';

/// "Motivos do Descarte": barra segmentada + legenda com % e valor.
class WasteReasonsCard extends StatelessWidget {
  const WasteReasonsCard({super.key, required this.byReason, required this.periodLabel});

  final Map<WasteReason, double> byReason;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final total = byReason.values.fold<double>(0, (sum, v) => sum + v);
    final entries = [
      for (final r in WasteReason.values)
        if ((byReason[r] ?? 0) > 0) (r, byReason[r]!),
    ];

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Motivos do Descarte',
                  style: AppTextStyles.bodyStrong.copyWith(letterSpacing: -0.35, color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                periodLabel,
                style: AppTextStyles.bodyMedium.copyWith(height: 16 / 12, color: AppColors.slate500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 12,
              child: total <= 0
                  ? const ColoredBox(color: AppColors.slate100)
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (reason, value) in entries)
                          Expanded(
                            flex: (value / total * 1000).round(),
                            child: ColoredBox(color: reason.color),
                          ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (reason, value) in entries)
                Expanded(
                  child: _Legend(reason: reason, value: value, percent: total == 0 ? 0 : value / total),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.reason, required this.value, required this.percent});

  final WasteReason reason;
  final double value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: reason.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                reason.label,
                style: AppTextStyles.bodyMedium.copyWith(height: 16 / 12, color: AppColors.slate600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${(percent * 100).round()}% ',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                    color: AppColors.ink,
                  ),
                ),
                TextSpan(
                  text: '(${formatBRL(value)})',
                  style: AppTextStyles.micro.copyWith(height: 16 / 10, color: AppColors.slate500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
