import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Barra de progresso arredondada (ocupação, vida útil).
class ProgressTrack extends StatelessWidget {
  const ProgressTrack({super.key, required this.value, required this.color, this.height = 6});

  /// 0..1
  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: AppColors.track)),
              FractionallySizedBox(
                widthFactor: value.clamp(0, 1),
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
                ),
              ),
            ],
          ),
        ),
      );
}
