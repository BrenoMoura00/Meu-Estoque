import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tom de cor de um item/categoria em listas (fundo e borda do ícone, texto da tag).
enum CategoryTone {
  blue(AppColors.blue50, AppColors.blue100, AppColors.blue700),
  amber(AppColors.amber50, AppColors.amber100, AppColors.amber800),
  orange(AppColors.orange50, AppColors.orange100, AppColors.orange700),
  yellow(AppColors.yellow50, AppColors.yellow100, AppColors.yellow800),
  slate(AppColors.slate50, AppColors.slate200, AppColors.slate700),
  rose(AppColors.rose50, AppColors.rose100, AppColors.rose700),
  red(AppColors.red50, AppColors.red100, AppColors.red600),
  emerald(AppColors.emerald50, AppColors.emerald100, AppColors.emerald700);

  const CategoryTone(this.background, this.border, this.foreground);

  final Color background;
  final Color border;
  final Color foreground;

  /// Fundo da tag de categoria (o tom "slate" usa um cinza um pouco mais escuro).
  Color get tagBackground => this == slate ? AppColors.slate100 : background;
}
