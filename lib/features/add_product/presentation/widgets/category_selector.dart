import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/form_widgets.dart';

/// Seletor de categoria em pílulas roláveis.
class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key, required this.categories, required this.selected, required this.onChanged});

  final List<Category> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sangra até as bordas da tela, mantendo o alinhamento de 16px.
    return Transform.translate(
      offset: const Offset(-16, 0),
      child: SizedBox(
        height: 44,
        width: MediaQuery.sizeOf(context).width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = categories[i];
            final isSelected = c.label == selected;
            final fg = isSelected ? Colors.white : AppColors.onSurface;
            return Center(
              child: Material(
                color: Colors.transparent,
                child: Ink(
                  decoration: ShapeDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    shape: const StadiumBorder(),
                    shadows: formShadow,
                  ),
                  child: InkWell(
                    onTap: () => onChanged(c.label),
                    customBorder: const StadiumBorder(),
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppSvg(c.icon, height: 14, color: fg),
                          const SizedBox(width: 4),
                          Text(c.label, style: AppTextStyles.label.copyWith(color: fg)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
