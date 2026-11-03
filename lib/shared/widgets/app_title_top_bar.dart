import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Header de telas internas com título centralizado: voltar + título + ação opcional.
class AppTitleTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTitleTopBar({
    super.key,
    required this.title,
    this.actionIcon,
    this.actionTooltip,
    this.onAction,
    this.outlined = false,
  });

  final String title;
  final String? actionIcon;
  final String? actionTooltip;
  final VoidCallback? onAction;

  /// Botões em círculo branco com borda e título menor (ex.: Desperdício).
  final bool outlined;

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
                      outlined: outlined,
                      child: outlined
                          ? const AppSvg(AppIcons.chevronLeft, width: 20, height: 20)
                          : const AppSvg(AppIcons.backArrow, width: 24, height: 24),
                    ),
                    Expanded(
                      child: Text(
                        title,
                        style: outlined
                            ? AppTextStyles.screenTitle.copyWith(
                                fontSize: 16,
                                height: 24 / 16,
                                letterSpacing: -0.4,
                                color: AppColors.ink,
                              )
                            : AppTextStyles.screenTitle.copyWith(color: AppColors.ink),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (actionIcon != null)
                      _IconButton(
                        tooltip: actionTooltip ?? '',
                        onTap: onAction,
                        outlined: outlined,
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
  const _IconButton({required this.child, required this.tooltip, this.onTap, this.outlined = false});

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;
  final bool outlined;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: outlined ? AppColors.surface : Colors.transparent,
      shape: CircleBorder(side: outlined ? const BorderSide(color: AppColors.slate100) : BorderSide.none),
      child: InkWell(
        onTap: onTap ?? () {},
        customBorder: const CircleBorder(),
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    ),
  );
}
