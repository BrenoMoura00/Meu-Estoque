import 'package:flutter/material.dart';

import '../../../data/estoque_store.dart';
import '../../../data/relatorios.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stock_actions.dart';
import '../../consumption_history/presentation/consumption_history_page.dart';
import '../../recipes/data/recipes_mock_data.dart';
import '../data/home_mock_data.dart';
import 'widgets/category_chips.dart';
import 'widgets/expiring_today_banner.dart';
import 'widgets/recent_item_card.dart';
import 'widgets/recipe_suggestion_banner.dart';
import 'widgets/savings_pill.dart';
import 'widgets/storage_summary_card.dart';

/// Tela Início (Figma node 12:689).
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onSeeStock, this.onSeeRecipes});

  final VoidCallback? onSeeStock;
  final VoidCallback? onSeeRecipes;

  static const _gap = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    // O Scaffold (extendBody/extendBodyBehindAppBar) já inclui a altura do
    // header e da bottom nav neste padding.
    return ListenableBuilder(listenable: estoque, builder: (context, _) => _build(context));
  }

  /// Capacidade aproximada de cada local (itens), usada na barra de ocupação.
  static const _capacidade = {StorageLocation.geladeira: 24, StorageLocation.despensa: 64, StorageLocation.freezer: 32};

  Widget _build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final produtos = estoque.produtos;
    final hoje = produtos.where((p) => p.status == ExpiryStatus.today).toList();
    final storage = [
      for (final loc in StorageLocation.values)
        StorageSummary(
          location: loc,
          count: produtos.where((p) => p.location == loc).length,
          occupancy: produtos.where((p) => p.location == loc).length / _capacidade[loc]!,
        ),
    ];
    final totalItems = produtos.length;
    final economia = economiaDoMes(estoque.movimentos, estoque.now());

    return ListView(
      padding: EdgeInsets.fromLTRB(16, padding.top, 16, padding.bottom + 32),
      children: [
        ExpiringTodayBanner(products: hoje, valueAtRisk: hoje.fold(0, (s, p) => s + p.price)),
        _gap,
        SavingsPill(
          amount: economia.valor,
          growthPercent: economia.crescimento ?? 0,
          onTap: () =>
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ConsumptionHistoryPage())),
        ),
        _gap,
        CategoryChips(categories: HomeMockData.categories),
        _gap,
        SectionHeader(title: 'Resumo do Estoque', trailing: '$totalItems itens no total'),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < storage.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: StorageSummaryCard(summary: storage[i])),
              ],
            ],
          ),
        ),
        _gap,
        SectionHeader(title: 'Últimos itens cadastrados', trailing: 'Ver estoque', onTrailingTap: onSeeStock ?? () {}),
        const SizedBox(height: 8),
        for (final item in estoque.recentes(4)) ...[
          RecentItemCard(
            product: item,
            onConsumed: () => consumirComDesfazer(context, item),
            onDiscard: () => descartarComDesfazer(context, item),
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        RecipeSuggestionBanner(recipeCount: RecipesMockData.recipes.length, onTap: onSeeRecipes),
      ],
    );
  }
}
