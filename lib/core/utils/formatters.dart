/// Formata valor em reais: 1234.5 → "R$ 1.234,50"
String formatBRL(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${value < 0 ? '-' : ''}R\$ $intPart,${parts[1]}';
}
