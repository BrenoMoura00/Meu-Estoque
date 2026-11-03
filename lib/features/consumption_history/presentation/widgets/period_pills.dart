import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/consumption_mock_data.dart';

/// Carrossel de períodos rápidos (Este Mês, Últimos 30 dias...).
class PeriodPills extends StatelessWidget {
  const PeriodPills({super.key, required this.selected, required this.onChanged, this.sidePadding = 20});

  final ConsumptionPeriod selected;
  final ValueChanged<ConsumptionPeriod> onChanged;

  /// Recuo lateral da página: o carrossel sangra até a borda mantendo o alinhamento.
  final double sidePadding;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-sidePadding, 0),
      child: SizedBox(
        height: 34,
        width: MediaQuery.sizeOf(context).width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          itemCount: ConsumptionPeriod.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Center(child: _pill(ConsumptionPeriod.values[i])),
        ),
      ),
    );
  }

  Widget _pill(ConsumptionPeriod period) {
    final isSelected = period == selected;
    return Material(
      color: isSelected ? AppColors.emerald600 : AppColors.surface,
      shape: StadiumBorder(side: isSelected ? BorderSide.none : const BorderSide(color: AppColors.slate200)),
      child: InkWell(
        onTap: () => onChanged(period),
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Text(
            period.label,
            style: AppTextStyles.label.copyWith(
              letterSpacing: 0,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
