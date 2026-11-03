import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_svg.dart';

/// Campo de busca + botão de filtros avançados.
class StockSearchBar extends StatelessWidget {
  const StockSearchBar({super.key, required this.onChanged, this.onFilterTap});

  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;

  static final _shadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: _shadow,
            ),
            child: TextField(
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                hintText: 'Buscar item por nome ou código...',
                hintStyle: AppTextStyles.subtitle.copyWith(
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                  color: AppColors.outline.withValues(alpha: 0.7),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 14, right: 15),
                  child: AppSvg(AppIcons.searchInput, width: 15, height: 15),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 44),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Opções avançadas de filtro',
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: _shadow,
              ),
              child: InkWell(
                onTap: onFilterTap ?? () {},
                borderRadius: BorderRadius.circular(12),
                child: const SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(child: AppSvg(AppIcons.filter, width: 16.5, height: 16.5)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
