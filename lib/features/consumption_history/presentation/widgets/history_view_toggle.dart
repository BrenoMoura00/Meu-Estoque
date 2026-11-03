import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Visões do histórico.
enum HistoryView {
  mostConsumed('Mais Consumido'),
  byCategory('Por categoria');

  const HistoryView(this.label);
  final String label;
}

/// Controle segmentado "Mais Consumido" / "Por categoria".
class HistoryViewToggle extends StatelessWidget {
  const HistoryViewToggle({super.key, required this.selected, required this.onChanged});

  final HistoryView selected;
  final ValueChanged<HistoryView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate200.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          for (final view in HistoryView.values) ...[
            if (view.index > 0) const SizedBox(width: 4),
            Expanded(child: _segment(view)),
          ],
        ],
      ),
    );
  }

  Widget _segment(HistoryView view) {
    final isSelected = view == selected;
    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(view),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))]
                : null,
          ),
          child: Text(
            view.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
              letterSpacing: 0,
              color: isSelected ? AppColors.ink : AppColors.slate600,
            ),
          ),
        ),
      ),
    );
  }
}
