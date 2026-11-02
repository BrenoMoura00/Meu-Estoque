import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Barra flutuante escura "Patrimônio despensa".
class StockSummaryBar extends StatelessWidget {
  const StockSummaryBar({super.key, required this.itemCount, required this.totalValue, this.statusLabel = 'Otimizado'});

  final int itemCount;
  final double totalValue;
  final String statusLabel;

  static const height = 56.0;

  @override
  Widget build(BuildContext context) {
    final value = formatBRL(totalValue).replaceAll(',00', '');

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 25, spreadRadius: -5, offset: const Offset(0, 20)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: -6, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: AppColors.surfaceInverse,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.mint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const AppSvg(AppIcons.savings, width: 16.7, height: 15.8),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'PATRIMÔNIO DESPENSA',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.onSurfaceInverseVariant, letterSpacing: 0.55),
                      ),
                      Text(
                        'Total: $itemCount ${itemCount == 1 ? 'item' : 'itens'} • $value',
                        style: AppTextStyles.bodyStrong.copyWith(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(statusLabel, style: AppTextStyles.tag.copyWith(color: AppColors.mint)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
