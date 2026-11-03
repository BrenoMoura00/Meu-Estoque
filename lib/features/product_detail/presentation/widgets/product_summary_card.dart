import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import 'detail_card.dart';

/// Card com foto, marca/variante, nome e local do produto.
class ProductSummaryCard extends StatelessWidget {
  const ProductSummaryCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: AppColors.surfaceLow,
                    child: Image.asset(product.photoPath ?? product.imagePath, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const AppSvg(AppIcons.dropBadge, width: 10.67, height: 13.33),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brand != null || product.variant != null) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (product.brand != null)
                        _Tag(
                          label: product.brand!,
                          background: AppColors.surfaceHigh,
                          foreground: AppColors.onSurfaceVariant,
                        ),
                      if (product.variant != null)
                        _Tag(
                          label: product.variant!,
                          background: AppColors.mint.withValues(alpha: 0.4),
                          foreground: AppColors.onMintVariant,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  product.name,
                  style: AppTextStyles.number.copyWith(height: 28 / 20),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    AppSvg(product.location.inlineIcon, width: 9.33, height: 11.67),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${product.quantity} • ${product.location.label} (${product.spot})',
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
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.background, required this.foreground});

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
    child: Text(label, style: AppTextStyles.caption.copyWith(color: foreground)),
  );
}
