import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/section_header.dart';

/// Seção "Categorias" com pílulas roláveis horizontalmente.
class CategoryChips extends StatefulWidget {
  const CategoryChips({super.key, required this.categories, this.onChanged});

  final List<Category> categories;
  final ValueChanged<Category>? onChanged;

  @override
  State<CategoryChips> createState() => _CategoryChipsState();
}

class _CategoryChipsState extends State<CategoryChips> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    // "Todos" não conta como categoria ativa.
    final activeCount = widget.categories.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: 'Categorias',
          small: true,
          trailing: '$activeCount ativas',
          trailingStyle: AppTextStyles.caption.copyWith(color: AppColors.primary),
        ),
        const SizedBox(height: 8),
        // Sangra até as bordas da tela, mantendo o alinhamento de 16px.
        Transform.translate(
          offset: const Offset(-16, 0),
          child: SizedBox(
            height: 40,
            width: MediaQuery.sizeOf(context).width,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Center(
                child: _Chip(
                  category: widget.categories[i],
                  selected: i == _selected,
                  onTap: () {
                    setState(() => _selected = i);
                    widget.onChanged?.call(widget.categories[i]);
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.category, required this.selected, required this.onTap});

  final Category category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Container(
          height: 36,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSvg(category.icon, height: 14, color: selected ? Colors.white : null),
              const SizedBox(width: 6),
              Text(
                category.label,
                style: AppTextStyles.label.copyWith(color: selected ? Colors.white : AppColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
