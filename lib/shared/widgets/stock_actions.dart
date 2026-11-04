import 'package:flutter/material.dart';

import '../../data/estoque_store.dart';
import '../../models/product.dart';

/// Consome o item inteiro e mostra SnackBar com "Desfazer".
/// Passe [messenger] quando a tela for fechada logo em seguida.
void consumirComDesfazer(BuildContext context, Product p, {ScaffoldMessengerState? messenger}) {
  final token = p.id == null ? null : estoque.consumir(p.id!);
  _avisar(messenger ?? ScaffoldMessenger.of(context), '"${p.name}" marcado como consumido', token);
}

/// Registra o item inteiro como desperdício e mostra SnackBar com "Desfazer".
void descartarComDesfazer(BuildContext context, Product p, {ScaffoldMessengerState? messenger}) {
  final token = p.id == null ? null : estoque.descartar(p.id!);
  _avisar(messenger ?? ScaffoldMessenger.of(context), '"${p.name}" registrado como desperdício', token);
}

void _avisar(ScaffoldMessengerState messenger, String message, String? token) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        action: token == null ? null : SnackBarAction(label: 'Desfazer', onPressed: () => estoque.desfazer(token)),
      ),
    );
}
