import '../core/constants/app_assets.dart';

enum StorageLocation {
  geladeira('Geladeira', AppIcons.geladeira, AppIcons.tagGeladeira),
  despensa('Despensa', AppIcons.despensa, AppIcons.tagDespensa),
  freezer('Freezer', AppIcons.freezer, AppIcons.tagGeladeira);

  const StorageLocation(this.label, this.icon, this.tagIcon);
  final String label;
  final String icon;
  final String tagIcon;
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
  });

  final String name;

  /// Ex.: "1 kg", "500g"
  final String quantity;
  final String imagePath;
  final StorageLocation location;

  /// Posição dentro do local (ex.: "Gaveta 01")
  final String spot;
  final int daysToExpire;

  /// 0..1 — quanto da vida útil ainda resta (barra de progresso)
  final double freshness;

  bool get expiresToday => daysToExpire <= 0;
  bool get isExpiringSoon => daysToExpire <= 3;
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
