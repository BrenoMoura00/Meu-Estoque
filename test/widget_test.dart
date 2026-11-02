import 'package:flutter_test/flutter_test.dart';
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
}
