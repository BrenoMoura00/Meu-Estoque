import '../core/theme/category_tone.dart';
import '../features/consumption_history/data/consumption_mock_data.dart';
import '../features/waste_report/data/waste_mock_data.dart';
import 'estoque_store.dart';

/// Emoji e tom de cor padrão de cada categoria (quando o item não tem emoji próprio).
({String emoji, CategoryTone tone}) estiloCategoria(String? categoria) => switch (categoria) {
  'Laticínios' => (emoji: '🥛', tone: CategoryTone.blue),
  'Hortifrúti' => (emoji: '🥬', tone: CategoryTone.emerald),
  'Carnes' => (emoji: '🍗', tone: CategoryTone.orange),
  'Grãos' => (emoji: '🍚', tone: CategoryTone.slate),
  'Bebidas' => (emoji: '🧃', tone: CategoryTone.amber),
  'Limpeza' => (emoji: '🧴', tone: CategoryTone.slate),
  'Outros' => (emoji: '🛒', tone: CategoryTone.yellow),
  _ => (emoji: '🛒', tone: CategoryTone.slate),
};

/// Primeiro dia (inclusive) de cada período, a partir de [agora].
DateTime inicioDoPeriodo(ConsumptionPeriod p, DateTime agora) {
  final hoje = DateTime(agora.year, agora.month, agora.day);
  return switch (p) {
    ConsumptionPeriod.thisMonth => DateTime(agora.year, agora.month, 1),
    ConsumptionPeriod.last30Days => DateTime(hoje.year, hoje.month, hoje.day - 29),
    ConsumptionPeriod.threeMonths => DateTime(hoje.year, hoje.month, hoje.day - 89),
    ConsumptionPeriod.thisYear => DateTime(agora.year, 1, 1),
  };
}

bool _noMes(DateTime d, DateTime ref) => d.year == ref.year && d.month == ref.month;

// ---------------------------------------------------------------- Consumo

class ResumoConsumo {
  const ResumoConsumo({
    required this.consumidos,
    required this.aproveitamento,
    required this.porItem,
    required this.porCategoria,
    required this.dicaItens,
    required this.dicaPercentual,
    required this.dicaEconomia,
  });

  /// Nº de itens consumidos no período.
  final int consumidos;

  /// consumidos ÷ (consumidos + desperdiçados), em %; null se não houver registros.
  final int? aproveitamento;
  final List<ConsumptionEntry> porItem;
  final List<ConsumptionEntry> porCategoria;

  /// Itens de maior gasto no período (até 2), % que representam e economia estimada (10%, múltiplo de R$ 5).
  final List<String> dicaItens;
  final int dicaPercentual;
  final double dicaEconomia;
}

ResumoConsumo resumoConsumo(List<Movimento> movs, ConsumptionPeriod periodo, DateTime agora) {
  final inicio = inicioDoPeriodo(periodo, agora);
  final noPeriodo = movs.where((m) => !m.data.isBefore(inicio) && !m.data.isAfter(agora)).toList();
  final consumidos = noPeriodo.where((m) => m.tipo == TipoMovimento.consumido).toList();

  List<ConsumptionEntry> agrupar(String Function(Movimento) chave, {required bool porCategoria}) {
    final grupos = <String, List<Movimento>>{};
    for (final m in consumidos) {
      grupos.putIfAbsent(chave(m), () => []).add(m);
    }
    final lista = [
      for (final g in grupos.entries)
        () {
          final primeiro = g.value.first;
          final estilo = estiloCategoria(primeiro.categoria);
          final vezes = g.value.length;
          final unidades = g.value.fold(0, (s, m) => s + m.unidades);
          final nomes = g.value.map((m) => m.nome).toSet().length;
          return ConsumptionEntry(
            name: porCategoria ? (primeiro.categoria ?? 'Outros') : primeiro.nome,
            emoji: porCategoria ? estilo.emoji : (primeiro.emoji ?? estilo.emoji),
            category: porCategoria ? (nomes == 1 ? '1 item' : '$nomes itens') : (primeiro.categoria ?? 'Outros'),
            tone: estilo.tone,
            times: vezes,
            amountLabel: porCategoria ? '${vezes}x no período' : '${vezes}x • $unidades un',
            totalValue: g.value.fold(0.0, (s, m) => s + m.valor),
          );
        }(),
    ]..sort((a, b) => b.times != a.times ? b.times.compareTo(a.times) : b.totalValue.compareTo(a.totalValue));
    return lista;
  }

  final porItem = agrupar((m) => m.nome.toLowerCase(), porCategoria: false);
  final total = porItem.fold(0.0, (s, e) => s + e.totalValue);
  final topo = ([...porItem]..sort((a, b) => b.totalValue.compareTo(a.totalValue))).take(2).toList();
  final valorTopo = topo.fold(0.0, (s, e) => s + e.totalValue);

  return ResumoConsumo(
    consumidos: consumidos.length,
    aproveitamento: noPeriodo.isEmpty ? null : (consumidos.length * 100 / noPeriodo.length).round(),
    porItem: porItem,
    porCategoria: agrupar((m) => m.categoria ?? 'Outros', porCategoria: true),
    dicaItens: [for (final e in topo) e.name],
    dicaPercentual: total == 0 ? 0 : (valorTopo * 100 / total).round(),
    dicaEconomia: total == 0 ? 0 : valorTopo * 0.10,
  );
}

