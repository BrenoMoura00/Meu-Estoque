import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

/// Card "Dica inteligente de economia".
class SavingTipCard extends StatelessWidget {
  const SavingTipCard({super.key, required this.items, required this.sharePercent, required this.savings});

  /// Itens que mais pesam no consumo (ex.: ["Leite Integral", "Frango"]).
  final List<String> items;
  final int sharePercent;
  final double savings;

  @override
  Widget build(BuildContext context) {
    final base = AppTextStyles.body.copyWith(height: 19.5 / 12, color: AppColors.slate700);
    final itemStyle = base.copyWith(fontWeight: FontWeight.w600, color: AppColors.emerald900);
    final strong = base.copyWith(fontWeight: FontWeight.w700);

    final itemSpans = <InlineSpan>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) itemSpans.add(TextSpan(text: i == items.length - 1 ? ' e ' : ', '));
      itemSpans.add(TextSpan(text: items[i], style: itemStyle));
    }

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.emerald50.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.emerald200.withValues(alpha: 0.7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.emerald600,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1)),
              ],
            ),
            child: Text('💡', style: AppTextStyles.rank.copyWith(color: Colors.white)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DICA INTELIGENTE DE ECONOMIA',
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: AppColors.emerald950,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: base,
                    children: [
                      ...itemSpans,
                      TextSpan(text: items.length > 1 ? ' representam ' : ' representa '),
                      TextSpan(text: '$sharePercent%', style: strong),
                      const TextSpan(
                        text:
                            ' do seu consumo mensal. Comprar fardos fechados ou embalagens econômicas pode gerar até ',
                      ),
                      TextSpan(
                        text: formatBRL(savings),
                        style: strong.copyWith(color: AppColors.emerald700),
                      ),
                      const TextSpan(text: ' de economia.'),
                    ],
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
