import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Header translúcido com logo, título da tela, busca, notificações e perfil.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    required this.title,
    this.notificationCount = 0,
    this.onSearch,
    this.onNotifications,
    this.onProfile,
  });

  final String title;
  final int notificationCount;
  final VoidCallback? onSearch;
  final VoidCallback? onNotifications;
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Image.asset(AppImages.logo, width: 32, height: 32),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MEU ESTOQUE',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 0.55,
                              height: 1,
                            ),
                          ),
                          Text(title, style: AppTextStyles.title, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    _CircleIconButton(
                      tooltip: 'Buscar no estoque',
                      onTap: onSearch,
                      child: const AppSvg(AppIcons.search, width: 16.5, height: 16.5),
                    ),
                    const SizedBox(width: 4),
                    _CircleIconButton(
                      tooltip: 'Notificações e vencimentos',
                      onTap: onNotifications,
                      badge: notificationCount > 0 ? '$notificationCount' : null,
                      child: const AppSvg(AppIcons.bell, width: 14.7, height: 18.3),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Perfil',
                      child: InkWell(
                        onTap: onProfile,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1)),
                            ],
                          ),
                          child: const AppSvg(AppIcons.profile, width: 12, height: 12),
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.child, required this.tooltip, this.onTap, this.badge});

  final Widget child;
  final String tooltip;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            alignment: Alignment.center,
            children: [
              child,
              if (badge != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    height: 18,
                    constraints: const BoxConstraints(minWidth: 18),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      badge!,
                      style: AppTextStyles.micro.copyWith(color: Colors.white, height: 1),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
