import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Header de telas internas (empilhadas): voltar + logo + título + mais opções + perfil.
class AppDetailTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppDetailTopBar({super.key, required this.title, this.onMore, this.onProfile});

  final String title;
  final VoidCallback? onMore;
  final VoidCallback? onProfile;

  static const height = 64.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(color: AppColors.shadow.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 1)),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _RoundButton(
                      tooltip: 'Voltar',
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const AppSvg(AppIcons.back, width: 16, height: 16),
                    ),
                    const SizedBox(width: 4),
                    Image.asset(AppImages.logo, width: 28, height: 28),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(title, style: AppTextStyles.title, overflow: TextOverflow.ellipsis),
                    ),
                    _RoundButton(
                      tooltip: 'Mais opções',
                      onTap: onMore,
                      child: const AppSvg(AppIcons.moreVert, width: 3.7, height: 14.7),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Tooltip(
                        message: 'Perfil',
                        child: InkWell(
                          onTap: onProfile,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const AppSvg(AppIcons.profile, width: 12, height: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.child, required this.tooltip, this.onTap});

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap ?? () {},
          customBorder: const CircleBorder(),
          child: SizedBox(width: 44, height: 44, child: Center(child: child)),
        ),
      );
}
