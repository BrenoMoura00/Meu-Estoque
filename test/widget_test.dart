import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_estoque/features/consumption_history/presentation/widgets/consumption_rank_card.dart';
import 'package:meu_estoque/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:meu_estoque/features/stock/presentation/widgets/stock_item_card.dart';
import 'package:meu_estoque/features/waste_report/presentation/widgets/waste_item_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meu_estoque/data/estoque_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meu_estoque/main.dart';
import 'package:meu_estoque/models/product.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await estoque.load();
  });

  testWidgets('Tela Início renderiza as seções principais', (tester) async {
    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.pump();

    expect(find.text('Produtos que vencem hoje'), findsOneWidget);
    expect(find.text('Resumo do Estoque'), findsOneWidget);
    expect(find.text('Categorias'), findsOneWidget);
  });

  testWidgets('Adicionar Item: abre pelo "+", exige nome e salva', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.bySemanticsLabel('Adicionar novo alimento'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Item'), findsOneWidget);

    await tester.tap(find.text('Salvar no Estoque'));
    await tester.pump();
    expect(find.text('Informe o nome do produto'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'Tomate Italiano');
    await tester.tap(find.text('+1 semana'));
    await tester.tap(find.text('Salvar no Estoque'));
    await tester.pumpAndSettle();
    expect(find.text('Adicionar Item'), findsNothing);
    expect(find.text('"Tomate Italiano" salvo no estoque'), findsOneWidget);

    await tester.tap(find.text('Estoque').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'italiano');
    await tester.pumpAndSettle();
    expect(find.text('Tomate Italiano'), findsOneWidget);
  });

  testWidgets('Histórico de Consumo: abre pela economia do mês e troca de visão', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Economia inteligente do mês'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de Consumo'), findsOneWidget);
    expect(find.text('Ranking de Itens'), findsOneWidget);
    expect(find.byType(ConsumptionRankCard), findsNWidgets(6));

    await tester.tap(find.text('Por categoria'));
    await tester.pumpAndSettle();
    expect(find.text('Ranking de Categorias'), findsOneWidget);

    await tester.tap(find.byTooltip('Voltar'));
    await tester.pumpAndSettle();
    expect(find.text('Histórico de Consumo'), findsNothing);
  });

  testWidgets('Receitas: aba abre, filtra e favorita', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 3000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Receitas').last);
    await tester.pumpAndSettle();
    expect(find.text('Alerta de Desperdício Zero'), findsOneWidget);
    expect(find.byType(RecipeCard), findsNWidgets(5));

    await tester.tap(find.text('Vencendo Hoje (2)'));
    await tester.pumpAndSettle();
    expect(find.byType(RecipeCard), findsNWidgets(2));

    await tester.tap(find.byTooltip('Favoritar').first);
    await tester.pump();
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);
  });

  testWidgets('Detalhes do Item: abre pelo card do estoque e marca como consumido', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Estoque').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Garrafa de Leite Integral'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do Item'), findsOneWidget);
    expect(find.text('Piracanjuba'), findsOneWidget);
    expect(find.text('2 unidades'), findsOneWidget);

    await tester.tap(find.byTooltip('Aumentar quantidade'));
    await tester.pump();
    expect(find.text('3 unidades'), findsOneWidget);

    await tester.tap(find.text('Marcar como Consumido'));
    await tester.pumpAndSettle();
    expect(find.text('Detalhes do Item'), findsNothing);
    expect(find.text('"Garrafa de Leite Integral" marcado como consumido'), findsOneWidget);
  });

  testWidgets('Desperdício: abre pelo aviso do descarte e leva às receitas', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Estoque').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Garrafa de Leite Integral'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar como Desperdiçado'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver relatório'));
    await tester.pumpAndSettle();
    expect(find.text('Desperdício de Alimentos'), findsOneWidget);
    expect(find.text('R\$ 201,36'), findsOneWidget);
    expect(find.byType(WasteItemCard), findsNWidgets(6));

    await tester.tap(find.text('Ver Receitas Rápidas'));
    await tester.pumpAndSettle();
    expect(find.text('Desperdício de Alimentos'), findsNothing);
    expect(find.text('Alerta de Desperdício Zero'), findsOneWidget);
  });

  testWidgets('Estoque filtra por status e por busca', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 4000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Estoque').last);
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsNWidgets(13));

    await tester.tap(find.text('Vence Hoje'));
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsNWidgets(4));
    expect(find.text('Garrafa de Leite Integral'), findsOneWidget);

    await tester.tap(find.text('Todos').last);
    await tester.enterText(find.byType(TextField), 'feij');
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsOneWidget);
    expect(find.text('Feijão Carioca Nobre'), findsOneWidget);

    // Consumir tira do estoque; Desfazer devolve.
    await tester.tap(find.text('Consumir'));
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsNothing);
    expect(estoque.movimentos.single.nome, 'Feijão Carioca Nobre');

    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(find.text('Feijão Carioca Nobre'), findsOneWidget);
    expect(estoque.movimentos, isEmpty);
  });

  test('Estoque persiste no aparelho', () async {
    estoque.adicionar(
      name: 'Café',
      quantity: '500g',
      location: StorageLocation.despensa,
      venceEm: estoque.hoje.add(const Duration(days: 30)),
      imagePath: 'x',
    );
    await Future<void>.delayed(Duration.zero);
    await estoque.load(); // relê do shared_preferences
    expect(estoque.produtos.any((p) => p.name == 'Café' && p.daysToExpire == 30), isTrue);
  });
}
