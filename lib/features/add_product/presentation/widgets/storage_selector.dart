import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../data/add_product_options.dart';

/// Seletor "Local de Armazenamento" (Geladeira / Despensa / Freezer).
class StorageSelector extends StatelessWidget {
  const StorageSelector({super.key, required this.selected, required this.onChanged});

  final StorageLocation selected;
  final ValueChanged<StorageLocation> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          for (final (i, loc) in StorageLocation.values.indexed) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _option(loc)),
          ],
        ],
      ),
    );
  }

  Widget _option(StorageLocation loc) {
    final isSelected = loc == selected;
    final color = isSelected ? AppColors.primary : AppColors.onSurfaceVariant;

    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(loc),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))]
                : null,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 18.3,
                child: Center(child: AppSvg(AddProductOptions.storageIcon(loc), height: 16.7, color: color)),
              ),
              const SizedBox(height: 4),
              Text(
                loc.label,
                style: AppTextStyles.label.copyWith(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
