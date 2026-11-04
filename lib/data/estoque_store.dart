import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/data/home_mock_data.dart';
import '../features/stock/data/stock_mock_data.dart';
import '../models/product.dart';

/// Tipo de movimentação registrada ao tirar um item do estoque.
enum TipoMovimento { consumido, desperdicado }

/// Registro de consumo/desperdício (base dos relatórios).
class Movimento {
  const Movimento({
    required this.id,
    required this.itemId,
    required this.nome,
    required this.categoria,
    required this.tipo,
    required this.valor,
    required this.unidades,
    required this.diasParaVencer,
    required this.data,
  });

  final String id;
  final String itemId;
  final String nome;
  final String? categoria;
  final TipoMovimento tipo;
  final double valor;
  final int unidades;

  /// Dias até vencer no momento do registro (negativo = já vencido).
  final int diasParaVencer;
  final DateTime data;

  Map<String, Object?> toJson() => {
    'id': id,
    'itemId': itemId,
    'nome': nome,
    'categoria': categoria,
    'tipo': tipo.name,
    'valor': valor,
    'unidades': unidades,
    'dias': diasParaVencer,
    'data': data.toIso8601String(),
  };

  factory Movimento.fromJson(Map<String, Object?> j) => Movimento(
    id: j['id']! as String,
    itemId: j['itemId']! as String,
    nome: j['nome']! as String,
    categoria: j['categoria'] as String?,
    tipo: TipoMovimento.values.byName(j['tipo']! as String),
    valor: (j['valor']! as num).toDouble(),
    unidades: j['unidades']! as int,
    diasParaVencer: j['dias']! as int,
    data: DateTime.parse(j['data']! as String),
  );
}

/// Item guardado no estoque. Datas sem hora; dias/ciclo são calculados a partir de hoje.
class _ItemRecord {
  _ItemRecord({
    required this.id,
    required this.name,
    required this.quantity,
    required this.imagePath,
    required this.location,
    required this.spot,
    required this.venceEm,
    required this.compradoEm,
    required this.criadoEm,
    this.price = 0,
    this.category,
    this.brand,
    this.variant,
    this.units = 1,
    this.notes,
    this.photoPath,
  });

  final String id;
  final String name;
  final String quantity;
  final String imagePath;
  final StorageLocation location;
  final String spot;
  final DateTime venceEm;
  final DateTime compradoEm;
  final DateTime criadoEm;
  double price;
  final String? category;
  final String? brand;
  final String? variant;
  int units;
  final String? notes;
  final String? photoPath;

  Product toProduct(DateTime hoje) {
    final dias = _diasEntre(hoje, venceEm);
    final total = _diasEntre(compradoEm, venceEm);
    final ciclo = total <= 0 ? 1.0 : (_diasEntre(compradoEm, hoje) / total).clamp(0.0, 1.0);
    return Product(
      id: id,
      name: name,
      quantity: quantity,
      imagePath: imagePath,
      location: location,
      spot: spot,
      daysToExpire: dias,
      freshness: ciclo,
      price: price,
      category: category,
      brand: brand,
      variant: variant,
      units: units,
      notes: notes,
      photoPath: photoPath,
    );
  }

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'imagePath': imagePath,
    'location': location.name,
    'spot': spot,
    'venceEm': _data(venceEm),
    'compradoEm': _data(compradoEm),
    'criadoEm': criadoEm.toIso8601String(),
    'price': price,
    'category': category,
    'brand': brand,
    'variant': variant,
    'units': units,
    'notes': notes,
    'photoPath': photoPath,
  };

  factory _ItemRecord.fromJson(Map<String, Object?> j) => _ItemRecord(
    id: j['id']! as String,
    name: j['name']! as String,
    quantity: j['quantity']! as String,
    imagePath: j['imagePath']! as String,
    location: StorageLocation.values.byName(j['location']! as String),
    spot: j['spot']! as String,
    venceEm: DateTime.parse(j['venceEm']! as String),
    compradoEm: DateTime.parse(j['compradoEm']! as String),
    criadoEm: DateTime.parse(j['criadoEm']! as String),
    price: (j['price'] as num? ?? 0).toDouble(),
    category: j['category'] as String?,
    brand: j['brand'] as String?,
    variant: j['variant'] as String?,
    units: j['units'] as int? ?? 1,
    notes: j['notes'] as String?,
    photoPath: j['photoPath'] as String?,
  );
}

/// Contagem de dias entre datas, ignorando horário (seguro com horário de verão).
int _diasEntre(DateTime de, DateTime ate) =>
    DateTime.utc(ate.year, ate.month, ate.day).difference(DateTime.utc(de.year, de.month, de.day)).inDays;

