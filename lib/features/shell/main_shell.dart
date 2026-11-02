import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../shared/widgets/app_top_bar.dart';
import '../home/presentation/home_page.dart';
import '../stock/presentation/stock_page.dart';

/// Estrutura principal: header + conteúdo da aba + bottom nav.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  AppTab _tab = AppTab.inicio;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppTopBar(title: _tab.label, notificationCount: 3),
      body: IndexedStack(
        index: _tab.index,
        children: [
          HomePage(onSeeStock: () => setState(() => _tab = AppTab.estoque)),
          const StockPage(),
          for (final tab in AppTab.values.skip(2)) _PlaceholderPage(title: tab.label),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        current: _tab,
        shoppingBadge: 4,
        onTabSelected: (tab) => setState(() => _tab = tab),
        onAdd: () {
          // TODO: abrir fluxo "Adicionar alimento" quando a tela existir no Figma.
        },
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) =>
      Center(child: Text('$title — em breve', style: AppTextStyles.subtitle));
}
