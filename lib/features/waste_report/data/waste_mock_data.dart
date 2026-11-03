import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/category_tone.dart';

/// Motivo do descarte (cor da barra/legenda).
enum WasteReason {
  vencimento('Vencimento', AppColors.red500),
  sobras('Sobras', AppColors.amber400),
  deteriorado('Deteriorado', AppColors.gray400);

  const WasteReason(this.label, this.color);
  final String label;
  final Color color;
}

/// Um item descartado.
class WasteEntry {
  const WasteEntry({
    required this.name,
    required this.emoji,
    required this.tone,
    required this.reason,
    required this.detail,
    required this.place,
    required this.value,
    required this.outcome,
  });

  final String name;
  final String emoji;
  final CategoryTone tone;
  final WasteReason reason;

  /// Ex.: "Venceu há 2 dias", "Mofo no pacote".
  final String detail;

  /// Onde estava (local ou categoria).
  final String place;

  /// Valor perdido em R$.
  final double value;

  /// Rótulo final (ex.: "Vencido", "Descartado", "Mofado").
  final String outcome;
}

abstract final class WasteMockData {
  /// Diferença de prejuízo em relação ao mês passado (positivo = piorou).
  static const deltaVsLastMonth = 42.0;
  static const discardedCount = 14;
  static const weightKg = 3.2;

  /// Valor perdido por motivo no mês.
  static const byReason = {WasteReason.vencimento: 130.80, WasteReason.sobras: 50.30, WasteReason.deteriorado: 20.26};

  static double get totalLoss => byReason.values.fold(0, (sum, v) => sum + v);

  static const recent = [
    WasteEntry(
      name: 'Queijo Brie 200g',
      emoji: '🧀',
      tone: CategoryTone.orange,
      reason: WasteReason.vencimento,
      detail: 'Venceu há 2 dias',
      place: 'Geladeira',
      value: 38.90,
      outcome: 'Vencido',
    ),
    WasteEntry(
      name: 'Salmão Fresco 400g',
      emoji: '🐟',
      tone: CategoryTone.red,
      reason: WasteReason.vencimento,
      detail: 'Venceu há 4 dias',
      place: 'Peixaria',
      value: 49.90,
      outcome: 'Descartado',
    ),
    WasteEntry(
      name: 'Iogurte Grego (4 un)',
      emoji: '🥛',
      tone: CategoryTone.blue,
      reason: WasteReason.vencimento,
      detail: 'Venceu há 1 sem',
      place: 'Laticínios',
      value: 22.00,
      outcome: 'Vencido',
    ),
    WasteEntry(
      name: 'Alface e Tomates',
      emoji: '🥗',
      tone: CategoryTone.emerald,
      reason: WasteReason.deteriorado,
      detail: 'Estragou antes',
      place: 'Gaveta Horta',
      value: 16.50,
      outcome: 'Deteriorado',
    ),
    WasteEntry(
      name: 'Pão de Forma Integral',
      emoji: '🍞',
      tone: CategoryTone.amber,
      reason: WasteReason.deteriorado,
      detail: 'Mofo no pacote',
      place: 'Despensa',
      value: 12.80,
      outcome: 'Mofado',
    ),
    WasteEntry(
      name: 'Requeijão Cremoso',
      emoji: '🍶',
      tone: CategoryTone.slate,
      reason: WasteReason.vencimento,
      detail: 'Venceu há 3 dias',
      place: 'Porta da Geladeira',
      value: 9.50,
      outcome: 'Vencido',
    ),
  ];
}
