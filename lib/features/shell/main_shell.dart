import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../add_product/presentation/add_product_page.dart';
import '../home/presentation/home_page.dart';
import '../recipes/presentation/recipes_page.dart';
import '../stock/presentation/stock_page.dart';

/// Estrutura principal: header + conteúdo da aba + bottom nav.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppTab _tab = AppTab.inicio;
  String _stockFilter = 'todos';
  int _stockVersion = 0;

  void _showExpiring() => setState(() {
    _stockFilter = 'hoje';
    _stockVersion++;
    _tab = AppTab.estoque;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(title: _tab.label, notificationCount: 3),
      body: IndexedStack(
        index: _tab.index,
        children: [
          HomePage(
            onSeeStock: () => setState(() => _tab = AppTab.estoque),
            onSeeExpiring: _showExpiring,
            onSeeRecipes: () => setState(() => _tab = AppTab.receitas),
          ),
          StockPage(
            key: ValueKey(_stockVersion),
            initialFilter: _stockFilter,
            onSeeRecipes: () => setState(() => _tab = AppTab.receitas),
          ),
          _PlaceholderPage(title: AppTab.compras.label),
          RecipesPage(onSeeUrgentItems: () => setState(() => _tab = AppTab.estoque)),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: _tab,
        shoppingBadge: 4,
        onTabSelected: (tab) => setState(() => _tab = tab),
        onAdd: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AddProductPage())),
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Center(child: Text('$title — em breve', style: AppTextStyles.subtitle));
}
