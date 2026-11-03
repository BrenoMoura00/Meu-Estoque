import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Uma opção do [ChoicePillBar].
class ChoicePill<T> {
  const ChoicePill(this.value, this.label, {this.dotColor});

  final T value;
  final String label;

  /// Bolinha colorida antes do texto (só quando não selecionada).
  final Color? dotColor;
}

/// Carrossel horizontal de pílulas: selecionada verde sólido, demais brancas com borda.
/// Sangra até as bordas da tela, mantendo o alinhamento do conteúdo.
class ChoicePillBar<T> extends StatelessWidget {
  const ChoicePillBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.sidePadding = 16,
    this.dense = false,
  });

  final List<ChoicePill<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  /// Recuo lateral da página.
  final double sidePadding;

  /// Versão compacta (34px, texto médio) usada em filtros de período.
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(-sidePadding, 0),
      child: SizedBox(
        height: dense ? 34 : 42,
        width: MediaQuery.sizeOf(context).width,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          itemCount: options.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => Center(child: _pill(options[i])),
        ),
      ),
    );
  }

  Widget _pill(ChoicePill<T> option) {
    final isSelected = option.value == selected;
    final shadow = dense
        ? null
        : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))];

    return DecoratedBox(
      decoration: ShapeDecoration(shape: const StadiumBorder(), shadows: shadow),
      child: Material(
        color: isSelected ? AppColors.emerald600 : AppColors.surface,
        shape: StadiumBorder(
          side: isSelected ? BorderSide.none : BorderSide(color: AppColors.slate200.withValues(alpha: 0.9)),
        ),
        child: InkWell(
          onTap: () => onChanged(option.value),
          customBorder: const StadiumBorder(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: dense ? 14 : 16, vertical: dense ? 6 : 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.dotColor != null && !isSelected) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: option.dotColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  option.label,
                  style: AppTextStyles.label.copyWith(
                    letterSpacing: 0,
                    fontWeight: isSelected || !dense ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.slate600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