String _data(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// Estoque local da apresentação: memória + `shared_preferences` (JSON).
/// Telas escutam com `ListenableBuilder(listenable: estoque, ...)`.
class EstoqueStore extends ChangeNotifier {
  static const _keyItens = 'estoque.itens.v1';
  static const _keyMovs = 'estoque.movimentos.v1';

  /// Relógio injetável (testes).
  DateTime Function() now = DateTime.now;

  SharedPreferences? _prefs;
  final List<_ItemRecord> _itens = [];
  final List<Movimento> _movimentos = [];
  int _seq = 0;

  DateTime get hoje {
    final n = now();
    return DateTime(n.year, n.month, n.day);
  }

  /// Itens do estoque, ordenados por validade.
  List<Product> get produtos {
    final h = hoje;
    final list = [for (final i in _itens) i.toProduct(h)]..sort((a, b) => a.daysToExpire.compareTo(b.daysToExpire));
    return list;
  }

  /// Últimos itens cadastrados (mais recentes primeiro).
  List<Product> recentes(int n) {
    final h = hoje;
    final sorted = [..._itens]..sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    return [for (final i in sorted.take(n)) i.toProduct(h)];
  }

  List<Movimento> get movimentos => List.unmodifiable(_movimentos);

  Product? porId(String id) {
    for (final i in _itens) {
      if (i.id == id) return i.toProduct(hoje);
    }
    return null;
  }

  /// Carrega do aparelho; na primeira execução usa os dados de exemplo.
  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    _itens.clear();
    _movimentos.clear();
    final raw = _prefs!.getString(_keyItens);
    if (raw == null) {
      _seed();
      await _persist();
    } else {
      _itens.addAll([for (final j in jsonDecode(raw) as List) _ItemRecord.fromJson((j as Map).cast())]);
      final movs = _prefs!.getString(_keyMovs);
      if (movs != null) {
        _movimentos.addAll([for (final j in jsonDecode(movs) as List) Movimento.fromJson((j as Map).cast())]);
      }
    }
    notifyListeners();
  }

  /// Volta aos dados de exemplo (útil antes de uma apresentação).
  Future<void> resetarExemplo() async {
    _itens.clear();
    _movimentos.clear();
    _seed();
    await _persist();
    notifyListeners();
  }

  String adicionar({
    required String name,
    required String quantity,
    required StorageLocation location,
    required DateTime venceEm,
    required String imagePath,
    String spot = '',
    double price = 0,
    String? category,
    int units = 1,
  }) {
    final agora = now();
    final record = _ItemRecord(
      id: _novoId(),
      name: name,
      quantity: quantity,
      imagePath: imagePath,
      location: location,
      spot: spot,
      venceEm: DateTime(venceEm.year, venceEm.month, venceEm.day),
      compradoEm: hoje,
      criadoEm: agora,
      price: price,
      category: category,
      units: units,
    );
    _itens.add(record);
    _changed();
    return record.id;
  }

  /// Ajusta unidades. Diminuir registra o consumo das unidades retiradas; mínimo 1.
  void ajustarUnidades(String id, int novas) {
    final i = _find(id);
    if (i == null || novas < 1 || novas == i.units) return;
    final unitario = i.units == 0 ? i.price : i.price / i.units;
    if (novas < i.units) _registrar(i, TipoMovimento.consumido, i.units - novas, unitario * (i.units - novas));
    i.price = unitario * novas;
    i.units = novas;
    _changed();
  }

  /// Retira o item inteiro do estoque. Retorna um token para [desfazer].
  String? consumir(String id) => _retirar(id, TipoMovimento.consumido);

  String? descartar(String id) => _retirar(id, TipoMovimento.desperdicado);

  final Map<String, ({_ItemRecord item, int index})> _desfazer = {};

  /// Desfaz um [consumir]/[descartar]: devolve o item e apaga a movimentação.
  void desfazer(String token) {
    final saved = _desfazer.remove(token);
    if (saved == null) return;
    _movimentos.removeWhere((m) => m.id == token);
    _itens.insert(saved.index.clamp(0, _itens.length), saved.item);
    _changed();
  }

  String? _retirar(String id, TipoMovimento tipo) {
    final index = _itens.indexWhere((i) => i.id == id);
    if (index < 0) return null;
    final item = _itens.removeAt(index);
    final mov = _registrar(item, tipo, item.units, item.price);
    _desfazer[mov.id] = (item: item, index: index);
    _changed();
    return mov.id;
  }

  Movimento _registrar(_ItemRecord i, TipoMovimento tipo, int unidades, double valor) {
    final mov = Movimento(
      id: _novoId(),
      itemId: i.id,
      nome: i.name,
      categoria: i.category,
      tipo: tipo,
      valor: valor,
      unidades: unidades,
      diasParaVencer: _diasEntre(hoje, i.venceEm),
      data: now(),
    );
    _movimentos.add(mov);
    return mov;
  }

  _ItemRecord? _find(String id) {
    for (final i in _itens) {
      if (i.id == id) return i;
    }
    return null;
  }

  String _novoId() => '${now().microsecondsSinceEpoch.toRadixString(36)}${(_seq++).toRadixString(36)}';

  void _changed() {
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setString(_keyItens, jsonEncode([for (final i in _itens) i.toJson()]));
    await prefs.setString(_keyMovs, jsonEncode([for (final m in _movimentos) m.toJson()]));
  }

  /// Dados de exemplo: itens do Estoque + itens da Início (os da Início ficam como mais recentes).
  void _seed() {
    final h = hoje;
    final seeds = [...HomeMockData.expiringToday, ...StockMockData.items, ...HomeMockData.recentItems];
    final base = now().subtract(Duration(minutes: seeds.length));
    for (var k = 0; k < seeds.length; k++) {
      final p = seeds[k];
      final dias = p.daysToExpire;
      // Recria a data de compra a partir do ciclo já percorrido (freshness).
      final f = p.freshness.clamp(0.0, 0.95);
      final decorridos = dias <= 0 ? 7 : (f * dias / (1 - f)).round();
      _itens.add(
        _ItemRecord(
          id: 'seed$k',
          name: p.name,
          quantity: p.quantity,
          imagePath: p.imagePath,
          location: p.location,
          spot: p.spot,
          venceEm: DateTime(h.year, h.month, h.day + dias),
          compradoEm: DateTime(h.year, h.month, h.day - decorridos),
          criadoEm: base.add(Duration(minutes: k)),
          price: p.price,
          category: p.category,
          brand: p.brand,
          variant: p.variant,
          units: p.units,
          notes: p.notes,
          photoPath: p.photoPath,
        ),
      );
    }
  }
}

/// Instância única usada pelo app.
final estoque = EstoqueStore();
