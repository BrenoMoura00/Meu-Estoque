import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';

/// Seletor segmentado de local: Todos / Geladeira / Despensa / Freezer.
/// `null` = Todos.
class LocationSegmentedControl extends StatelessWidget {
  const LocationSegmentedControl({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  final StorageLocation? selected;
  final Map<StorageLocation, int> counts;
  final ValueChanged<StorageLocation?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _segment(null, 'Todos', null),
            for (final loc in StorageLocation.values) _segment(loc, loc.label, counts[loc] ?? 0),
          ],
        ),
      ),
    );
  }

  Widget _segment(StorageLocation? value, String label, int? count) {
    final isSelected = value == selected;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.label.copyWith(
                  color: isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (count != null)
                Opacity(
                  opacity: 0.75,
                  child: Text(
                    '($count)',
                    style: AppTextStyles.label.copyWith(
                      fontWeight: FontWeight.w400,
                      color: AppColors.onSurfaceVariant,
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
