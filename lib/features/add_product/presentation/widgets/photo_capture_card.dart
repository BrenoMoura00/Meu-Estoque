import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/form_widgets.dart';

/// Área "Foto do Produto" com botões Tirar Foto / Galeria.
class PhotoCaptureCard extends StatelessWidget {
  const PhotoCaptureCard({super.key, this.onTakePhoto, this.onPickFromGallery});

  final VoidCallback? onTakePhoto;
  final VoidCallback? onPickFromGallery;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(12),
        boxShadow: formShadow,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.mint.withValues(alpha: 0.4), shape: BoxShape.circle),
              child: const AppSvg(AppIcons.cameraLarge, width: 26.7, height: 24),
            ),
            const SizedBox(height: 8),
            Text('Foto do Produto', style: AppTextStyles.title, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 260),
              child: Text(
                'Tire uma foto do produto para identificação automática inteligente.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PhotoButton(
                    label: 'Tirar Foto',
                    icon: AppIcons.camera,
                    iconSize: const Size(15, 13.5),
                    background: AppColors.primary,
                    foreground: Colors.white,
                    onTap: onTakePhoto,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PhotoButton(
                    label: 'Galeria',
                    icon: AppIcons.gallery,
                    iconSize: const Size(13.5, 13.5),
                    background: AppColors.surfaceHigh,
                    foreground: AppColors.onSurface,
                    onTap: onPickFromGallery,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  const _PhotoButton({
    required this.label,
    required this.icon,
    required this.iconSize,
    required this.background,
    required this.foreground,
    this.onTap,
  });

  final String label;
  final String icon;
  final Size iconSize;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSvg(icon, width: iconSize.width, height: iconSize.height, color: foreground),
              const SizedBox(width: 4),
              Text(label, style: AppTextStyles.label.copyWith(color: foreground)),
            ],
          ),
        ),
      ),
    );
  }
}
