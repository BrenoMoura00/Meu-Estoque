import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Card de alerta "Produtos que vencem hoje".
class ExpiringTodayBanner extends StatelessWidget {
  const ExpiringTodayBanner({super.key, required this.products, required this.valueAtRisk, this.onSeeAll});

  final List<Product> products;
  final double valueAtRisk;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'ATENÇÃO PRIORITÁRIA',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.onErrorContainer, letterSpacing: 0.55),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('Produtos que vencem hoje', style: AppTextStyles.title),
                    const SizedBox(height: 4),
                    Text('Evite o desperdício consumindo ou congelando agora', style: AppTextStyles.body),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${products.length}', style: AppTextStyles.display.copyWith(color: AppColors.error)),
                    const SizedBox(width: 4),
                    Text('itens', style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < products.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _MiniProductCard(product: products[i])),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${formatBRL(valueAtRisk)} em risco hoje',
                style: AppTextStyles.label.copyWith(color: AppColors.error, letterSpacing: 0, height: 18 / 12),
              ),
              InkWell(
                onTap: onSeeAll,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Text('Ver todos', style: AppTextStyles.label.copyWith(color: AppColors.error)),
                      const SizedBox(width: 4),
                      const AppSvg(AppIcons.arrowRightSmall, width: 10.7, height: 10.7),
                    ],
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

class _MiniProductCard extends StatelessWidget {
  const _MiniProductCard({required this.product});
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 48,
              height: 48,
              color: AppColors.surfaceContainer,
              child: Image.asset(product.imagePath, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.name,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(6)),
            child: Text(
              'Hoje',
              style: AppTextStyles.caption.copyWith(fontSize: 10, height: 1.25, letterSpacing: 0, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
