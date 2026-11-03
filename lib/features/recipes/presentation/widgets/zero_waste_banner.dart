import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';

/// Banner "Alerta de Desperdício Zero" com os itens urgentes do estoque.
class ZeroWasteBanner extends StatelessWidget {
  const ZeroWasteBanner({
    super.key,
    required this.savings,
    required this.urgentItems,
    required this.urgentToday,
    this.onSeeItems,
  });

  final double savings;
  final List<String> urgentItems;

  /// Itens que vencem hoje (chip vermelho); os demais ficam âmbar.
  final Set<String> urgentToday;
  final VoidCallback? onSeeItems;

  @override
  Widget build(BuildContext context) {
    final soft = AppColors.emerald100;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(-0.5, -1),
          end: Alignment(0.5, 1),
          colors: [AppColors.emerald600, AppColors.emerald700, AppColors.teal800],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.07),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -24,
            bottom: -32,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Text('🍲', style: AppTextStyles.display.copyWith(fontSize: 30, height: 1.2)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald500.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: AppColors.emerald400.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: AppColors.emerald300,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Alerta de Desperdício Zero',
                                      style: AppTextStyles.label.copyWith(letterSpacing: 0, color: soft),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Use os ingredientes que estão perto de se vencer',
                              style: AppTextStyles.rank.copyWith(
                                fontWeight: FontWeight.w700,
                                height: 22 / 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text.rich(
                              TextSpan(
                                style: AppTextStyles.body.copyWith(height: 16 / 12, color: soft.withValues(alpha: 0.9)),
                                children: [
                                  const TextSpan(text: 'Economize até '),
                                  TextSpan(
                                    text: formatBRL(savings),
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                                  ),
                                  const TextSpan(text: ' aproveitando itens da despensa hoje.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      Text(
                        'Urgentes:',
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 16 / 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final item in urgentItems) ...[
                                const SizedBox(width: 6),
                                _UrgentChip(label: item, today: urgentToday.contains(item)),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onSeeItems,
                        child: Text(
                          'Ver ${urgentItems.length} itens',
                          style: AppTextStyles.caption.copyWith(
                            letterSpacing: 0,
                            height: 16 / 11,
                            color: AppColors.emerald200,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.emerald200,
                          ),
                        ),
                      ),
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

class _UrgentChip extends StatelessWidget {
  const _UrgentChip({required this.label, required this.today});

  final String label;
  final bool today;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: (today ? AppColors.rose500 : AppColors.amber500).withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      label,
      style: AppTextStyles.captionMedium.copyWith(letterSpacing: 0, height: 16 / 11, color: Colors.white),
    ),
  );
}
