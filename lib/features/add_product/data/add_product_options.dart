import '../../../core/constants/app_assets.dart';
import '../../../models/product.dart';

/// Opções fixas do formulário "Adicionar Item".
abstract final class AddProductOptions {
  static const categories = [
    Category('Hortifrúti', AppIcons.addCatHortifruti),
    Category('Laticínios', AppIcons.addCatLaticinios),
    Category('Carnes', AppIcons.addCatCarnes),
    Category('Grãos', AppIcons.addCatGraos),
    Category('Bebidas', AppIcons.addCatBebidas),
    Category('Limpeza', AppIcons.addCatLimpeza),
    Category('Outros', AppIcons.addCatOutros),
  ];

  static const units = ['Unidade(s)', 'kg', 'g', 'Litro(s)', 'ml', 'Pacote(s)'];

  /// Atalhos de validade a partir de hoje.
  static const expiryShortcuts = [
    (label: '+3 dias', days: 3),
    (label: '+1 semana', days: 7),
    (label: '+1 mês', days: 30),
  ];

  /// Ícone usado no seletor de local deste formulário.
  static String storageIcon(StorageLocation location) => switch (location) {
        StorageLocation.geladeira => AppIcons.storeGeladeira,
        StorageLocation.despensa => AppIcons.storeDespensa,
        StorageLocation.freezer => AppIcons.storeFreezer,
      };

  static const notifyDaysBefore = 3;
}
