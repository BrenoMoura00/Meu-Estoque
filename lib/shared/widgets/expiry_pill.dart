import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Pílula "Vence em X dias" — laranja se ≤ 3 dias, verde caso contrário.
class ExpiryPill extends StatelessWidget {
  const ExpiryPill({super.key, required this.daysToExpire});

  final int daysToExpire;

  @override
  Widget build(BuildContext context) {
    final soon = daysToExpire <= 3;
    final fg = soon ? AppColors.onWarningContainer : AppColors.onMint;
    final label = daysToExpire <= 0
        ? 'Vence hoje'
        : 'Vence em $daysToExpire ${daysToExpire == 1 ? 'dia' : 'dias'}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: soon ? AppColors.warningContainer : AppColors.mint,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          soon
              ? const AppSvg(AppIcons.warningClock, width: 10.5, height: 12.25)
              : const AppSvg(AppIcons.check, width: 9.5, height: 7),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.captionMedium.copyWith(color: fg)),
        ],
      ),
    );
  }
}
