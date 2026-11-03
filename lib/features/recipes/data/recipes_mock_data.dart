import '../../../core/constants/app_assets.dart';
import '../../../models/product.dart';

enum RecipeTag { vegetariano, sobremesa, semGluten }

/// Destaque de aproveitamento do card: verde quando usa tudo, âmbar quando falta algo.
class RecipeHighlight {
  const RecipeHighlight({required this.emoji, required this.lead, required this.detail, required this.tag});

  final String emoji;

  /// Parte em negrito (ex.: "Usa 2 itens críticos:").
  final String lead;
  final String detail;

  /// Selo à direita (ex.: "Salva 100%").
  final String tag;
}

class Recipe {
  const Recipe({
    required this.name,
    required this.image,
    required this.minutes,
    required this.difficulty,
    required this.yieldLabel,
    required this.highlight,
    required this.ingredientsTotal,
    this.missingIngredients = const [],
    this.expiresInDays,
    this.tip,
    this.tags = const {},
  });

  final String name;
  final String image;
  final int minutes;
  final String difficulty;

  /// Rendimento com emoji (ex.: "🍳 1 porção").
  final String yieldLabel;
  final RecipeHighlight highlight;
  final int ingredientsTotal;
  final List<String> missingIngredients;

  /// Dias até vencer o ingrediente mais urgente (null = nenhum urgente).
  final int? expiresInDays;

  /// Selo neutro quando não há urgência (ex.: "💡 Prático de liquidificador").
  final String? tip;
  final Set<RecipeTag> tags;

  int get ingredientsAvailable => ingredientsTotal - missingIngredients.length;
  bool get hasAllIngredients => missingIngredients.isEmpty;

  /// Urgência pelo mesmo critério de validade dos produtos.
  ExpiryStatus? get urgency {
    final days = expiresInDays;
    if (days == null) return null;
    if (days <= 0) return ExpiryStatus.today;
    return days <= Product.soonThresholdDays ? ExpiryStatus.soon : ExpiryStatus.ok;
  }
}

abstract final class RecipesMockData {
  static const potentialSavings = 48.0;
  static const urgentItems = ['Leite', 'Tomate', 'Queijo'];

  /// Itens urgentes que vencem hoje (os demais vencem em breve).
  static const urgentToday = {'Leite', 'Tomate'};

  static const recipes = [
    Recipe(
      name: 'Omelete Cremosa com Tomate e Queijo',
      image: AppImages.receitaOmelete,
      minutes: 10,
      difficulty: 'Fácil',
      yieldLabel: '🍳 1 porção',
      expiresInDays: 0,
      ingredientsTotal: 4,
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(
        emoji: '🍅',
        lead: 'Usa 2 itens críticos:',
        detail: 'Tomate Rama e Queijo Prato',
        tag: 'Salva 100%',
      ),
    ),
    Recipe(
      name: 'Panqueca Rápida de Leite e Mel',
      image: AppImages.receitaPanqueca,
      minutes: 15,
      difficulty: 'Fácil',
      yieldLabel: '🥞 6 unid.',
      expiresInDays: 1,
      ingredientsTotal: 4,
      tags: {RecipeTag.vegetariano, RecipeTag.sobremesa},
      highlight: RecipeHighlight(
        emoji: '🥛',
        lead: 'Usa 400ml:',
        detail: 'Leite Integral aberto',
        tag: 'Economize R\$ 6',
      ),
    ),
    Recipe(
      name: 'Molho Rústico de Tomates Assados',
      image: AppImages.receitaMolhoTomate,
      minutes: 25,
      difficulty: 'Médio',
      yieldLabel: '🍝 4 porções',
      expiresInDays: 0,
      ingredientsTotal: 4,
      missingIngredients: ['Manjericão'],
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(emoji: '🍅', lead: 'Aproveita:', detail: '6 Tomates maduros', tag: 'Falta 1 item'),
    ),
    Recipe(
      name: 'Torta Salgada de Frango e Requeijão',
      image: AppImages.receitaTortaFrango,
      minutes: 35,
      difficulty: 'Fácil',
      yieldLabel: '🥧 8 pedaços',
      tip: '💡 Prático de liquidificador',
      ingredientsTotal: 5,
      highlight: RecipeHighlight(
        emoji: '🍗',
        lead: 'Usa sobras de:',
        detail: 'Frango Desfiado + Ovos',
        tag: 'Zero Perda',
      ),
    ),
    Recipe(
      name: 'Smoothie Gelado de Iogurte & Banana',
      image: AppImages.receitaSmoothie,
      minutes: 5,
      difficulty: 'Muito Fácil',
      yieldLabel: '🥤 2 copos',
      expiresInDays: 1,
      ingredientsTotal: 3,
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(
        emoji: '🍌',
        lead: 'Salva:',
        detail: 'Iogurte Natural + Banana Madura',
        tag: 'Salva 100%',
      ),
    ),
  ];
}
