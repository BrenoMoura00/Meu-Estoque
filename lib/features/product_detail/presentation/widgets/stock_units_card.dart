import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';
import 'detail_card.dart';

/// "Em estoque: N unidades" com stepper − / +.
class StockUnitsCard extends StatelessWidget {
  const StockUnitsCard({super.key, required this.units, required this.onChanged});

  final int units;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(8)),
            child: const AppSvg(AppIcons.inventory, width: 16.67, height: 16.67),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Em estoque', style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant)),
                Text(
                  units == 1 ? '1 unidade' : '$units unidades',
                  style: AppTextStyles.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(
                  tooltip: 'Diminuir quantidade',
                  onTap: units > 0 ? () => onChanged(units - 1) : null,
                  child: const AppSvg(AppIcons.minus, width: 10.5, height: 1.5),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 24,
                  child: Text('$units', style: AppTextStyles.title, textAlign: TextAlign.center),
                ),
                const SizedBox(width: 8),
                _StepButton(
                  tooltip: 'Aumentar quantidade',
                  onTap: () => onChanged(units + 1),
                  child: const AppSvg(AppIcons.plusSmall, width: 10.5, height: 10.5, color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.child, required this.tooltip, this.onTap});

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Opacity(opacity: onTap == null ? 0.4 : 1, child: child),
          ),
        ),
      ),
    ),
  );
}
