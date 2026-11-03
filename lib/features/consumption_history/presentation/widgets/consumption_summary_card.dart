import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Card verde "Consumo geral" + aproveitamento.
class ConsumptionSummaryCard extends StatelessWidget {
  const ConsumptionSummaryCard({super.key, required this.totalItems, required this.efficiencyPercent});

  final int totalItems;
  final int efficiencyPercent;

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.emerald100;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment(-0.3, -1),
          end: Alignment(0.3, 1),
          colors: [AppColors.emerald600, AppColors.emerald700],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Brilho decorativo no canto inferior direito.
          Positioned(
            right: -24,
            bottom: -24,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.emerald400.withValues(alpha: 0.2)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONSUMO GERAL',
                        style: AppTextStyles.label.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                          color: soft,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$totalItems itens',
                        style: AppTextStyles.headline.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'concluídos na despensa',
                        style: AppTextStyles.body.copyWith(height: 16 / 12, color: soft.withValues(alpha: 0.9)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  color: AppColors.emerald500.withValues(alpha: 0.4),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.emerald500.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '✓ Alta Eficiência',
                          style: AppTextStyles.caption.copyWith(letterSpacing: 0, height: 16.5 / 11, color: soft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$efficiencyPercent%',
                        style: AppTextStyles.number.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'aproveitamento total',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.tag.copyWith(color: soft.withValues(alpha: 0.8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
}
