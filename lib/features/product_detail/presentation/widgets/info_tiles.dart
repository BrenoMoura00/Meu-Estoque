import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';
import 'detail_card.dart';

/// Ícone SVG com seu tamanho nativo.
typedef TileIcon = ({String asset, double width, double height});

/// Card de valor com rótulo em cima (ex.: "Validade" → "14/06/2026").
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.caption,
    this.captionStyle,
  });

  final TileIcon icon;
  final String label;
  final String value;
  final String caption;
  final TextStyle? captionStyle;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSvg(icon.asset, width: icon.width, height: icon.height),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(caption, style: captionStyle ?? AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Card com ícone em caixa à esquerda (ex.: "Categoria" → "Laticínios").
class IconInfoTile extends StatelessWidget {
  const IconInfoTile({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.label,
    required this.value,
  });

  final TileIcon icon;
  final Color iconBackground;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DetailCard(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: iconBackground, borderRadius: BorderRadius.circular(8)),
            child: AppSvg(icon.asset, width: icon.width, height: icon.height),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
                Text(value, style: AppTextStyles.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
