import 'package:flutter/material.dart';

import '../../data/estoque_store.dart';
import '../../models/product.dart';
import 'discard_reason_sheet.dart';

/// Consome o item inteiro e mostra SnackBar com "Desfazer".
/// Passe [messenger] quando a tela for fechada logo em seguida.
void consumirComDesfazer(BuildContext context, Product p, {ScaffoldMessengerState? messenger}) {
  final token = p.id == null ? null : estoque.consumir(p.id!);
  _avisar(messenger ?? ScaffoldMessenger.of(context), '"${p.name}" marcado como consumido', token);
}

/// Pergunta o motivo e registra o item inteiro como desperdício, com "Desfazer".
/// Retorna false se o usuário cancelou.
Future<bool> descartarComDesfazer(BuildContext context, Product p, {SnackBarAction? acaoExtra}) async {
  final messenger = ScaffoldMessenger.of(context);
  final motivo = await escolherMotivoDescarte(context, p.name);
  if (motivo == null) return false;
  final token = p.id == null ? null : estoque.descartar(p.id!, motivo: motivo);
  _avisar(messenger, '"${p.name}" registrado como desperdício', token, acao: acaoExtra);
  return true;
}

void _avisar(ScaffoldMessengerState messenger, String message, String? token, {SnackBarAction? acao}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: acao ?? (token == null ? null : SnackBarAction(label: 'Desfazer', onPressed: () => estoque.desfazer(token))),
      ),
    );
}
