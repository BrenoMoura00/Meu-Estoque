import 'package:flutter/material.dart';

import '../../data/estoque_store.dart';
import '../../models/product.dart';
import 'discard_reason_sheet.dart';

/// Solicita a quantidade antes de consumir ou descartar.
Future<double?> escolherQuantidade(BuildContext context, Product p) async {
  final available = p.amount ?? p.units.toDouble();
  final unit = p.measureUnit ?? 'Unidade(s)';
  final whole = unit == 'Unidade(s)' || unit == 'Pacote(s)';
  return showDialog<double>(
    context: context,
    builder: (_) => _QuantityDialog(available: available, unit: unit, whole: whole),
  );

}

/// O controller pertence ao ciclo de vida do diálogo, não ao Future de showDialog.
class _QuantityDialog extends StatefulWidget {
  const _QuantityDialog({required this.available, required this.unit, required this.whole});

  final double available;
  final String unit;
  final bool whole;

  @override
  State<_QuantityDialog> createState() => _QuantityDialogState();
}

class _QuantityDialogState extends State<_QuantityDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    final value = widget.available;
    _controller = TextEditingController(
      text: value == value.roundToDouble() ? value.toInt().toString() : value.toString(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    final value = double.tryParse(_controller.text.trim().replaceAll(',', '.'));
    if (value == null || !value.isFinite || value <= 0 ||
        value > widget.available + 0.000001 ||
        (widget.whole && value != value.roundToDouble())) {
      setState(() => _error = 'Informe uma quantidade válida dentro do estoque disponível');
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Qual quantidade deseja retirar?'),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Disponível: ${widget.available} ${widget.unit}'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: false,
            keyboardType: TextInputType.numberWithOptions(decimal: !widget.whole),
            decoration: InputDecoration(
              labelText: 'Quantidade (${widget.unit})',
              border: const OutlineInputBorder(),
              errorText: _error,
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
      TextButton(onPressed: _confirm, child: const Text('Confirmar')),
    ],
  );
}

Future<bool> consumirComDesfazer(BuildContext context, Product p, {ScaffoldMessengerState? messenger}) async {
  final amount = await escolherQuantidade(context, p);
  if (amount == null || !context.mounted) return false;
  final token = p.id == null ? null : estoque.consumir(p.id!, quantidade: amount);
  if (token == null) return false;
  _avisar(messenger ?? ScaffoldMessenger.of(context), '"${p.name}" consumido: $amount ${p.measureUnit ?? 'unidades'}', token);
  return true;
}

Future<bool> descartarComDesfazer(BuildContext context, Product p, {SnackBarAction? acaoExtra}) async {
  final messenger = ScaffoldMessenger.of(context);
  final amount = await escolherQuantidade(context, p);
  if (amount == null || !context.mounted) return false;
  final motivo = await escolherMotivoDescarte(context, p.name);
  if (motivo == null || !context.mounted) return false;
  final token = p.id == null ? null : estoque.descartar(p.id!, motivo: motivo, quantidade: amount);
  if (token == null) return false;
  _avisar(messenger, '"${p.name}" descartado: $amount ${p.measureUnit ?? 'unidades'}', token, acao: acaoExtra);
  return true;
}

void _avisar(ScaffoldMessengerState messenger, String message, String? token, {SnackBarAction? acao}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      duration: const Duration(seconds: 4),
      content: Text(message),
      action: acao ?? (token == null ? null : SnackBarAction(label: 'Desfazer', onPressed: () => estoque.desfazer(token))),
    ));
}