/// "Economia inteligente do mês": valor consumido enquanto vencia (≤ limiar de "vence em breve"),
/// e a variação % em relação ao mês anterior (null se o mês anterior for zero).
({double valor, int? crescimento}) economiaDoMes(List<Movimento> movs, DateTime agora) {
  final anterior = DateTime(agora.year, agora.month - 1, 1);
  double soma(DateTime ref) => movs
      .where((m) => m.tipo == TipoMovimento.consumido && m.diasParaVencer <= 4 && _noMes(m.data, ref))
      .fold(0.0, (s, m) => s + m.valor);
  final atual = soma(agora);
  final antes = soma(anterior);
  return (valor: atual, crescimento: antes == 0 ? null : ((atual - antes) * 100 / antes).round());
}

// ---------------------------------------------------------------- Desperdício

class ResumoDesperdicio {
  const ResumoDesperdicio({
    required this.total,
    required this.variacao,
    required this.quantidade,
    required this.pesoKg,
    required this.porMotivo,
    required this.recentes,
  });

  final double total;

  /// Diferença para o mês anterior (positivo = prejuízo maior).
  final double variacao;
  final int quantidade;
  final double pesoKg;
  final Map<WasteReason, double> porMotivo;
  final List<WasteEntry> recentes;
}

ResumoDesperdicio resumoDesperdicio(List<Movimento> movs, DateTime agora, {int recentes = 6}) {
  final descartes = movs.where((m) => m.tipo == TipoMovimento.desperdicado).toList();
  final doMes = descartes.where((m) => _noMes(m.data, agora)).toList()..sort((a, b) => b.data.compareTo(a.data));
  final anterior = DateTime(agora.year, agora.month - 1, 1);
  final totalAnterior = descartes.where((m) => _noMes(m.data, anterior)).fold(0.0, (s, m) => s + m.valor);
  final total = doMes.fold(0.0, (s, m) => s + m.valor);

  return ResumoDesperdicio(
    total: total,
    variacao: total - totalAnterior,
    quantidade: doMes.length,
    pesoKg: doMes.fold(0.0, (s, m) => s + m.pesoKg),
    porMotivo: {
      for (final r in WasteReason.values)
        r: doMes.where((m) => (m.motivo ?? WasteReason.vencimento) == r).fold(0.0, (s, m) => s + m.valor),
    },
    recentes: [for (final m in doMes.take(recentes)) _paraEntrada(m)],
  );
}

WasteEntry _paraEntrada(Movimento m) {
  final motivo = m.motivo ?? WasteReason.vencimento;
  final estilo = estiloCategoria(m.categoria);
  final dias = m.diasParaVencer;
  final detalhe = switch (motivo) {
    WasteReason.vencimento when dias <= -7 => 'Venceu há ${-dias ~/ 7} sem',
    WasteReason.vencimento when dias < 0 => 'Venceu há ${-dias} ${dias == -1 ? 'dia' : 'dias'}',
    WasteReason.vencimento when dias == 0 => 'Venceu hoje',
    WasteReason.vencimento => 'Descartado antes',
    WasteReason.deteriorado => 'Estragou antes',
    WasteReason.sobras => 'Sobra descartada',
  };
  return WasteEntry(
    name: m.nome,
    emoji: m.emoji ?? estilo.emoji,
    tone: estilo.tone,
    reason: motivo,
    detail: detalhe,
    place: m.local.isEmpty ? '—' : m.local,
    value: m.valor,
    outcome: switch (motivo) {
      WasteReason.vencimento => 'Vencido',
      WasteReason.sobras => 'Descartado',
      WasteReason.deteriorado => 'Deteriorado',
    },
  );
}
