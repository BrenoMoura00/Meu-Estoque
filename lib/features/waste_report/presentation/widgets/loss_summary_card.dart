import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Card de destaque "Prejuízo estimado esse mês".
class LossSummaryCard extends StatelessWidget {
  const LossSummaryCard({
    super.key,
    required this.total,
    required this.delta,
    required this.discardedCount,
    required this.weightKg,
  });

  final double total;

  /// Diferença vs. mês passado (positivo = prejuízo maior).
  final double delta;
  final int discardedCount;
  final double weightKg;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.slate500;
    final worse = delta > 0;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.red100),
        boxShadow: [
          BoxShadow(
            color: AppColors.red500.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.rose50.withValues(alpha: 0.6)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(21),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.rose100.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const AppSvg(AppIcons.piggyLoss, width: 24, height: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PREJUÍZO ESTIMADO ESSE MÊS',
                            style: AppTextStyles.label.copyWith(letterSpacing: 0.6, color: muted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatBRL(total),
                            style: AppTextStyles.headline.copyWith(
                              fontSize: 30,
                              height: 36 / 30,
                              letterSpacing: -0.75,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: worse ? AppColors.rose50 : AppColors.emerald50,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: (worse ? AppColors.rose200 : AppColors.emerald200).withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (worse) ...[
                            const AppSvg(AppIcons.trendUp, width: 13.47, height: 14),
                            const SizedBox(width: 4),
                          ],
                          Text(
                            '${worse ? '+' : '-'}${formatBRL(delta.abs()).replaceAll(',00', '')} este mês',
                            style: AppTextStyles.label.copyWith(
                              letterSpacing: 0,
                              color: worse ? AppColors.rose700 : AppColors.emerald700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Comparado com mês passado',
                        style: AppTextStyles.body.copyWith(height: 16 / 12, color: muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, thickness: 1, color: AppColors.slate100),
                const SizedBox(height: 18),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Metric(
                          label: 'ITENS DESCARTADOS',
                          child: Row(
                            children: [
                              Flexible(child: Text('$discardedCount itens', style: _metricValue)),
                              const SizedBox(width: 6),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(color: AppColors.red400, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Metric(
                          label: 'PESO APROXIMADO',
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${weightKg.toStringAsFixed(1).replaceAll('.', ',')} kg',
                                  style: _metricValue,
                                ),
                                TextSpan(
                                  text: '  desperdiçado',
                                  style: AppTextStyles.body.copyWith(height: 16 / 12, color: muted),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _metricValue => AppTextStyles.rank.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(13, 14, 13, 13),
    decoration: BoxDecoration(
      color: AppColors.slate50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.slate100.withValues(alpha: 0.7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.tag.copyWith(fontWeight: FontWeight.w500, height: 16.5 / 11, color: AppColors.slate500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        child,
      ],
    ),
  );
}
