/// Formata data como dd/MM/aaaa
String formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

/// Formata valor em reais: 1234.5 → "R$ 1.234,50"
String formatBRL(double value) {
  final parts = value.abs().toStringAsFixed(2).split('.');
  final intPart = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.');
  return '${value < 0 ? '-' : ''}R\$ $intPart,${parts[1]}';
}

const _months = [
  'Janeiro',
  'Fevereiro',
  'Março',
  'Abril',
  'Maio',
  'Junho',
  'Julho',
  'Agosto',
  'Setembro',
  'Outubro',
  'Novembro',
  'Dezembro',
];

/// Formata mês e ano: "Novembro 2026"
String formatMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

/// Mês abreviado: "Nov"
String formatMonthShort(DateTime d) => _months[d.month - 1].substring(0, 3);
