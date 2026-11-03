import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Card branco padrão da tela de detalhes (padding 12, raio 12, sombra leve).
class DetailCard extends StatelessWidget {
  const DetailCard({super.key, required this.child, this.padding = const EdgeInsets.all(12)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 1, offset: const Offset(0, 1))],
    ),
    child: child,
  );
}
