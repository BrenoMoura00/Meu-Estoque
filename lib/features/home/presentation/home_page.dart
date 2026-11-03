import 'package:flutter/material.dart';

import '../../../shared/widgets/section_header.dart';
import '../../consumption_history/presentation/consumption_history_page.dart';
import '../data/home_mock_data.dart';
import 'widgets/category_chips.dart';
import 'widgets/expiring_today_banner.dart';
import 'widgets/recent_item_card.dart';
import 'widgets/recipe_suggestion_banner.dart';
import 'widgets/savings_pill.dart';
import 'widgets/storage_summary_card.dart';

/// Tela Início (Figma node 12:689).
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onSeeStock});

  final VoidCallback? onSeeStock;

  static const _gap = SizedBox(height: 24);

  @override
  Widget build(BuildContext context) {
    // O Scaffold (extendBody/extendBodyBehindAppBar) já inclui a altura do
    // header e da bottom nav neste padding.
    final padding = MediaQuery.paddingOf(context);
    final storage = HomeMockData.storage;
    final totalItems = storage.fold<int>(0, (sum, s) => sum + s.count);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, padding.top, 16, padding.bottom + 32),
      children: [
        const ExpiringTodayBanner(
          products: HomeMockData.expiringToday,
          valueAtRisk: HomeMockData.valueAtRiskToday,
        ),
        _gap,
        SavingsPill(
          amount: HomeMockData.monthlySavings,
          growthPercent: HomeMockData.savingsGrowth,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ConsumptionHistoryPage()),
          ),
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
        for (final item in HomeMockData.recentItems) ...[
          RecentItemCard(product: item),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 16),
        const RecipeSuggestionBanner(recipeCount: 3),
      ],
    );
  }
}
