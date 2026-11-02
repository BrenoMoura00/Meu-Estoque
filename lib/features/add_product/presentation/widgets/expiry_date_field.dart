import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/widgets/form_widgets.dart';
import '../../data/add_product_options.dart';

/// Campo de data de validade (abre calendário) + atalhos "+3 dias", "+1 semana", "+1 mês".
class ExpiryDateField extends StatelessWidget {
  const ExpiryDateField({super.key, required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Future<void> _pick(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? _today,
      firstDate: _today.subtract(const Duration(days: 365)),
      lastDate: _today.add(const Duration(days: 365 * 5)),
      helpText: 'Data de validade',
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(12),
          child: InputBox(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value == null ? 'dd/mm/aaaa' : formatDate(value!),
                    style: inputTextStyle.copyWith(
                      color: value == null ? AppColors.outline.withValues(alpha: 0.7) : AppColors.onSurface,
                    ),
                  ),
                ),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.onSurface),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text('Atalhos:', style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
            ),
            for (final s in AddProductOptions.expiryShortcuts)
              Material(
                color: AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () => onChanged(_today.add(Duration(days: s.days))),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(s.label, style: AppTextStyles.caption),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
