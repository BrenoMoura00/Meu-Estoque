import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/form_widgets.dart';

/// Linha com "Quantidade" (stepper) e "Unidade" (dropdown).
class QuantityUnitRow extends StatelessWidget {
  const QuantityUnitRow({
    super.key,
    required this.quantity,
    required this.onQuantityChanged,
    required this.unit,
    required this.units,
    required this.onUnitChanged,
  });

  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final String unit;
  final List<String> units;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabeledField(
            label: const FormFieldLabel('Quantidade'),
            child: InputBox(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  _StepButton(
                    tooltip: 'Diminuir quantidade',
                    background: AppColors.surfaceHigh,
                    icon: const AppSvg(AppIcons.minus, width: 10.5, height: 1.5),
                    onTap: quantity > 1 ? () => onQuantityChanged(quantity - 1) : null,
                  ),
                  Expanded(
                    child: Text('$quantity', style: AppTextStyles.title, textAlign: TextAlign.center),
                  ),
                  _StepButton(
                    tooltip: 'Aumentar quantidade',
                    background: AppColors.mint,
                    icon: const AppSvg(AppIcons.plusSmall, width: 10.5, height: 10.5),
                    onTap: () => onQuantityChanged(quantity + 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LabeledField(
            label: const FormFieldLabel('Unidade'),
            child: InputBox(
              padding: const EdgeInsets.only(left: 12, right: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: unit,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(12),
                  dropdownColor: AppColors.surface,
                  style: inputTextStyle.copyWith(color: AppColors.onSurface),
                  icon: const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: AppSvg(AppIcons.chevronDown, width: 10, height: 6.2),
                  ),
                  items: [for (final u in units) DropdownMenuItem(value: u, child: Text(u))],
                  onChanged: (v) {
                    if (v != null) onUnitChanged(v);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.tooltip, required this.background, required this.icon, this.onTap});

  final String tooltip;
  final Color background;
  final Widget icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: onTap == null ? 0.5 : 1,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(width: 32, height: 32, child: Center(child: icon)),
          ),
        ),
      ),
    );
  }
}
