import '../../../core/constants/app_assets.dart';
import '../../../models/product.dart';

enum RecipeTag { vegetariano, sobremesa, semGluten }

/// Ingrediente de uma receita. [termos] (minúsculos, sem acento) são buscados nos nomes do estoque.
/// [basico] = item de despensa assumido como disponível (não entra em "Você tem X/Y").
class Ingrediente {
  const Ingrediente(this.nome, this.termos, {this.basico = false});

  final String nome;
  final List<String> termos;
  final bool basico;
}

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
    this.ingredientes = const [],
    this.preparo = const [],
  });

  final List<Ingrediente> ingredientes;
  final List<String> preparo;

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

/// Catálogo de receitas. Disponibilidade, urgência e destaque são calculados com o estoque
/// (`lib/data/receitas.dart`); os campos fixos abaixo são só o ponto de partida.
abstract final class RecipesMockData {
  static const recipes = [
    Recipe(
      name: 'Omelete Cremosa com Tomate e Queijo',
      image: AppImages.receitaOmelete,
      minutes: 10,
      difficulty: 'Fácil',
      yieldLabel: '🍳 1 porção',
      ingredientsTotal: 0,
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(emoji: '🍅', lead: '', detail: '', tag: ''),
      ingredientes: [
        Ingrediente('Tomate', ['tomate']),
        Ingrediente('Queijo', ['queijo']),
        Ingrediente('Leite', ['leite']),
        Ingrediente('Ovos', ['ovo'], basico: true),
        Ingrediente('Sal', ['sal'], basico: true),
      ],
      preparo: [
        'Bata os ovos com um pouco de leite e uma pitada de sal.',
        'Junte o tomate picado e o queijo.',
        'Cozinhe em frigideira untada, em fogo baixo, por 5 minutos.',
        'Dobre ao meio e sirva.',
      ],
    ),
    Recipe(
      name: 'Panqueca Rápida de Leite e Mel',
      image: AppImages.receitaPanqueca,
      minutes: 15,
      difficulty: 'Fácil',
      yieldLabel: '🥞 6 unid.',
      ingredientsTotal: 0,
      tags: {RecipeTag.vegetariano, RecipeTag.sobremesa},
      highlight: RecipeHighlight(emoji: '🥛', lead: '', detail: '', tag: ''),
      ingredientes: [
        Ingrediente('Leite', ['leite']),
        Ingrediente('Iogurte', ['iogurte']),
        Ingrediente('Farinha', ['farinha'], basico: true),
        Ingrediente('Ovos', ['ovo'], basico: true),
        Ingrediente('Mel', ['mel'], basico: true),
      ],
      preparo: [
        'Misture leite, iogurte, ovos e farinha até ficar liso.',
        'Despeje porções na frigideira quente e untada.',
        'Vire quando formar bolhas na superfície.',
        'Sirva com mel.',
      ],
    ),
    Recipe(
      name: 'Molho Rústico de Tomates Assados',
      image: AppImages.receitaMolhoTomate,
      minutes: 25,
      difficulty: 'Médio',
      yieldLabel: '🍝 4 porções',
      ingredientsTotal: 0,
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(emoji: '🍅', lead: '', detail: '', tag: ''),
      ingredientes: [
        Ingrediente('Tomate', ['tomate']),
        Ingrediente('Queijo Parmesão', ['parmesao']),
        Ingrediente('Manjericão', ['manjericao']),
        Ingrediente('Alho', ['alho'], basico: true),
        Ingrediente('Azeite', ['azeite'], basico: true),
      ],
      preparo: [
        'Corte os tomates ao meio e asse com alho e azeite por 20 minutos.',
        'Amasse grosseiramente com um garfo.',
        'Finalize com manjericão e parmesão ralado.',
      ],
    ),
    Recipe(
      name: 'Torta Salgada de Frango e Requeijão',
      image: AppImages.receitaTortaFrango,
      minutes: 35,
      difficulty: 'Fácil',
      yieldLabel: '🥧 8 pedaços',
      tip: '💡 Prático de liquidificador',
      ingredientsTotal: 0,
      highlight: RecipeHighlight(emoji: '🍗', lead: '', detail: '', tag: ''),
      ingredientes: [
        Ingrediente('Frango', ['frango']),
        Ingrediente('Requeijão', ['requeijao']),
        Ingrediente('Queijo', ['queijo']),
        Ingrediente('Farinha', ['farinha'], basico: true),
        Ingrediente('Ovos', ['ovo'], basico: true),
      ],
      preparo: [
        'Bata no liquidificador ovos, farinha e um pouco de leite.',
        'Misture o frango desfiado, o requeijão e o queijo.',
        'Asse a 200 °C por 30 minutos.',
      ],
    ),
    Recipe(
      name: 'Smoothie Gelado de Iogurte & Banana',
      image: AppImages.receitaSmoothie,
      minutes: 5,
      difficulty: 'Muito Fácil',
      yieldLabel: '🥤 2 copos',
      ingredientsTotal: 0,
      tags: {RecipeTag.vegetariano, RecipeTag.semGluten},
      highlight: RecipeHighlight(emoji: '🍌', lead: '', detail: '', tag: ''),
      ingredientes: [
        Ingrediente('Iogurte', ['iogurte']),
        Ingrediente('Banana', ['banana']),
        Ingrediente('Suco de Laranja', ['suco', 'laranja']),
        Ingrediente('Gelo', ['gelo'], basico: true),
      ],
      preparo: [
        'Bata o iogurte, a banana e o suco de laranja com gelo.',
        'Sirva bem gelado.',
      ],
    ),
  ];
}
