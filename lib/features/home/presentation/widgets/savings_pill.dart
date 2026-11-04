import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Faixa "Economia inteligente do mês".
class SavingsPill extends StatelessWidget {
  const SavingsPill({super.key, required this.amount, required this.growthPercent, this.onTap});

  final double amount;
  final int growthPercent;

  /// Abre o histórico de consumo.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(padding: const EdgeInsets.all(12), child: _content()),
      ),
    );
  }

  Widget _content() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: AppColors.mint, borderRadius: BorderRadius.circular(12)),
          child: const AppSvg(AppIcons.eco, width: 14.2, height: 14.2),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Economia inteligente do mês',
                style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${formatBRL(amount)} preservados',
                style: AppTextStyles.bodyStrong.copyWith(color: AppColors.primary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
          child: Text('${growthPercent >= 0 ? '+' : ''}$growthPercent%', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
        ),
      ],
    );
  }
}
