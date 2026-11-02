import '../../../core/constants/app_assets.dart';
import '../../../models/product.dart';

/// Dados fictícios da tela Início. Serão trocados por repositório/back-end
/// na fase de funcionalidades.
abstract final class HomeMockData {
  static const expiringToday = [
    Product(
      name: 'Leite Integral',
      quantity: '1 L',
      imagePath: AppImages.leiteIntegral,
      location: StorageLocation.geladeira,
      spot: 'Porta',
      daysToExpire: 0,
      freshness: 0,
    ),
    Product(
      name: 'Iogurte Nat.',
      quantity: '170g',
      imagePath: AppImages.iogurteNatural,
      location: StorageLocation.geladeira,
      spot: 'Prateleira 1',
      daysToExpire: 0,
      freshness: 0,
    ),
    Product(
      name: 'Tomate Rama',
      quantity: '500g',
      imagePath: AppImages.tomateRama,
      location: StorageLocation.geladeira,
      spot: 'Gaveta 02',
      daysToExpire: 0,
      freshness: 0,
    ),
  ];

  static const valueAtRiskToday = 18.20;
  static const monthlySavings = 142.50;
  static const savingsGrowth = 94;

  static const categories = [
    Category('Todos', AppIcons.catTodos),
    Category('Laticínios', AppIcons.catLaticinios),
    Category('Hortifrúti', AppIcons.catHortifruti),
    Category('Carnes', AppIcons.catCarnes),
    Category('Grãos', AppIcons.catGraos),
    Category('Bebidas', AppIcons.catBebidas),
  ];

  static const storage = [
    StorageSummary(location: StorageLocation.geladeira, count: 18, occupancy: 0.75),
    StorageSummary(location: StorageLocation.despensa, count: 32, occupancy: 0.50),
    StorageSummary(location: StorageLocation.freezer, count: 12, occupancy: 0.35),
  ];

  static const recentItems = [
    Product(
      name: 'Peito de Frango',
      quantity: '1 kg',
      imagePath: AppImages.peitoFrango,
      location: StorageLocation.geladeira,
      spot: 'Gaveta 01',
      daysToExpire: 2,
      freshness: 0.70,
    ),
    Product(
      name: 'Pão Artesanal',
      quantity: '500g',
      imagePath: AppImages.paoArtesanal,
      location: StorageLocation.despensa,
      spot: 'Prateleira 2',
      daysToExpire: 3,
      freshness: 0.55,
    ),
    Product(
      name: 'Suco de Laranja',
      quantity: '1 L',
      imagePath: AppImages.sucoLaranja,
      location: StorageLocation.geladeira,
      spot: 'Porta superior',
      daysToExpire: 5,
      freshness: 0.30,
    ),
    Product(
      name: 'Queijo Parmesão',
      quantity: '250g',
      imagePath: AppImages.queijoParmesao,
      location: StorageLocation.geladeira,
      spot: 'Queijeira',
      daysToExpire: 12,
      freshness: 0.15,
    ),
  ];
}
