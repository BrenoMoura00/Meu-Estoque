import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Título de seção com texto/ação à direita.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
    this.small = false,
    this.trailingStyle,
  });

  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  /// true = título 14 (ex.: "Categorias"); false = título 17
  final bool small;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    final trailingText = trailing == null
        ? null
        : Text(
            trailing!,
            style: trailingStyle ??
                (onTrailingTap != null
                    ? AppTextStyles.label.copyWith(color: AppColors.primary)
                    : AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant)),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(title, style: small ? AppTextStyles.subtitle : AppTextStyles.title),
        ),
        if (trailingText != null)
          onTrailingTap == null
              ? trailingText
              : InkWell(
                  onTap: onTrailingTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(padding: const EdgeInsets.all(4), child: trailingText),
                ),
      ],
    );
  }
}
