import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meu_estoque/features/consumption_history/presentation/widgets/consumption_rank_card.dart';
import 'package:meu_estoque/features/stock/presentation/widgets/stock_item_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:meu_estoque/main.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

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

  testWidgets('Estoque filtra por status e por busca', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2400 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MeuEstoqueApp());
    await tester.tap(find.text('Estoque').last);
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsNWidgets(6));

    await tester.tap(find.text('Vence Hoje'));
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsOneWidget);
    expect(find.text('Garrafa de Leite Integral'), findsOneWidget);

    await tester.tap(find.text('Todos').last);
    await tester.enterText(find.byType(TextField), 'feij');
    await tester.pumpAndSettle();
    expect(find.byType(StockItemCard), findsOneWidget);
    expect(find.text('Feijão Carioca Nobre'), findsOneWidget);
  });
}
