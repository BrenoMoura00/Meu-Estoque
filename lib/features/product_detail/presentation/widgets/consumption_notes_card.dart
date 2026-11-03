import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';
import 'detail_card.dart';

/// "Observações de Consumo" (privadas).
class ConsumptionNotesCard extends StatelessWidget {
  const ConsumptionNotesCard({super.key, required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const AppSvg(AppIcons.notes, width: 12, height: 8),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Observações de Consumo',
                  style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text('Privado', style: AppTextStyles.caption.copyWith(color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: BorderRadius.circular(8)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSvg(AppIcons.noteCheck, width: 15, height: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notes,
                    style: AppTextStyles.subtitle.copyWith(
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0,
                      color: AppColors.onSurfaceVariant,
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
