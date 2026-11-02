import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Mini-banner "O que cozinhar hoje?".
class RecipeSuggestionBanner extends StatelessWidget {
  const RecipeSuggestionBanner({super.key, required this.recipeCount, this.onTap});

  final int recipeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.mintOverlay.withValues(alpha: 0.2),
              AppColors.surfaceLow,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1)),
                    ],
                  ),
                  child: const AppSvg(AppIcons.recipe, width: 18.6, height: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('O que cozinhar hoje?', style: AppTextStyles.bodyStrong),
                      Text('$recipeCount receitas com os itens que vencem logo', style: AppTextStyles.body),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const AppSvg(AppIcons.chevronRight, width: 6.2, height: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
