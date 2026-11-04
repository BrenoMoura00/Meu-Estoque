import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/estoque_store.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/stock_actions.dart';
import '../../../shared/widgets/app_detail_top_bar.dart';
import '../../../shared/widgets/app_svg.dart';
import '../../add_product/data/add_product_options.dart';
import '../../waste_report/presentation/waste_report_page.dart';
import 'widgets/consumption_notes_card.dart';
import 'widgets/expiry_palette.dart';
import 'widgets/expiry_status_card.dart';
import 'widgets/info_tiles.dart';
import 'widgets/product_summary_card.dart';
import 'widgets/stock_units_card.dart';

/// Tela Detalhes do Item (Figma node 12:332). Rota empilhada a partir do Estoque.
class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.product, this.onSeeRecipes});

  final Product product;

  /// Repassado ao relatório de desperdício ("Ver Receitas Rápidas").
  final VoidCallback? onSeeRecipes;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  /// Versão atual do item no estoque (cai no recebido se já saiu do estoque).
  Product get _product => (widget.product.id == null ? null : estoque.porId(widget.product.id!)) ?? widget.product;

  int get _units => _product.units;

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    estoque.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    estoque.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _finish(String message, {SnackBarAction Function(NavigatorState nav)? action}) {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context)..pop();
    messenger.showSnackBar(SnackBar(content: Text(message), action: action?.call(nav)));
  }

  SnackBarAction _seeWasteReport(NavigatorState nav) => SnackBarAction(
    label: 'Ver relatório',
    onPressed: () => nav.push(
      MaterialPageRoute<void>(
        builder: (_) => WasteReportPage(
          onSeeRecipes: () {
            nav.popUntil((route) => route.isFirst);
            widget.onSeeRecipes?.call();
          },
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final palette = ExpiryPalette.of(p);
    final today = DateUtils.dateOnly(DateTime.now());
    final expiry = today.add(Duration(days: p.daysToExpire));

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: const AppDetailTopBar(title: 'Detalhes do Item'),
      body: Builder(
        builder: (context) {
          final padding = MediaQuery.paddingOf(context);
          return ListView(
            padding: EdgeInsets.fromLTRB(16, padding.top + 4, 16, padding.bottom + 32),
            children: [
              Row(
                children: [
                  if (p.isExpiringSoon) _AlertChip(color: palette.accent),
                  const Spacer(),
                  _IconAction(
                    tooltip: 'Editar produto',
                    onTap: () {},
                    child: const AppSvg(AppIcons.edit, width: 15, height: 15),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    tooltip: 'Compartilhar produto',
                    onTap: () {},
                    child: const AppSvg(AppIcons.share, width: 15, height: 16.67),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ProductSummaryCard(product: p),
              const SizedBox(height: 12),
              ExpiryStatusCard(product: p, notifyDaysBefore: AddProductOptions.notifyDaysBefore),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatTile(
                        icon: (asset: AppIcons.calendar, width: 13.5, height: 15),
                        label: 'Validade',
                        value: formatDate(expiry),
                        caption: palette.priority,
                        captionStyle: AppTextStyles.bodyMedium.copyWith(color: palette.priorityColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        icon: (asset: AppIcons.priceTag, width: 14.98, height: 15),
                        label: 'Valor Estimado',
                        value: formatBRL(p.unitPrice * _units),
                        caption: '${formatBRL(p.unitPrice)} / unidade',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              StockUnitsCard(units: _units, onChanged: (v) { if (_product.id != null) estoque.ajustarUnidades(_product.id!, v); }),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: IconInfoTile(
                      icon: (asset: AppIcons.category, width: 14.25, height: 15),
                      iconBackground: AppColors.mint.withValues(alpha: 0.5),
                      label: 'Categoria',
                      value: p.category ?? 'Outros',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: IconInfoTile(
                      icon: (asset: AppIcons.location, width: 13.5, height: 16.5),
                      iconBackground: AppColors.surfaceHigh,
                      label: 'Local',
                      value: p.location.label,
                    ),
                  ),
                ],
              ),
              if (p.notes != null) ...[const SizedBox(height: 8), ConsumptionNotesCard(notes: p.notes!)],
              const SizedBox(height: 24),
              _ActionButton(
                label: 'Marcar como Consumido',
                icon: const AppSvg(AppIcons.checkLarge, width: 13.58, height: 10.02),
                background: AppColors.primary,
                foreground: Colors.white,
                elevated: true,
                onTap: () {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.of(context).pop();
                  consumirComDesfazer(context, p, messenger: messenger);
                },
              ),
              const SizedBox(height: 8),
              _ActionButton(
                label: 'Registrar como Desperdiçado',
                icon: const AppSvg(AppIcons.trashLarge, width: 13.33, height: 15),
                background: AppColors.errorContainerSolid,
                foreground: AppColors.onErrorContainer,
                onTap: () {
                  if (p.id != null) estoque.descartar(p.id!);
                  _finish('"${p.name}" registrado como desperdício', action: _seeWasteReport);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  const _AlertChip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: BorderRadius.circular(999)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('Alerta de consumo', style: AppTextStyles.caption.copyWith(color: AppColors.onSurfaceVariant)),
      ],
    ),
  );
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.child, required this.tooltip, required this.onTap});

  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(width: 40, height: 40, child: Center(child: child)),
    ),
  );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.elevated = false,
  });

  final String label;
  final Widget icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      boxShadow: elevated
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
                spreadRadius: -1,
              ),
            ]
          : null,
    ),
    child: Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: AppTextStyles.subtitle.copyWith(color: foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
