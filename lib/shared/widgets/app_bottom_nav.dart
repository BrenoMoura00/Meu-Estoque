import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'app_svg.dart';

/// Abas principais do app (o botão central "+" não é uma aba).
enum AppTab {
  inicio('Início', AppIcons.navInicio, 16, 20),
  estoque('Estoque', AppIcons.navEstoque, 20, 22),
  compras('Compras', AppIcons.navCompras, 20, 20),
  receitas('Receitas', AppIcons.navReceitas, 18, 20);

  const AppTab(this.label, this.icon, this.iconWidth, this.iconHeight);
  final String label;
  final String icon;
  final double iconWidth;
  final double iconHeight;
}

/// Barra inferior translúcida com botão central de adicionar alimento.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.current,
    required this.onTabSelected,
    required this.onAdd,
    this.shoppingBadge = 0,
  });

  final AppTab current;
  final ValueChanged<AppTab> onTabSelected;
  final VoidCallback onAdd;
  final int shoppingBadge;

  static const height = 64.0;
  static const _fabSize = 56.0;
  static const _fabLift = 20.0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.9),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: height,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 512),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          children: [
                            _item(AppTab.inicio),
                            _item(AppTab.estoque),
                            const SizedBox(width: 76),
                            _item(AppTab.compras, badge: shoppingBadge),
                            _item(AppTab.receitas),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -_fabLift,
          child: Semantics(
            button: true,
            label: 'Adicionar novo alimento',
            child: Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              elevation: 0,
              child: InkWell(
                onTap: onAdd,
                customBorder: const CircleBorder(),
                child: Container(
                  width: _fabSize,
                  height: _fabSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.45),
                        blurRadius: 20,
                        spreadRadius: -3,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AppSvg(AppIcons.plus, width: 16.3, height: 16.3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _item(AppTab tab, {int badge = 0}) {
    final selected = tab == current;
    final color = selected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () => onTabSelected(tab),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AppSvg(tab.icon, width: tab.iconWidth, height: tab.iconHeight, color: color),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: AppColors.warning, shape: BoxShape.circle),
                      child: Text(
                        '$badge',
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 10, height: 1, letterSpacing: 0, color: AppColors.onWarning),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(tab.label, style: AppTextStyles.caption.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
