import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Header de telas internas com título centralizado: voltar + título + ação opcional.
class AppTitleTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTitleTopBar({super.key, required this.title, this.actionIcon, this.actionTooltip, this.onAction});

  final String title;
  final String? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;

  static const height = 56.0;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background.withValues(alpha: 0.9),
            border: const Border(bottom: BorderSide(color: AppColors.slate100)),
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    _IconButton(
                      tooltip: 'Voltar',
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const AppSvg(AppIcons.backArrow, width: 24, height: 24),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.screenTitle.copyWith(color: AppColors.ink),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (actionIcon != null)
                      _IconButton(
                        tooltip: actionTooltip ?? '',
                        onTap: onAction,
                        child: AppSvg(actionIcon!, width: 20, height: 20),
                      )
                    else
                      const SizedBox(width: 40),
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

class _IconButton extends StatelessWidget {
  const _IconButton({required this.child, required this.tooltip, this.onTap});

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap ?? () {},
      customBorder: const CircleBorder(),
      child: SizedBox(width: 40, height: 40, child: Center(child: child)),
    ),
  );
}
