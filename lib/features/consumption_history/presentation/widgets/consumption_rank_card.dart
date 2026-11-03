import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/progress_track.dart';
import '../../data/consumption_mock_data.dart';

/// Card de uma posição do ranking de consumo.
class ConsumptionRankCard extends StatelessWidget {
  const ConsumptionRankCard({super.key, required this.rank, required this.entry, required this.frequency});

  /// Posição (1 = mais consumido).
  final int rank;
  final ConsumptionEntry entry;

  /// Frequência relativa ao 1º colocado (0..1).
  final double frequency;

  /// Top 1 em verde forte; top 3 em destaque; demais mais discretos.
  Color get _rankColor => switch (rank) {
    1 => AppColors.emerald600,
    <= 3 => AppColors.slate700,
    _ => AppColors.slate500,
  };

  /// As barras vão clareando conforme a posição cai.
  Color get _barColor {
    if (rank == 1) return AppColors.emerald600;
    if (rank <= 3) return AppColors.emerald500;
    return AppColors.emerald500.withValues(alpha: (1 - 0.1 * (rank - 2)).clamp(0.5, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    final tone = entry.tone;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.emerald600.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 3, offset: const Offset(0, 1)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: AppTextStyles.rank.copyWith(
                color: _rankColor,
                fontWeight: rank <= 3 ? FontWeight.w800 : FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tone.border),
            ),
            child: Text(entry.emoji, style: AppTextStyles.number.copyWith(height: 1.4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.name,
                        style: AppTextStyles.bodyStrong.copyWith(letterSpacing: 0, color: AppColors.ink),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '~${formatBRL(entry.totalValue)}',
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: tone.tagBackground, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          entry.category,
                          style: AppTextStyles.micro.copyWith(
                            fontWeight: FontWeight.w500,
                            height: 15 / 10,
                            color: tone.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        entry.amountLabel,
                        style: AppTextStyles.tag.copyWith(height: 16.5 / 11, color: AppColors.slate500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ProgressTrack(value: frequency, color: _barColor, trackColor: AppColors.slate100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
