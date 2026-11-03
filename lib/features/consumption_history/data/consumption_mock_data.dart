import '../../../core/theme/category_tone.dart';

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
  final CategoryTone tone;

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
      tone: CategoryTone.blue,
      times: 14,
      amountLabel: '14x • 14 Litros',
      totalValue: 91,
    ),
    ConsumptionEntry(
      name: 'Café Torrado & Moído',
      emoji: '☕',
      category: 'Matinais',
      tone: CategoryTone.amber,
      times: 8,
      amountLabel: '8x • 4 kg',
      totalValue: 88,
    ),
    ConsumptionEntry(
      name: 'Peito de Frango',
      emoji: '🍗',
      category: 'Açougue',
      tone: CategoryTone.orange,
      times: 7,
      amountLabel: '7x • 7 kg',
      totalValue: 140,
    ),
    ConsumptionEntry(
      name: 'Ovos Caipiras',
      emoji: '🥚',
      category: 'Proteínas',
      tone: CategoryTone.yellow,
      times: 6,
      amountLabel: '6 dúzias (72 un)',
      totalValue: 66,
    ),
    ConsumptionEntry(
      name: 'Arroz Branco 5kg',
      emoji: '🍚',
      category: 'Grãos & Cereais',
      tone: CategoryTone.slate,
      times: 4,
      amountLabel: '4x • 20 kg',
      totalValue: 110,
    ),
    ConsumptionEntry(
      name: 'Maçã Fuji',
      emoji: '🍎',
      category: 'Hortifrúti',
      tone: CategoryTone.rose,
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
