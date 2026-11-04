import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/estoque_store.dart';
import '../../../data/relatorios.dart';
import '../../../shared/widgets/app_title_top_bar.dart';
import '../../add_product/data/add_product_options.dart';
import 'widgets/avoid_waste_tip_card.dart';
import 'widgets/loss_summary_card.dart';
import 'widgets/waste_item_card.dart';
import 'widgets/waste_reasons_card.dart';

/// Tela Desperdício de Alimentos (Figma node 12:1396). Rota empilhada.
class WasteReportPage extends StatelessWidget {
  const WasteReportPage({super.key, this.onSeeRecipes});

  /// "Ver Receitas Rápidas" (abre a aba Receitas do MainShell).
  final VoidCallback? onSeeRecipes;

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: estoque,
      builder: (context, _) => _buildReport(context),
    );
  }

  Widget _buildReport(BuildContext context) {
    final resumo = resumoDesperdicio(estoque.movimentos, estoque.now());
    final recent = resumo.recentes;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppTitleTopBar(
        title: 'Desperdício de Alimentos',
        outlined: true,
        actionIcon: AppIcons.shareUpload,
        actionTooltip: 'Compartilhar relatório',
        onAction: () => _toast(context, 'Compartilhamento em breve'),
      ),
      body: Builder(
        builder: (context) {
          final padding = MediaQuery.paddingOf(context);
          return ListView(
            padding: EdgeInsets.fromLTRB(20, padding.top + 16, 20, padding.bottom + 48),
            children: [
              LossSummaryCard(
                total: resumo.total,
                delta: resumo.variacao,
                discardedCount: resumo.quantidade,
                weightKg: resumo.pesoKg,
              ),
              const SizedBox(height: 24),
              WasteReasonsCard(byReason: resumo.porMotivo, periodLabel: formatMonthYear(estoque.now())),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Itens Descartados',
                          style: AppTextStyles.rank.copyWith(fontWeight: FontWeight.w700, color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Histórico de produtos perdidos',
                          style: AppTextStyles.body.copyWith(height: 16 / 12, color: AppColors.slate500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.emerald50, borderRadius: BorderRadius.circular(999)),
                    child: Text(
                      '${recent.length} mais recentes',
                      style: AppTextStyles.label.copyWith(letterSpacing: 0, color: AppColors.emerald600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(child: Text('Nenhum descarte registrado neste mês.')),
                ),
              for (var i = 0; i < recent.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                WasteItemCard(entry: recent[i]),
              ],
              const SizedBox(height: 24),
              AvoidWasteTipCard(
                notifyDaysBefore: AddProductOptions.notifyDaysBefore,
                // TODO: abrir configurações de notificação quando existirem.
                onAdjustNotifications: () => _toast(context, 'Configurações de notificação em breve'),
                onSeeRecipes: onSeeRecipes,
              ),
            ],
          );
        },
      ),
    );
  }
}
