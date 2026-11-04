import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/data/home_mock_data.dart';
import '../features/consumption_history/data/consumption_mock_data.dart';
import '../features/stock/data/stock_mock_data.dart';
import '../features/waste_report/data/waste_mock_data.dart';
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
    this.motivo,
    this.local = '',
    this.emoji,
    this.pesoKg = 0,
    this.quantidade,
    this.unidadeMedida,
  });

  /// Motivo do descarte (só em [TipoMovimento.desperdicado]).
  final WasteReason? motivo;

  /// Onde o item estava (ex.: "Geladeira • Porta").
  final String local;

  /// Emoji específico do item (senão usa o da categoria).
  final String? emoji;

  /// Peso aproximado retirado (kg); 0 quando não dá para estimar.
  final double pesoKg;
  final double? quantidade;
  final String? unidadeMedida;

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
    'motivo': motivo?.name,
    'local': local,
    'emoji': emoji,
    'pesoKg': pesoKg,
    'quantidade': quantidade,
    'unidadeMedida': unidadeMedida,
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
    motivo: j['motivo'] == null ? null : WasteReason.values.byName(j['motivo']! as String),
    local: j['local'] as String? ?? '',
    emoji: j['emoji'] as String?,
    pesoKg: (j['pesoKg'] as num? ?? 0).toDouble(),
    quantidade: (j['quantidade'] as num?)?.toDouble(),
    unidadeMedida: j['unidadeMedida'] as String?,
  );
}

