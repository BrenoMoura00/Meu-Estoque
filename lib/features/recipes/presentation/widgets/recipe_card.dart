import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../models/product.dart';
import '../../../../shared/widgets/app_svg.dart';
import '../../data/recipes_mock_data.dart';

/// Card de receita: foto, urgência, metadados, destaque de aproveitamento e CTA.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
    this.onOpen,
    this.onAddMissing,
  });

  final Recipe recipe;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  /// "Ver Preparo".
  final VoidCallback? onOpen;

  /// "+ Lista" (adiciona os ingredientes faltantes à lista de compras).
  final VoidCallback? onAddMissing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          const SizedBox(height: 12),
          _HighlightBox(highlight: recipe.highlight, complete: recipe.hasAllIngredients),
          const SizedBox(height: 12),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    final meta = AppTextStyles.bodyMedium.copyWith(height: 16 / 12, color: AppColors.slate500);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: ColoredBox(
              color: AppColors.slate100,
              child: Image.asset(recipe.image, width: 96, height: 96, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _RecipeBadge(recipe: recipe),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: isFavorite ? 'Remover dos favoritos' : 'Favoritar',
                      child: InkResponse(
                        onTap: onToggleFavorite,
                        radius: 18,
                        child: isFavorite
                            ? const Icon(Icons.favorite, size: 20, color: AppColors.rose500)
                            : const AppSvg(AppIcons.heartOutline, width: 20, height: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  recipe.name,
                  style: AppTextStyles.bodyStrong.copyWith(letterSpacing: 0, height: 19.25 / 14, color: AppColors.ink),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                const SizedBox(height: 8),
                Text(
                  '⏱️ ${recipe.minutes} min  •  ${recipe.difficulty}  •  ${recipe.yieldLabel}',
                  style: meta,
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

  Widget _footer() {
    final complete = recipe.hasAllIngredients;
    final base = AppTextStyles.label.copyWith(letterSpacing: 0);

    return Container(
      padding: const EdgeInsets.only(top: 9),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.slate100)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: complete ? AppColors.emerald500 : AppColors.amber400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: complete
                ? Text(
                    'Você tem ${recipe.ingredientsAvailable}/${recipe.ingredientsTotal} ingredientes',
                    style: base.copyWith(color: AppColors.slate700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : Text.rich(
                    TextSpan(
                      style: base.copyWith(fontWeight: FontWeight.w400, color: AppColors.slate600),
                      children: [
                        const TextSpan(text: 'Tem '),
                        TextSpan(
                          text: '${recipe.ingredientsAvailable}/${recipe.ingredientsTotal}',
                          style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        TextSpan(text: ' (Falta ${recipe.missingIngredients.join(', ')})'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          const SizedBox(width: 8),
          if (complete)
            Material(
              color: AppColors.emerald600,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onOpen,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Text(
                    'Ver Preparo',
                    style: base.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            )
          else
            Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppColors.emerald600),
              ),
              child: InkWell(
                onTap: onAddMissing,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(11, 6, 11, 7),
                  child: Text(
                    '+ Lista',
                    style: AppTextStyles.caption.copyWith(
                      letterSpacing: 0,
                      height: 16.5 / 11,
                      color: AppColors.emerald700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selo do topo: urgência (vence hoje / amanhã) ou dica neutra.
class _RecipeBadge extends StatelessWidget {
  const _RecipeBadge({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final urgency = recipe.urgency;
    final (String label, Color bg, Color? border, Color fg) = switch (urgency) {
      ExpiryStatus.today => ('🔥 Vence hoje', AppColors.rose50, AppColors.rose200, AppColors.rose600),
      ExpiryStatus.soon || ExpiryStatus.ok => (
        recipe.expiresInDays == 1 ? '⏳ Vence amanhã' : '⏳ Vence em ${recipe.expiresInDays} dias',
        AppColors.amber50,
        AppColors.amber200,
        AppColors.amber700,
      ),
      null => (recipe.tip ?? '', AppColors.slate100, null, AppColors.slate700),
    };
    if (label.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: border == null ? 8 : 9, vertical: border == null ? 2 : 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: border == null ? null : Border.all(color: border.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: AppTextStyles.micro.copyWith(fontWeight: FontWeight.w700, height: 15 / 10, color: fg),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Faixa de aproveitamento: verde quando tem tudo, âmbar quando falta ingrediente.
class _HighlightBox extends StatelessWidget {
  const _HighlightBox({required this.highlight, required this.complete});

  final RecipeHighlight highlight;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final bg = complete ? AppColors.emerald50 : AppColors.amber50;
    final border = complete ? AppColors.emerald100 : AppColors.amber200.withValues(alpha: 0.6);
    final fg = complete ? AppColors.emerald900 : AppColors.amber900;
    final tagBg = complete ? AppColors.emerald100 : AppColors.amber100;
    final tagFg = complete ? AppColors.emerald700 : AppColors.amber700;
    final text = AppTextStyles.label.copyWith(letterSpacing: 0, color: fg);

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Text(highlight.emoji, style: AppTextStyles.rank.copyWith(fontWeight: FontWeight.w400)),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: text.copyWith(fontWeight: FontWeight.w700),
                children: [
                  TextSpan(text: highlight.lead),
                  TextSpan(
                    text: ' ${highlight.detail}',
                    style: const TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            constraints: const BoxConstraints(maxWidth: 88),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(6)),
            child: Text(
              highlight.tag,
              style: AppTextStyles.caption.copyWith(letterSpacing: 0, height: 16 / 11, color: tagFg),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
