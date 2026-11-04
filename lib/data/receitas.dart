import '../core/utils/formatters.dart';
import '../features/recipes/data/recipes_mock_data.dart';
import '../models/product.dart';

/// Minúsculas e sem acento, para comparar nomes.
String normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüç';
  const para = 'aaaaaeeeeiiiiooooouuuuc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i < 0 ? ch : para[i]);
  }
  return b.toString();
}

/// Item do estoque que atende o ingrediente (o que vence primeiro), ou null.
Product? itemPara(Ingrediente ing, List<Product> estoque) {
  Product? melhor;
  for (final p in estoque) {
    final nome = normalizar(p.name);
    final casa = ing.termos.any((t) => RegExp('\\b${RegExp.escape(t)}').hasMatch(nome));
    if (casa && (melhor == null || p.daysToExpire < melhor.daysToExpire)) melhor = p;
  }
  return melhor;
}

/// Receita com os campos calculados a partir do estoque, mais os itens usados.
class ReceitaCalculada {
  const ReceitaCalculada(this.receita, this.usados, this.urgentes);

  final Recipe receita;

  /// Itens do estoque que a receita usa.
  final List<Product> usados;

  /// Dos usados, os que vencem hoje ou em breve.
  final List<Product> urgentes;
}

ReceitaCalculada calcularReceita(Recipe r, List<Product> estoque) {
  final principais = r.ingredientes.where((i) => !i.basico).toList();
  final usados = <Product>[];
  final faltando = <String>[];
  for (final ing in principais) {
    final p = itemPara(ing, estoque);
    if (p == null) {
      faltando.add(ing.nome);
    } else if (!usados.contains(p)) {
      usados.add(p);
    }
  }
  final urgentes = usados.where((p) => p.isExpiringSoon).toList();
  final maisUrgente = usados.isEmpty ? null : usados.map((p) => p.daysToExpire).reduce((a, b) => a < b ? a : b);
  final valorUrgente = urgentes.fold(0.0, (s, p) => s + p.price);

  String juntar(List<String> nomes) =>
      nomes.length <= 1 ? nomes.join() : '${nomes.sublist(0, nomes.length - 1).join(', ')} e ${nomes.last}';
  final nomesDestaque = juntar([for (final p in (urgentes.isNotEmpty ? urgentes : usados).take(2)) p.name]);

  final completo = faltando.isEmpty;
  final RecipeHighlight destaque;
  if (completo) {
    destaque = RecipeHighlight(
      emoji: r.highlight.emoji,
      lead: urgentes.isEmpty
          ? 'Usa do estoque:'
          : (urgentes.length == 1 ? 'Usa 1 item crítico:' : 'Usa ${urgentes.length} itens críticos:'),
      detail: nomesDestaque,
      tag: valorUrgente > 0 ? 'Salva ${formatBRL(valorUrgente)}' : 'Tudo em casa',
    );
  } else {
    destaque = RecipeHighlight(
      emoji: r.highlight.emoji,
      lead: usados.isEmpty ? 'Falta comprar:' : 'Aproveita:',
      detail: usados.isEmpty ? juntar(faltando) : nomesDestaque,
      tag: faltando.length == 1 ? 'Falta 1 item' : 'Faltam ${faltando.length} itens',
    );
  }

  return ReceitaCalculada(
    Recipe(
      name: r.name,
      image: r.image,
      minutes: r.minutes,
      difficulty: r.difficulty,
      yieldLabel: r.yieldLabel,
      highlight: destaque,
      ingredientsTotal: principais.length,
      missingIngredients: faltando,
      // Selo de urgência só quando algum ingrediente vence em breve; senão mostra a dica.
      expiresInDays: maisUrgente != null && maisUrgente <= Product.soonThresholdDays ? maisUrgente : null,
      tip: r.tip,
      tags: r.tags,
      ingredientes: r.ingredientes,
      preparo: r.preparo,
    ),
    usados,
    urgentes,
  );
}

/// Todas as receitas calculadas, priorizando as que salvam mais itens urgentes.
List<ReceitaCalculada> receitasComEstoque(List<Recipe> catalogo, List<Product> estoque) {
  final lista = [for (final r in catalogo) calcularReceita(r, estoque)];
  lista.sort((a, b) {
    final u = b.urgentes.length.compareTo(a.urgentes.length);
    if (u != 0) return u;
    final f = a.receita.missingIngredients.length.compareTo(b.receita.missingIngredients.length);
    if (f != 0) return f;
    return a.receita.minutes.compareTo(b.receita.minutes);
  });
  return lista;
}
