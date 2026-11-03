import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/progress_track.dart';
import 'expiry_palette.dart';

/// Card "Status de validade": tempo restante, ciclo de vida e alerta.
class ExpiryStatusCard extends StatelessWidget {
  const ExpiryStatusCard({super.key, required this.product, required this.notifyDaysBefore});

  final Product product;

  /// Antecedência do alerta automático.
  final int notifyDaysBefore;

  @override
  Widget build(BuildContext context) {
    final palette = ExpiryPalette.of(product);
    final fg = palette.onContainer;
    final days = product.daysToExpire;
    final alertSent = days <= notifyDaysBefore;
    final cyclePercent = (product.freshness * 100).round();

    final (String big, String small) = switch (days) {
      <= 0 => ('Hoje', 'último dia'),
      1 => ('1 dia', 'restante'),
      _ => (product.shortRemaining, 'restantes'),
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: palette.container, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(12)),
                child: const AppSvg(AppIcons.clock, width: 18.33, height: 18.33),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATUS DE VALIDADE',
                      style: AppTextStyles.label.copyWith(letterSpacing: 0.6, color: fg),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: big,
                            style: AppTextStyles.display.copyWith(
                              fontSize: 26,
                              height: 34 / 26,
                              letterSpacing: -0.39,
                              color: fg,
                            ),
                          ),
                          TextSpan(
                            text: '  $small',
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0,
                              color: fg,
                            ),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: palette.accent, borderRadius: BorderRadius.circular(999)),
                child: Text(
                  palette.pillLabel,
                  style: AppTextStyles.caption.copyWith(color: product.status == ExpiryStatus.soon ? fg : Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProgressTrack(
            value: product.freshness,
            color: palette.accent,
            height: 8,
            trackColor: Colors.white.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              AppSvg(AppIcons.bellSent, width: 12.5, height: 12.53, color: fg),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  alertSent ? 'Alerta automático enviado' : 'Alerta $notifyDaysBefore dias antes do vencimento',
                  style: AppTextStyles.body.copyWith(color: fg),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text('$cyclePercent% do ciclo', style: AppTextStyles.caption.copyWith(color: fg)),
            ],
          ),
        ],
      ),
    );
  }
}
