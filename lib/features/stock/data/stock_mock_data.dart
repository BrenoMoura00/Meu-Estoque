import '../../../core/constants/app_assets.dart';
import '../../../models/product.dart';

/// Dados fictícios da tela Estoque. Serão trocados por repositório/back-end.
abstract final class StockMockData {
  static const items = [
    Product(
      name: 'Garrafa de Leite Integral',
      quantity: '2 Litros',
      imagePath: AppImages.leiteGarrafa,
      location: StorageLocation.geladeira,
      spot: 'Porta',
      daysToExpire: 0,
      freshness: 0.95,
      price: 12.90,
      category: 'Laticínios',
    ),
    Product(
      name: 'Queijo Mussarela Fatiado',
      quantity: '300g',
      imagePath: AppImages.queijoMussarela,
      location: StorageLocation.geladeira,
      spot: 'Queijeira',
      daysToExpire: 1,
      freshness: 0.85,
      price: 18.50,
      category: 'Laticínios',
    ),
    Product(
      name: 'Iogurte de Morango',
      quantity: '4 un (170g cada)',
      imagePath: AppImages.iogurteMorango,
      location: StorageLocation.geladeira,
      spot: 'Prateleira 1',
      daysToExpire: 3,
      freshness: 0.70,
      price: 14.00,
      category: 'Laticínios',
    ),
    Product(
      name: 'Peito de Frango em Filés',
      quantity: '1 kg',
      imagePath: AppImages.frangoFiles,
      location: StorageLocation.freezer,
      spot: 'Gaveta 1',
      daysToExpire: 4,
      freshness: 0.60,
      price: 24.90,
      category: 'Carnes',
    ),
    Product(
      name: 'Arroz Branco Tipo 1',
      quantity: '5 kg',
      imagePath: AppImages.arrozBranco,
      location: StorageLocation.despensa,
      spot: 'Prateleira 2',
      daysToExpire: 180,
      freshness: 0.25,
      price: 27.90,
      category: 'Grãos',
    ),
    Product(
      name: 'Feijão Carioca Nobre',
      quantity: '1 kg',
      imagePath: AppImages.feijaoCarioca,
      location: StorageLocation.despensa,
      spot: 'Prateleira 2',
      daysToExpire: 120,
      freshness: 0.35,
      price: 8.90,
      category: 'Grãos',
    ),
  ];

  static const categoryFilters = ['Laticínios', 'Hortifrúti', 'Grãos'];
}
