import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/expiry_pill.dart';
import '../../../../shared/widgets/progress_track.dart';

/// Card de item recente com validade e ações Descartar / Consumido.
class RecentItemCard extends StatelessWidget {
  const RecentItemCard({super.key, required this.product, this.onDiscard, this.onConsumed});

  final Product product;
  final VoidCallback? onDiscard;
  final VoidCallback? onConsumed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 48,
                  height: 48,
                  color: AppColors.surfaceContainer,
                  child: Image.asset(product.imagePath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: product.name, style: AppTextStyles.title),
                        TextSpan(text: '  (${product.quantity})', style: AppTextStyles.bodyMedium),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _LocationTag(location: product.location),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '• ${product.spot}',
                            style: AppTextStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ExpiryPill(daysToExpire: product.daysToExpire),
            ],
          ),
          const SizedBox(height: 8),
          ProgressTrack(
            value: product.freshness,
            height: 4,
            color: product.isExpiringSoon ? AppColors.warning : AppColors.primary,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ActionButton(
                label: 'Descartar',
                icon: AppIcons.trash,
                iconSize: const Size(10.7, 12),
                background: AppColors.surfaceHighOverlay,
                foreground: AppColors.error,
                horizontalPadding: 12,
                onTap: onDiscard,
              ),
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Consumido',
                icon: AppIcons.checkCircle,
                iconSize: const Size(13.3, 13.3),
                background: AppColors.primary,
                foreground: Colors.white,
                horizontalPadding: 16,
                onTap: onConsumed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationTag extends StatelessWidget {
  const _LocationTag({required this.location});
  final StorageLocation location;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppSvg(location.tagIcon, height: 11),
          const SizedBox(width: 4),
          Text(location.label, style: AppTextStyles.tag),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.background,
    required this.foreground,
    required this.horizontalPadding,
    this.onTap,
  });

  final String label;
  final String icon;
  final Size iconSize;
  final Color background;
  final Color foreground;
  final double horizontalPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvg(icon, width: iconSize.width, height: iconSize.height),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.label.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
