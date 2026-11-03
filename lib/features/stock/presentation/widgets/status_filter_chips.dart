import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Um filtro do carrossel (status ou categoria).
class StatusFilter {
  const StatusFilter({
    required this.id,
    required this.label,
    this.count,
    this.dotColor,
    this.background = AppColors.surfaceHigh,
    this.foreground = AppColors.onSurfaceVariant,
  });

  final String id;
  final String label;
  final int? count;
  final Color? dotColor;
  final Color background;
  final Color foreground;
}

/// Carrossel horizontal de filtros. O selecionado fica verde sólido.
class StatusFilterChips extends StatelessWidget {
  const StatusFilterChips({super.key, required this.filters, required this.selectedId, required this.onChanged});

  final List<StatusFilter> filters;
  final String selectedId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sangra até as bordas da tela, mantendo o alinhamento de 16px.
    return Transform.translate(
      offset: const Offset(-16, 0),
      child: SizedBox(
        height: 36,
        width: MediaQuery.sizeOf(context).width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Center(child: _chip(filters[i])),
        ),
      ),
    );
  }

  Widget _chip(StatusFilter f) {
    final selected = f.id == selectedId;
    final fg = selected ? Colors.white : f.foreground;
    final style = AppTextStyles.caption.copyWith(color: fg);

    return Material(
      color: selected ? AppColors.primary : f.background,
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: () => onChanged(f.id),
        customBorder: const StadiumBorder(),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (f.dotColor != null && !selected) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: f.dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Text(f.label, style: style),
              if (f.count != null) ...[
                const SizedBox(width: 6),
                Opacity(opacity: selected ? 0.9 : 0.8, child: Text('${f.count}', style: style)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
