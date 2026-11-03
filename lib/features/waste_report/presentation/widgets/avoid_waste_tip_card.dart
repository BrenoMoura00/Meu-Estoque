import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Card verde "Como evitar novos prejuízos?" com atalhos.
class AvoidWasteTipCard extends StatelessWidget {
  const AvoidWasteTipCard({super.key, required this.notifyDaysBefore, this.onAdjustNotifications, this.onSeeRecipes});

  final int notifyDaysBefore;
  final VoidCallback? onAdjustNotifications;
  final VoidCallback? onSeeRecipes;

  @override
  Widget build(BuildContext context) {
    final bold = AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-0.6, -1),
          end: Alignment(0.6, 1),
          colors: [AppColors.emerald600, AppColors.emerald700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DICA INTELIGENTE',
                        style: AppTextStyles.captionMedium.copyWith(
                          height: 16.5 / 11,
                          letterSpacing: 0.55,
                          color: AppColors.emerald200,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Como evitar novos prejuízos?',
                        style: AppTextStyles.rank.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ative lembretes com $notifyDaysBefore dias de antecedência ou explore receitas de '
                        'reaproveitamento para os itens com consumo próximo.',
                        style: AppTextStyles.body.copyWith(height: 19.5 / 12, color: AppColors.emerald100),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const AppSvg(AppIcons.bolt, width: 20, height: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 13),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.15))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: onAdjustNotifications,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              'Ajustar Notificações',
                              style: bold.copyWith(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const AppSvg(AppIcons.chevronRightWhite, width: 14, height: 14),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onSeeRecipes,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text('Ver Receitas Rápidas', style: bold.copyWith(color: AppColors.emerald700)),
                    ),
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
