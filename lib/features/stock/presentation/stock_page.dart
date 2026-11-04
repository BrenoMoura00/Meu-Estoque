import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/product.dart';
import '../../../data/estoque_store.dart';
import '../../../shared/widgets/stock_actions.dart';
import '../../product_detail/presentation/product_detail_page.dart';
import '../../consumption_history/presentation/consumption_history_page.dart';
import '../../waste_report/presentation/waste_report_page.dart';
import '../data/stock_mock_data.dart';
import 'widgets/location_segmented_control.dart';
import 'widgets/status_filter_chips.dart';
import 'widgets/stock_item_card.dart';
import 'widgets/stock_search_bar.dart';
import 'widgets/stock_summary_bar.dart';

/// Tela Estoque (Figma node 12:1057).
/// Filtros (busca, local, status/categoria) funcionam localmente sobre os dados mock.
class StockPage extends StatefulWidget {
  const StockPage({super.key, this.onSeeRecipes, this.initialFilter = 'todos'});

  final String initialFilter;

  /// Abre a aba Receitas (atalho do relatório de desperdício).
  final VoidCallback? onSeeRecipes;

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  static const _all = 'todos';
  static const _today = 'hoje';
  static const _soon = 'em_breve';
  static const _ok = 'no_prazo';

  List<Product> get _items => estoque.produtos;

  void _onStoreChanged() => setState(() {});

  @override
  void initState() {
    super.initState();
    _filterId = widget.initialFilter;
    estoque.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    estoque.removeListener(_onStoreChanged);
    super.dispose();
  }

  String _query = '';
  StorageLocation? _location;
  late String _filterId;

  /// Itens filtrados apenas por busca + local (base para as contagens dos chips).
  List<Product> get _byLocationAndQuery {
    final q = _query.trim().toLowerCase();
    return _items.where((p) {
      if (_location != null && p.location != _location) return false;
      if (q.isNotEmpty && !p.name.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  bool _matchesFilter(Product p) => switch (_filterId) {
        _all => true,
        _today => p.status == ExpiryStatus.today,
        _soon => p.status == ExpiryStatus.soon,
        _ok => p.status == ExpiryStatus.ok,
        final category => p.category == category,
      };

  List<StatusFilter> _filters(List<Product> base) {
    int count(ExpiryStatus s) => base.where((p) => p.status == s).length;
    return [
      StatusFilter(id: _all, label: 'Todos', count: base.length),
      StatusFilter(
        id: _today,
        label: 'Vence Hoje',
        count: count(ExpiryStatus.today),
        dotColor: AppColors.errorBright,
        background: AppColors.errorBright.withValues(alpha: 0.3),
        foreground: AppColors.errorBright,
      ),
      StatusFilter(
        id: _soon,
        label: 'Em ${Product.soonThresholdDays} dias',
        count: count(ExpiryStatus.soon),
        dotColor: AppColors.warning,
        background: AppColors.warning.withValues(alpha: 0.2),
        foreground: AppColors.onWarning,
      ),
      StatusFilter(
        id: _ok,
        label: 'No Prazo',
        count: count(ExpiryStatus.ok),
        dotColor: AppColors.primary,
        background: AppColors.primaryLight.withValues(alpha: 0.2),
        foreground: AppColors.primary,
      ),
      for (final c in {...StockMockData.categoryFilters, 'Carnes', 'Bebidas', 'Outros'}) StatusFilter(id: c, label: c),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final base = _byLocationAndQuery;
    final visible = base.where(_matchesFilter).toList();
    final totalValue = _items.fold<double>(0, (s, p) => s + p.price);
    final locationCounts = {
      for (final loc in StorageLocation.values) loc: _items.where((p) => p.location == loc).length,
    };

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16, padding.top, 16, 0),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(builder: (_) => const ConsumptionHistoryPage()),
                          ),
                          icon: const Icon(Icons.history, size: 19),
                          label: const Text('Histórico'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            final nav = Navigator.of(context);
                            nav.push(MaterialPageRoute<void>(
                              builder: (_) => WasteReportPage(
                                onSeeRecipes: () {
                                  nav.popUntil((route) => route.isFirst);
                                  widget.onSeeRecipes?.call();
                                },
                              ),
                            ));
                          },
                          icon: const Icon(Icons.bar_chart_outlined, size: 19),
                          label: const Text('Desperdício'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StockSearchBar(onChanged: (v) => setState(() => _query = v)),
                  const SizedBox(height: 12),
                  LocationSegmentedControl(
                    selected: _location,
                    counts: locationCounts,
                    onChanged: (loc) => setState(() => _location = loc),
                  ),
                  const SizedBox(height: 12),
                  StatusFilterChips(
                    filters: _filters(base),
                    selectedId: _filterId,
                    onChanged: (id) => setState(() => _filterId = id),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            if (visible.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 48),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Nenhum item encontrado',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => StockItemCard(
                    product: visible[i],
                    onConsume: () => consumirComDesfazer(context, visible[i]),
                    onDiscard: () => descartarComDesfazer(context, visible[i]),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => ProductDetailPage(product: visible[i], onSeeRecipes: widget.onSeeRecipes)),
                    ),
                  ),
                ),
              ),
            // Espaço para a barra de resumo flutuante + bottom nav.
            SliverToBoxAdapter(child: SizedBox(height: padding.bottom + StockSummaryBar.height + 40)),
          ],
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: padding.bottom + 16,
          child: StockSummaryBar(itemCount: _items.length, totalValue: totalValue),
        ),
      ],
    );
  }
}