/// Peso aproximado (kg) a partir de textos como "500g", "1 kg", "2 Litros" (1 L ≈ 1 kg).
double pesoDeTexto(String quantidade) {
  final m = RegExp(r'(\d+(?:[.,]\d+)?)\s*(kg|g|ml|l\b|litros?)', caseSensitive: false).firstMatch(quantidade);
  if (m == null) return 0;
  final v = double.parse(m.group(1)!.replaceAll(',', '.'));
  return switch (m.group(2)!.toLowerCase()) {
    'g' || 'ml' => v / 1000,
    _ => v,
  };
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
    double? amount,
    String? measureUnit,
    this.notes,
    this.photoPath,
  }) {
    initializeMeasure(amount, measureUnit);
  }

  final String id;
  final String name;
  String quantity;
  late double amount;
  late String measureUnit;
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

  // Os registros antigos são interpretados sem alterar a chave de persistência.
  void initializeMeasure(double? initialAmount, String? initialUnit) {
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*(kg|g|ml|litros?|l\b|unidades?|pacotes?)', caseSensitive: false).firstMatch(quantity);
    amount = initialAmount ?? (match == null ? units.toDouble() : double.parse(match.group(1)!.replaceAll(',', '.')));
    measureUnit = initialUnit ?? (match == null ? 'Unidade(s)' : switch (match.group(2)!.toLowerCase()) {
      'l' || 'litro' || 'litros' => 'Litro(s)',
      'unidade' || 'unidades' => 'Unidade(s)',
      'pacote' || 'pacotes' => 'Pacote(s)',
      final value => value,
    });
  }

  void refreshQuantity() {
    final value = amount == amount.roundToDouble() ? amount.toInt().toString() : amount.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '').replaceAll('.', ',');
    quantity = '$value $measureUnit';
  }

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
      amount: amount,
      measureUnit: measureUnit,
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
    'amount': amount,
    'measureUnit': measureUnit,
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
    amount: (j['amount'] as num?)?.toDouble(),
    measureUnit: j['measureUnit'] as String?,
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
  static const _keyItens = 'estoque.itens.v2';
  static const _keyMovs = 'estoque.movimentos.v2';
  static const _keyFavoritas = 'estoque.favoritas.v1';

  /// Relógio injetável (testes).
  DateTime Function() now = DateTime.now;

  SharedPreferences? _prefs;
  final List<_ItemRecord> _itens = [];
  final List<Movimento> _movimentos = [];
  final Set<String> _favoritas = {};

  /// Receitas favoritas (pelo nome).
  Set<String> get favoritas => Set.unmodifiable(_favoritas);

  void alternarFavorita(String receita) {
    if (!_favoritas.remove(receita)) _favoritas.add(receita);
    _changed();
  }

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
    _favoritas
      ..clear()
      ..addAll(_prefs!.getStringList(_keyFavoritas) ?? const []);
    final raw = _prefs!.getString(_keyItens);
    if (raw == null) {
      _seed();
      _seedMovimentos();
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
    _seedMovimentos();
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
    double? amount,
    String? measureUnit,
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
      amount: amount,
      measureUnit: measureUnit,
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

  /// Consome/descarta uma quantidade, mantendo o saldo e o preço proporcionais.
  String? consumir(String id, {double? quantidade}) => _retirar(id, TipoMovimento.consumido, quantidade: quantidade);

  String? descartar(String id, {WasteReason motivo = WasteReason.vencimento, double? quantidade}) =>
      _retirar(id, TipoMovimento.desperdicado, motivo: motivo, quantidade: quantidade);

  final Map<String, ({_ItemRecord item, int index})> _desfazer = {};

  void desfazer(String token) {
    final saved = _desfazer.remove(token);
    if (saved == null) return;
    _movimentos.removeWhere((m) => m.id == token);
    final index = _itens.indexWhere((i) => i.id == saved.item.id);
    if (index >= 0) _itens.removeAt(index);
    _itens.insert(saved.index.clamp(0, _itens.length), saved.item);
    _changed();
  }

  String? _retirar(String id, TipoMovimento tipo, {WasteReason? motivo, double? quantidade}) {
    final index = _itens.indexWhere((i) => i.id == id);
    if (index < 0) return null;
    final item = _itens[index];
    final retirada = quantidade ?? item.amount;
    if (!retirada.isFinite || retirada <= 0 || retirada > item.amount + 0.000001) return null;
    final snapshot = _ItemRecord.fromJson(item.toJson());
    final fraction = (retirada / item.amount).clamp(0.0, 1.0);
    final value = item.price * fraction;
    final weight = switch (item.measureUnit) {
      'kg' || 'Litro(s)' => retirada,
      'g' || 'ml' => retirada / 1000,
      _ => 0.0,
    };
    final mov = _registrar(item, tipo, (item.units * fraction).round(), value, motivo: motivo, pesoKg: weight, quantidade: retirada, unidadeMedida: item.measureUnit);
    item.amount = (item.amount - retirada).clamp(0.0, double.infinity).toDouble();
    item.price = (item.price - value).clamp(0.0, double.infinity).toDouble();
    if (item.amount < 0.000001) {
      _itens.removeAt(index);
    } else {
      if (item.measureUnit == 'Unidade(s)' || item.measureUnit == 'Pacote(s)') item.units = item.amount.round();
      item.refreshQuantity();
    }
    _desfazer[mov.id] = (item: snapshot, index: index);
    _changed();
    return mov.id;
  }

  Movimento _registrar(_ItemRecord i, TipoMovimento tipo, int unidades, double valor, {WasteReason? motivo, double? pesoKg, double? quantidade, String? unidadeMedida}) {
    final mov = Movimento(
      motivo: motivo,
      local: i.spot.isEmpty ? i.location.label : '${i.location.label} • ${i.spot}',
      pesoKg: pesoKg ?? pesoDeTexto(i.quantity) * (unidades / (i.units == 0 ? 1 : i.units)),
      quantidade: quantidade,
      unidadeMedida: unidadeMedida,
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
    await prefs.setStringList(_keyFavoritas, _favoritas.toList());
  }

  /// Histórico de exemplo: consumo deste mês e do anterior + descartes (somam os números do design).
  void _seedMovimentos() {
    final n = now();
    final inicioMes = DateTime(n.year, n.month, 1);
    final decorrido = n.difference(inicioMes);
    DateTime noMes(double f) => inicioMes.add(decorrido * f);
    DateTime mesPassado(int dia) => DateTime(n.year, n.month - 1, dia, 12);
    var k = 0;

    Movimento mov(
      String nome,
      String? categoria,
      TipoMovimento tipo,
      double valor,
      DateTime data, {
      String? emoji,
      int dias = 8,
      WasteReason? motivo,
      String local = '',
      double peso = 0,
    }) => Movimento(
      id: 'seedm${k++}',
      itemId: 'seedm$k',
      nome: nome,
      categoria: categoria,
      tipo: tipo,
      valor: valor,
      unidades: 1,
      diasParaVencer: dias,
      data: data,
      emoji: emoji,
      motivo: motivo,
      local: local,
      pesoKg: peso,
    );

    const categorias = {'Matinais': 'Outros', 'Açougue': 'Carnes', 'Proteínas': 'Carnes', 'Grãos & Cereais': 'Grãos'};
    for (final e in ConsumptionMockData.ranking) {
      final cat = categorias[e.category] ?? e.category;
      final valor = e.totalValue / e.times;
      for (var t = 0; t < e.times; t++) {
        _movimentos.add(
          mov(
            e.name,
            cat,
            TipoMovimento.consumido,
            valor,
            noMes((t + 1) / (e.times + 1)),
            emoji: e.emoji,
            dias: t % 3 == 0 ? 1 : 8,
          ),
        );
      }
      for (var t = 0; t < (e.times / 2).ceil(); t++) {
        _movimentos.add(
          mov(e.name, cat, TipoMovimento.consumido, valor, mesPassado(5 + t), emoji: e.emoji, dias: t.isEven ? 2 : 9),
        );
      }
    }

    // Descartes deste mês: dois mais antigos + os 6 "recentes" do design.
    const pesos = [0.2, 0.4, 0.68, 0.5, 0.5, 0.2];
    const categoriasDescarte = ['Laticínios', 'Carnes', 'Laticínios', 'Hortifrúti', 'Outros', 'Laticínios'];
    const diasDescarte = [-2, -4, -7, 2, 1, -3];
    _movimentos.add(
      mov(
        'Arroz cozido',
        'Grãos',
        TipoMovimento.desperdicado,
        50.30,
        noMes(0.1),
        emoji: '🍚',
        motivo: WasteReason.sobras,
        local: 'Geladeira',
        peso: 0.5,
        dias: 0,
      ),
    );
    _movimentos.add(
      mov(
        'Linguiça Toscana',
        'Carnes',
        TipoMovimento.desperdicado,
        10.50,
        noMes(0.2),
        emoji: '🌭',
        motivo: WasteReason.vencimento,
        local: 'Freezer',
        peso: 0.22,
        dias: -1,
      ),
    );
    final recentes = WasteMockData.recent;
    for (var i = recentes.length - 1; i >= 0; i--) {
      final w = recentes[i];
      _movimentos.add(
        mov(
          w.name,
          categoriasDescarte[i],
          TipoMovimento.desperdicado,
          w.value,
          noMes(0.95 - i * 0.1),
          emoji: w.emoji,
          motivo: w.reason,
          local: w.place,
          peso: pesos[i],
          dias: diasDescarte[i],
        ),
      );
    }

    // Descartes do mês passado (prejuízo menor → variação de +R$ 42).
    _movimentos.add(
      mov(
        'Frutas variadas',
        'Hortifrúti',
        TipoMovimento.desperdicado,
        59.36,
        mesPassado(12),
        emoji: '🍓',
        motivo: WasteReason.deteriorado,
        local: 'Fruteira',
        peso: 1.2,
        dias: 1,
      ),
    );
    _movimentos.add(
      mov(
        'Presunto Fatiado',
        'Carnes',
        TipoMovimento.desperdicado,
        100.00,
        mesPassado(20),
        emoji: '🥓',
        motivo: WasteReason.vencimento,
        local: 'Geladeira',
        peso: 0.5,
        dias: -2,
      ),
    );
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
