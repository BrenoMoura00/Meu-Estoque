import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/estoque_store.dart';
import '../../../data/receitas.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/choice_pill_bar.dart';
import '../data/recipes_mock_data.dart';
import 'widgets/recipe_card.dart';
import 'widgets/recipe_steps_sheet.dart';
import 'widgets/zero_waste_banner.dart';

enum _RecipeFilter { todos, vencendoHoje, rapidas, vegetariano, sobremesas, semGluten }

/// Tela Receitas Rápidas (Figma node 12:2002), aba "Receitas" do MainShell.
class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key, this.onSeeUrgentItems});

  /// "Ver N itens" do banner (abre o estoque).
  final VoidCallback? onSeeUrgentItems;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  static const _quickMinutes = 15;

  _RecipeFilter _filter = _RecipeFilter.todos;

  bool _matches(Recipe r, _RecipeFilter f) => switch (f) {
    _RecipeFilter.todos => true,
    _RecipeFilter.vencendoHoje => r.urgency == ExpiryStatus.today,
    _RecipeFilter.rapidas => r.minutes <= _quickMinutes,
    _RecipeFilter.vegetariano => r.tags.contains(RecipeTag.vegetariano),
    _RecipeFilter.sobremesas => r.tags.contains(RecipeTag.sobremesa),
    _RecipeFilter.semGluten => r.tags.contains(RecipeTag.semGluten),
  };

  int _count(List<ReceitaCalculada> todas, _RecipeFilter f) => todas.where((c) => _matches(c.receita, f)).length;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) =>
      ListenableBuilder(listenable: estoque, builder: (context, _) => _build(context));

  Widget _build(BuildContext context) {
    // O Scaffold do MainShell já inclui header e bottom nav neste padding.
    final padding = MediaQuery.paddingOf(context);
    final produtos = estoque.produtos;
    final todas = receitasComEstoque(RecipesMockData.recipes, produtos);
    final calcs = todas.where((c) => _matches(c.receita, _filter)).toList();
    final recipes = [for (final c in calcs) c.receita];
    final urgentes = produtos.where((p) => p.isExpiringSoon).toList();
    final usadosUrgentes = {for (final c in todas) ...c.urgentes};

    final options = [
      ChoicePill(_RecipeFilter.todos, 'Todos (${_count(todas, _RecipeFilter.todos)})'),
      ChoicePill(
        _RecipeFilter.vencendoHoje,
        'Vencendo Hoje (${_count(todas, _RecipeFilter.vencendoHoje)})',
        dotColor: AppColors.rose500,
      ),
      const ChoicePill(_RecipeFilter.rapidas, '⚡ Até $_quickMinutes min'),
      const ChoicePill(_RecipeFilter.vegetariano, '🌱 Vegetariano'),
      const ChoicePill(_RecipeFilter.sobremesas, '🥖 Sobremesas'),
      const ChoicePill(_RecipeFilter.semGluten, 'Sem Glúten'),
    ];

    return ListView(
      padding: EdgeInsets.fromLTRB(16, padding.top + 16, 16, padding.bottom + 32),
      children: [
        ZeroWasteBanner(
          savings: usadosUrgentes.fold(0.0, (s, p) => s + p.price),
          urgentItems: [for (final p in urgentes) p.name],
          urgentToday: {
            for (final p in urgentes)
              if (p.expiresToday) p.name,
          },
          onSeeItems: widget.onSeeUrgentItems,
        ),
        const SizedBox(height: 20),
        ChoicePillBar<_RecipeFilter>(
          options: options,
          selected: _filter,
          onChanged: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 20),
        if (recipes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('Nenhuma receita para este filtro.', style: AppTextStyles.body)),
          ),
        for (var i = 0; i < recipes.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          RecipeCard(
            recipe: recipes[i],
            isFavorite: estoque.favoritas.contains(recipes[i].name),
            onToggleFavorite: () => estoque.alternarFavorita(recipes[i].name),
            onOpen: () => mostrarPreparo(context, calcs[i], produtos),
            // TODO: integrar com a lista de compras.
            onAddMissing: () => _toast('${recipes[i].missingIngredients.join(', ')} adicionado à lista de compras'),
          ),
        ],
      ],
    );
  }
}
