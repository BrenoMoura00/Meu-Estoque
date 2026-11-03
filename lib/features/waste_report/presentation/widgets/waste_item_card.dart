import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/waste_mock_data.dart';

/// Linha de um item descartado: emoji, nome, motivo • local, valor perdido.
class WasteItemCard extends StatelessWidget {
  const WasteItemCard({super.key, required this.entry});

  final WasteEntry entry;

  @override
  Widget build(BuildContext context) {
    final tone = entry.tone;
    final detailColor = entry.reason == WasteReason.vencimento ? AppColors.red600 : AppColors.amber600;
    final small = AppTextStyles.tag.copyWith(height: 16.5 / 11);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: tone.border),
            ),
            child: Text(entry.emoji, style: AppTextStyles.number.copyWith(height: 1.4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: AppTextStyles.bodyStrong.copyWith(letterSpacing: 0, height: 19.25 / 14, color: AppColors.ink),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: entry.detail,
                        style: small.copyWith(fontWeight: FontWeight.w500, color: detailColor),
                      ),
                      TextSpan(
                        text: '  •  ',
                        style: small.copyWith(color: AppColors.gray300),
                      ),
                      TextSpan(
                        text: entry.place,
                        style: small.copyWith(color: AppColors.slate500),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${formatBRL(entry.value)}',
                style: AppTextStyles.bodyStrong.copyWith(letterSpacing: -0.35, color: AppColors.rose600),
              ),
              const SizedBox(height: 2),
              Text(
                entry.outcome,
                style: AppTextStyles.micro.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 15 / 10,
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
