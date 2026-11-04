import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/estoque_store.dart';
import '../../../data/relatorios.dart';
import '../../../shared/widgets/app_title_top_bar.dart';
import '../../../shared/widgets/choice_pill_bar.dart';
import '../data/consumption_mock_data.dart';
import 'widgets/consumption_rank_card.dart';
import 'widgets/consumption_summary_card.dart';
import 'widgets/history_view_toggle.dart';

import 'widgets/saving_tip_card.dart';

/// Tela Histórico de Consumo (Figma node 12:1821). Rota empilhada.
class ConsumptionHistoryPage extends StatefulWidget {
  const ConsumptionHistoryPage({super.key});

  @override
  State<ConsumptionHistoryPage> createState() => _ConsumptionHistoryPageState();
}

class _ConsumptionHistoryPageState extends State<ConsumptionHistoryPage> {
  static const _side = 20.0;

  HistoryView _view = HistoryView.mostConsumed;
  // TODO: filtrar os dados pelo período quando houver histórico real.
  ConsumptionPeriod _period = ConsumptionPeriod.thisMonth;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final resumo = resumoConsumo(estoque.movimentos, _period, estoque.now());
    final ranking = _view == HistoryView.mostConsumed ? resumo.porItem : resumo.porCategoria;
    final maxTimes = ranking.isEmpty ? 1 : ranking.first.times;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppTitleTopBar(
        title: 'Histórico de Consumo',
        actionIcon: AppIcons.filterFunnel,
        actionTooltip: 'Filtrar histórico',
        onAction: () {},
      ),
      body: Builder(
        // Builder para ler o padding já com a altura do header.
        builder: (context) {
          final top = MediaQuery.paddingOf(context).top;
          return ListView(
            padding: EdgeInsets.fromLTRB(_side, top + 16, _side, padding.bottom + 24),
            children: [
              HistoryViewToggle(selected: _view, onChanged: (v) => setState(() => _view = v)),
              const SizedBox(height: 14),
              ChoicePillBar<ConsumptionPeriod>(
                options: [
                  for (final p in ConsumptionPeriod.values)
                    ChoicePill(
                      p,
                      p == ConsumptionPeriod.thisMonth ? 'Este Mês (${formatMonthShort(estoque.now())})' : p.label,
                    ),
                ],
                selected: _period,
                sidePadding: _side,
                dense: true,
                onChanged: (p) => setState(() => _period = p),
              ),
              const SizedBox(height: 16),
              ConsumptionSummaryCard(totalItems: resumo.consumidos, efficiencyPercent: resumo.aproveitamento ?? 0),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    _view == HistoryView.mostConsumed ? 'Ranking de Itens' : 'Ranking de Categorias',
                    style: AppTextStyles.bodyStrong.copyWith(letterSpacing: -0.35, color: AppColors.ink),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Classificado por frequência',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium.copyWith(height: 16 / 12, color: AppColors.slate500),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < ranking.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                ConsumptionRankCard(rank: i + 1, entry: ranking[i], frequency: ranking[i].times / maxTimes),
              ],
              const SizedBox(height: 24),
              if (resumo.dicaItens.isNotEmpty)
                SavingTipCard(
                  items: resumo.dicaItens,
                  sharePercent: resumo.dicaPercentual,
                  savings: resumo.dicaEconomia,
                ),
            ],
          );
        },
      ),
    );
  }
}
