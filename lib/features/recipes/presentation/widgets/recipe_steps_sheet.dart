import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/receitas.dart';
import '../../../../models/product.dart';
import '../../data/recipes_mock_data.dart';

/// Mostra ingredientes (tem / falta / básico) e o modo de preparo da receita.
Future<void> mostrarPreparo(BuildContext context, ReceitaCalculada calc, List<Product> estoque) {
  final r = calc.receita;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.92,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(r.name, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text('⏱️ ${r.minutes} min  •  ${r.difficulty}  •  ${r.yieldLabel}', style: AppTextStyles.body),
          const SizedBox(height: 24),
          Text('Ingredientes', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          for (final ing in r.ingredientes)
            _IngredienteLinha(ing: ing, item: ing.basico ? null : itemPara(ing, estoque)),
          const SizedBox(height: 24),
          Text('Modo de preparo', style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          for (var i = 0; i < r.preparo.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: AppColors.emerald50, shape: BoxShape.circle),
                    child: Text('${i + 1}', style: AppTextStyles.caption.copyWith(color: AppColors.emerald700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(r.preparo[i], style: AppTextStyles.body.copyWith(color: AppColors.onSurface)),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

class _IngredienteLinha extends StatelessWidget {
  const _IngredienteLinha({required this.ing, required this.item});

  final Ingrediente ing;
  final Product? item;

  @override
  Widget build(BuildContext context) {
    final basico = ing.basico;
    final tem = basico || item != null;
    final detalhe = basico
        ? 'Básico da despensa'
        : item == null
        ? 'Falta comprar'
        : '${item!.name} • ${item!.shortRemaining}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            tem ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: tem ? AppColors.emerald500 : AppColors.amber500,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ing.nome, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w500)),
                Text(
                  detalhe,
                  style: AppTextStyles.body.copyWith(color: tem ? AppColors.slate500 : AppColors.amber700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
