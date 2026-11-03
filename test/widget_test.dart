import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
