import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/progress_track.dart';

/// Card de item do estoque com validade, barra de vida útil e ações.
class StockItemCard extends StatelessWidget {
  const StockItemCard({super.key, required this.product, this.onConsume, this.onDiscard});

  final Product product;
  final VoidCallback? onConsume;
  final VoidCallback? onDiscard;

  ({Color accent, Color imageBg, Color badgeBg, Color badgeFg}) get _palette => switch (product.status) {
        ExpiryStatus.today => (
            accent: AppColors.errorBright,
            imageBg: AppColors.errorContainerSolid,
            badgeBg: AppColors.errorBright,
            badgeFg: Colors.white,
          ),
        ExpiryStatus.soon => (
            accent: AppColors.warning,
            imageBg: product.daysToExpire <= 1 ? AppColors.warningContainer : AppColors.surfaceHigh,
            badgeBg: AppColors.warning.withValues(alpha: 0.2),
            badgeFg: AppColors.onWarning,
          ),
        ExpiryStatus.ok => (
            accent: AppColors.primary,
            imageBg: AppColors.mint,
            badgeBg: AppColors.primary.withValues(alpha: 0.1),
            badgeFg: AppColors.primary,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final p = _palette;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumb(imagePath: product.imagePath, background: p.imageBg, dot: p.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: AppTextStyles.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: p.badgeBg, borderRadius: BorderRadius.circular(999)),
                          child: Text(
                            product.shortRemaining,
                            style: AppTextStyles.caption.copyWith(
                              color: p.badgeFg,
                              fontWeight: product.status == ExpiryStatus.ok ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1.5),
                    Row(
                      children: [
                        Flexible(
                          child: Text(product.quantity,
                              style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        Text('•', style: AppTextStyles.body),
                        const SizedBox(width: 8),
                        AppSvg(product.location.inlineIcon, height: 11.7),
                        const SizedBox(width: 2),
                        Text(product.location.label, style: AppTextStyles.body),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ProgressTrack(value: product.freshness, color: p.accent),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatusNote(product: product)),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: onConsume ?? () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppSvg(AppIcons.consume, width: 15, height: 15),
                        const SizedBox(width: 4),
                        Text('Consumir', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Tooltip(
                message: 'Descartar item',
                child: Material(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: onDiscard ?? () {},
                    borderRadius: BorderRadius.circular(8),
                    child: const SizedBox(
                      width: 36,
                      height: 36,
                      child: Center(child: AppSvg(AppIcons.trashOutline, width: 12, height: 13.5)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.imagePath, required this.background, required this.dot});

  final String imagePath;
  final Color background;
  final Color dot;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 56,
        height: 56,
        color: background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: dot,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Texto de situação à esquerda das ações.
class _StatusNote extends StatelessWidget {
  const _StatusNote({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    final (String text, Color color, FontWeight weight, String? icon) = switch (product.status) {
      ExpiryStatus.today => ('Consumir com urgência', AppColors.error, FontWeight.w700, AppIcons.warning),
      ExpiryStatus.soon when product.location == StorageLocation.freezer =>
        ('Congelado • Prazo ideal', AppColors.onSurfaceVariant, FontWeight.w700, null),
      ExpiryStatus.soon when product.daysToExpire == 1 =>
        ('Vence amanhã', AppColors.warningText, FontWeight.w500, null),
      ExpiryStatus.soon =>
        ('Vence em ${product.daysToExpire} dias', AppColors.onSurfaceVariant, FontWeight.w700, null),
      ExpiryStatus.ok => ('Seguro & fechado', AppColors.primary, FontWeight.w500, AppIcons.checkCircleGreen),
    };

    return Row(
      children: [
        if (icon != null) ...[
          AppSvg(icon, height: 13),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            text,
            style: AppTextStyles.caption.copyWith(color: color, fontWeight: weight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
