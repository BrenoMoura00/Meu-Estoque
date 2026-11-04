import '../core/constants/app_assets.dart';

enum StorageLocation {
  geladeira('Geladeira', AppIcons.geladeira, AppIcons.tagGeladeira, AppIcons.locGeladeira),
  despensa('Despensa', AppIcons.despensa, AppIcons.tagDespensa, AppIcons.locDespensa),
  freezer('Freezer', AppIcons.freezer, AppIcons.locFreezer, AppIcons.locFreezer);

  const StorageLocation(this.label, this.icon, this.tagIcon, this.inlineIcon);
  final String label;

  /// Ícone grande (cards de resumo)
  final String icon;

  /// Ícone da tag em pílula (Início)
  final String tagIcon;

  /// Ícone inline ao lado do texto (Estoque)
  final String inlineIcon;
}

/// Situação de validade de um item.
enum ExpiryStatus {
  /// Vence hoje ou já venceu
  today,

  /// Vence em até [Product.soonThresholdDays] dias
  soon,

  /// Dentro do prazo
  ok,
}

class Product {
  const Product({
    required this.name,
    required this.quantity,
    required this.imagePath,
    required this.location,
    required this.spot,
    required this.daysToExpire,
    required this.freshness,
    this.price = 0,
    this.category,
    this.brand,
    this.variant,
    this.units = 1,
    this.amount,
    this.measureUnit,
    this.notes,
    this.photoPath,
    this.id,
  });

  /// Identificador no estoque (null em dados mock).
  final String? id;

  /// Marca (ex.: "Piracanjuba")
  final String? brand;

  /// Variante (ex.: "Integral", "Desnatado")
  final String? variant;

  /// Quantas unidades/embalagens há em estoque.
  final int units;

  /// Quantidade restante na unidade de medida escolhida.
  final double? amount;
  final String? measureUnit;

  /// Observações de consumo (privadas).
  final String? notes;

  /// Foto grande para a tela de detalhes; usa [imagePath] se nula.
  final String? photoPath;

  /// Rótulo da categoria (ex.: "Laticínios")
  final String? category;

  /// Até quantos dias o item é considerado "vencendo".
  static const soonThresholdDays = 4;

  final String name;

  /// Ex.: "1 kg", "500g"
  final String quantity;
  final String imagePath;
  final StorageLocation location;

  /// Posição dentro do local (ex.: "Gaveta 01")
  final String spot;
  final int daysToExpire;

  /// 0..1 — quanto do ciclo de vida útil já passou (barra de progresso)
  final double freshness;

  /// Valor estimado do item em R$
  final double price;

  /// Valor estimado por unidade.
  double get unitPrice => units <= 0 ? price : price / units;

  ExpiryStatus get status => daysToExpire <= 0
      ? ExpiryStatus.today
      : daysToExpire <= soonThresholdDays
          ? ExpiryStatus.soon
          : ExpiryStatus.ok;

  bool get expiresToday => status == ExpiryStatus.today;
  bool get isExpiringSoon => status != ExpiryStatus.ok;

  /// Prazo restante curto: "Hoje!", "1 dia", "3 dias", "6 meses"
  String get shortRemaining {
    if (daysToExpire <= 0) return 'Hoje!';
    if (daysToExpire < 30) return daysToExpire == 1 ? '1 dia' : '$daysToExpire dias';
    final months = (daysToExpire / 30).round();
    return months == 1 ? '1 mês' : '$months meses';
  }
}

class Category {
  const Category(this.label, this.icon);
  final String label;
  final String icon;
}

class StorageSummary {
  const StorageSummary({required this.location, required this.count, required this.occupancy});
  final StorageLocation location;
  final int count;

  /// 0..1
  final double occupancy;
}
