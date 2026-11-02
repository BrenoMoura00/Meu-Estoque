import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../../../shared/widgets/progress_track.dart';

/// Card de resumo por local (Geladeira / Despensa / Freezer).
class StorageSummaryCard extends StatelessWidget {
  const StorageSummaryCard({super.key, required this.summary});

  final StorageSummary summary;

  ({Color bg, Color bar, double w, double h}) get _style => switch (summary.location) {
        StorageLocation.geladeira => (bg: AppColors.mintOverlay, bar: AppColors.primary, w: 14.7, h: 18.3),
        StorageLocation.despensa => (
            bg: AppColors.warningContainerOverlay,
            bar: AppColors.warning,
            w: 16.5,
            h: 20.2
          ),
        StorageLocation.freezer => (bg: AppColors.track, bar: AppColors.primaryLight, w: 18.3, h: 18.3),
      };

  @override
  Widget build(BuildContext context) {
    final s = _style;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: s.bg, borderRadius: BorderRadius.circular(12)),
            child: AppSvg(summary.location.icon, width: s.w, height: s.h),
          ),
          const SizedBox(height: 8),
          Text('${summary.count}', style: AppTextStyles.number),
          Text(
            summary.location.label,
            style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          ProgressTrack(value: summary.occupancy, color: s.bar),
          const SizedBox(height: 6),
          Text('${(summary.occupancy * 100).round()}% espaço', style: AppTextStyles.micro),
        ],
      ),
    );
  }
}
