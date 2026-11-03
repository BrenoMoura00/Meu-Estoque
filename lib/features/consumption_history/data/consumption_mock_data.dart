import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Tom de cor de uma categoria no histórico (fundo, borda e texto da tag).
enum ConsumptionTone {
  blue(AppColors.blue50, AppColors.blue100, AppColors.blue700),
  amber(AppColors.amber50, AppColors.amber100, AppColors.amber800),
  orange(AppColors.orange50, AppColors.orange100, AppColors.orange700),
  yellow(AppColors.yellow50, AppColors.yellow100, AppColors.yellow800),
  slate(AppColors.slate50, AppColors.slate200, AppColors.slate700),
  rose(AppColors.rose50, AppColors.rose100, AppColors.rose700);

  const ConsumptionTone(this.background, this.border, this.foreground);

  final Color background;
  final Color border;
  final Color foreground;

  /// Fundo da tag de categoria (o tom "slate" usa um cinza um pouco mais escuro).
  Color get tagBackground => this == slate ? AppColors.slate100 : background;
}

/// Um item (ou categoria) no ranking de consumo.
class ConsumptionEntry {
  const ConsumptionEntry({
    required this.name,
    required this.emoji,
    required this.category,
    required this.tone,
    required this.times,
    required this.amountLabel,
    required this.totalValue,
  });

  final String name;
  final String emoji;
  final String category;
  final ConsumptionTone tone;

  /// Quantas vezes foi consumido no período.
  final int times;

  /// Texto de quantidade (ex.: "14x • 14 Litros").
  final String amountLabel;

  /// Valor aproximado gasto no período.
  final double totalValue;
}

/// Períodos rápidos do histórico.
enum ConsumptionPeriod {
  thisMonth('Este Mês (Out)'),
  last30Days('Últimos 30 dias'),
  threeMonths('3 Meses'),
  thisYear('Este Ano');

  const ConsumptionPeriod(this.label);
  final String label;
}

abstract final class ConsumptionMockData {
  static const totalItems = 84;
  static const efficiencyPercent = 96;

  static const ranking = [
    ConsumptionEntry(
      name: 'Leite Integral',
      emoji: '🥛',
      category: 'Laticínios',
      tone: ConsumptionTone.blue,
      times: 14,
      amountLabel: '14x • 14 Litros',
      totalValue: 91,
    ),
    ConsumptionEntry(
      name: 'Café Torrado & Moído',
      emoji: '☕',
      category: 'Matinais',
      tone: ConsumptionTone.amber,
      times: 8,
      amountLabel: '8x • 4 kg',
      totalValue: 88,
    ),
    ConsumptionEntry(
      name: 'Peito de Frango',
      emoji: '🍗',
      category: 'Açougue',
      tone: ConsumptionTone.orange,
      times: 7,
      amountLabel: '7x • 7 kg',
      totalValue: 140,
    ),
    ConsumptionEntry(
      name: 'Ovos Caipiras',
      emoji: '🥚',
      category: 'Proteínas',
      tone: ConsumptionTone.yellow,
      times: 6,
      amountLabel: '6 dúzias (72 un)',
      totalValue: 66,
    ),
    ConsumptionEntry(
      name: 'Arroz Branco 5kg',
      emoji: '🍚',
      category: 'Grãos & Cereais',
      tone: ConsumptionTone.slate,
      times: 4,
      amountLabel: '4x • 20 kg',
      totalValue: 110,
    ),
    ConsumptionEntry(
      name: 'Maçã Fuji',
      emoji: '🍎',
      category: 'Hortifrúti',
      tone: ConsumptionTone.rose,
      times: 4,
      amountLabel: '4x • 4 kg',
      totalValue: 36,
    ),
  ];

  /// Dica de economia: itens em destaque, % do consumo e economia possível.
  static const tipItems = ['Leite Integral', 'Frango'];
  static const tipSharePercent = 38;
  static const tipSavings = 45.0;
}
