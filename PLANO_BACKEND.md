# Plano de implementação: lógica e back-end

Guia passo a passo para tirar o Meu Estoque dos dados mock e deixá-lo funcional.
O plano foi escrito para ser seguido à risca. Cada fase define:

- o que criar ou alterar, com caminhos de arquivo;
- as regras de negócio exatas;
- os testes obrigatórios;
- um critério de "pronto";
- as armadilhas conhecidas.

> Estado de partida (03/11/2026): todas as telas do Figma estão na `main`, com dados mock.
> Ambiente: Flutter 3.47.1, Dart 3.13.1, plataformas android/ios/web, `applicationId` `br.com.meuestoque.meu_estoque`, iOS 15.0.

---

## ⚡ Modo apresentação (adotado em 04/11/2026)
O objetivo atual é **só uma apresentação**. Para economizar tempo e tokens, a implementação segue um caminho simplificado
em vez das Fases 0–10 completas:

- Sem Riverpod, go_router, Drift, back-end ou Docker.
- Estado central em `lib/data/estoque_store.dart`: um `EstoqueStore extends ChangeNotifier` com instância global `estoque`.
  As telas escutam com `addListener`/`ListenableBuilder`.
- Persistência local com `shared_preferences` (JSON). Na primeira execução, ele carrega os dados de exemplo.
  `estoque.resetarExemplo()` volta ao estado inicial.

| Etapa | Branch | Conteúdo | Status |
|---|---|---|---|
| 1 | `feat/estado-local` | Store + persistência. Estoque, Início, Adicionar Item e Detalhes funcionam de verdade (cadastrar, consumir, descartar, Desfazer, ajustar unidades). Movimentações registradas. | ✅ |
| 2 | `feat/relatorios-locais` | Histórico de Consumo e Desperdício calculados a partir das movimentações (+ seed de movimentações para a demo), motivo do descarte | ⏳ |
| 3 | `feat/receitas-locais` | Receitas cruzando com o estoque (ingredientes que tem/faltam, urgência), favoritos persistidos | ⏳ |

As seções abaixo continuam válidas como referência caso o app vá para produção.

---

## Sumário
- [0. Decisões e convenções globais](#0-decisões-e-convenções-globais)
- [1. Modelo de domínio](#1-modelo-de-domínio)
- [2. Regras de negócio (fórmulas)](#2-regras-de-negócio-fórmulas)
- [Fase 0: Fundação](#fase-0-fundação-featarquitetura-estado)
- [Fase 1: Persistência local](#fase-1-persistência-local-featpersistencia-local)
- [Fase 2: Ciclo de vida do item](#fase-2-ciclo-de-vida-do-item-featcrud-itens)
- [Fase 3: Números da Início e do Estoque](#fase-3-números-da-início-e-do-estoque-featmetricas-inicio)
- [Fase 4: Relatórios](#fase-4-relatórios-featrelatorios)
- [Fase 5: Notificações](#fase-5-notificações-featnotificacoes)
- [Fase 6: Receitas](#fase-6-receitas-featreceitas-logica)
- [Fase 7: Compras](#fase-7-compras-featcompras)
- [Fase 8: Câmera e código de barras](#fase-8-câmera-e-código-de-barras-featcamera-scanner)
- [Fase 9: Nuvem e família (opcional)](#fase-9-nuvem-e-família-featsync-supabase-opcional)
- [Fase 10: Qualidade e publicação](#fase-10-qualidade-e-publicação)
- [Armadilhas conhecidas](#armadilhas-conhecidas-checklist)
- [Decisões pendentes](#decisões-pendentes)

---

## 0. Decisões e convenções globais

### 0.1 Estratégia
Os dados ficam no aparelho primeiro (local-first): o app funciona offline e não tem custo de servidor.
A nuvem entra na Fase 9. Por isso, desde a Fase 1, todo registro já nasce com os campos que a sincronização vai exigir:

- `uuid`, para não colidir entre aparelhos;
- `atualizadoEm`, para saber qual versão é a mais nova;
- `excluidoEm`, para exclusão "suave" que também possa ser sincronizada.

Assim não será preciso migrar o banco depois.

### 0.2 Pacotes
Versões mais recentes no pub.dev em 03/11/2026, como referência. Adicione **sempre com `flutter pub add`**, que resolve versões compatíveis, e anote no PR a versão que entrou.

| Uso | Pacote | Ref. | Fase |
|---|---|---|---|
| Estado | `flutter_riverpod` | 3.4.3 | 0 |
| Navegação | `go_router` | 18.1.2 | 0 |
| IDs | `uuid` | 4.6.0 | 0 |
| Banco | `drift`, `drift_flutter` | 2.35.3 / 0.3.1 | 1 |
| Codegen (dev) | `drift_dev`, `build_runner` | 2.35.2 / 2.17.1 | 1 |
| Caminhos | `path_provider`, `path` | 2.1.6 / 1.9.1 | 1 |
| Testes (dev) | `mocktail` | 1.0.5 | 0 |
| Notificações | `flutter_local_notifications`, `timezone`, `flutter_timezone` | 22.3.3 / 0.11.2 / 5.1.1 | 5 |
| Widget tela de bloqueio | `home_widget` | 0.10.0 | 5b |
| Fotos | `image_picker` | 1.2.4 | 8 |
| Código de barras | `mobile_scanner` | 7.5.0 | 8 |
| HTTP | `http` | 1.6.0 | 8 |
| Nuvem | `supabase_flutter` | 2.18.3 | 9 |

Decisões sobre os pacotes:
- **Riverpod sem geração de código.** Não use `riverpod_annotation`/`riverpod_generator`: o código gerado só entra no projeto por causa do Drift, e menos geração significa menos erros de build.
  No Riverpod 3, `StateProvider` e `ChangeNotifierProvider` ficaram em `package:flutter_riverpod/legacy.dart`. **Não use.** Use `Provider`, `StreamProvider`, `FutureProvider`, `NotifierProvider` e `AsyncNotifierProvider`.
- **Sem `freezed`.** As classes de domínio são escritas à mão, com `copyWith`, `==` e `hashCode` (são poucas).

### 0.3 Arquitetura e pastas
```
lib/
  app/
    router.dart              GoRouter + rotas (Fase 0)
    providers.dart           providers globais (clock, db, repositórios)
    snackbar_service.dart    SnackBars globais (rootScaffoldMessengerKey)
  core/                      (já existe) theme, constants, utils
    utils/text_normalize.dart  normalizar(): minúsculas + sem acento (Fase 6)
    time/clock.dart          Clock injetável + hojeProvider
  domain/                    Dart puro, sem import de Flutter (exceto foundation)
    enums.dart               Categoria, LocalArmazenamento, UnidadeMedida, TipoMovimentacao, MotivoDescarte
    item.dart                Item (entidade)
    movimentacao.dart        Movimentacao
    item_compra.dart         ItemCompra
    receita.dart             Receita, Ingrediente
    configuracoes.dart       Configuracoes
    regras/                  funções puras: validade.dart, valores.dart, metricas.dart, receitas_match.dart
  data/
    db/app_database.dart     Drift: tabelas + AppDatabase (+ .g.dart gerado)
    db/converters.dart       DataSemHoraConverter
    repositories/            interfaces + implementações (mock e drift)
    seed/dev_seed.dart       dados de exemplo (só em debug)
  features/...               (já existe) telas; passam a usar providers
  models/product.dart        vira "view model" da UI (ver 1.4)
test/
  fixtures/fixtures.dart     mesmos dados dos mocks atuais, com relógio fixo
  domain/  data/  features/  testes por camada
```
Regra de dependência: `features` → `app/providers` → `data/repositories` (interfaces) → `domain`.
O `domain` não importa nada de `data` nem de `features`.

### 0.4 Convenções que evitam bugs
1. **Dinheiro em centavos (`int`).** Nunca use `double` para dinheiro no domínio ou no banco. Converta para `double` só na hora de exibir, com o `formatBRL` existente ou um novo `formatCentavos(int)`.
2. **Datas de validade e compra sem horário.** Guarde como texto `yyyy-MM-dd` (converter, ver Fase 1). Compare sempre `DateUtils.dateOnly(...)`.
   Nunca calcule dias com `difference().inDays` entre horários quaisquer: horário de verão e fuso horário quebram a conta. Use `diasEntre(a, b)` (ver 2.1).
3. **Instantes** (`criadoEm`, `ocorridoEm`, `atualizadoEm`) são `DateTime` em **UTC** no banco e viram hora local só na UI.
4. **"Hoje" vem do `hojeProvider`.** Nunca chame `DateTime.now()` dentro de regra ou tela, para que os testes possam fixar a data.
5. **Enums no banco pelo nome** (`textEnum`). Nunca **renomeie nem remova** um valor de enum que já tenha ido para produção; só adicione novos. Renomear corrompe os dados salvos.
6. **IDs:** `uuid` v4 em `String` para tudo que for sincronizável, mais um `localId` inteiro (autoincremento) usado como ID de notificação.
7. **Exclusão suave:** preencha `excluidoEm` em vez de apagar a linha. Listagens filtram `excluidoEm IS NULL`.
8. **Operações compostas em transação** (`db.transaction`), por exemplo baixar o estoque e registrar a movimentação.
9. **Formatação:** adicionar ao `analysis_options.yaml`:
   ```yaml
   formatter:
     page_width: 120
   analyzer:
     exclude:
       - "**/*.g.dart"
   ```
   Hoje o `dart format` usa 80 colunas e reformata o projeto inteiro; o padrão do projeto é 120.
10. **Quebras de linha:** criar `.gitattributes` com `* text=auto eol=lf` (o Git hoje avisa "LF will be replaced by CRLF").

### 0.5 Fluxo de trabalho por fase
1. `git checkout main && git pull`, depois `git checkout -b <branch-da-fase>`.
2. Implementar seguindo a seção da fase.
3. `dart run build_runner build --delete-conflicting-outputs` (a partir da Fase 1).
4. `flutter analyze` sem nenhum aviso, e `flutter test` passando.
5. Rodar no emulador Android e testar o roteiro manual da fase.
6. Atualizar o `CLAUDE.md` (o que mudou na arquitetura) e marcar a fase como concluída aqui.
7. Commit em pt-BR, push, PR e merge na `main` **antes** de começar a próxima fase.

---

## 1. Modelo de domínio

### 1.1 Enums (`lib/domain/enums.dart`)
Hoje as categorias estão **inconsistentes** entre as telas. A Início usa "Grãos", o Adicionar usa "Grãos" + "Limpeza" + "Outros", e os mocks do Histórico e das Receitas usam "Açougue", "Matinais", "Proteínas" e "Grãos & Cereais".
Passa a valer **uma única lista canônica**:

```dart
enum Categoria {
  hortifruti('Hortifrúti'),
  laticinios('Laticínios'),
  carnes('Carnes'),        // inclui açougue, peixaria, ovos/proteínas
  graos('Grãos'),          // grãos, cereais, massas
  bebidas('Bebidas'),
  padaria('Padaria'),      // pães, matinais
  limpeza('Limpeza'),
  outros('Outros');

  const Categoria(this.label);
  final String label;
}
```
- Ícones, emoji e `CategoryTone` de cada categoria ficam num **mapa na camada de UI** (`features/.../category_style.dart` ou `core/theme`), não no domínio.
  Ícone do chip: `AppIcons.cat*`; ícone do formulário: `AppIcons.addCat*`. **Padaria** não tem ícone próprio ainda: usar `addCatOutros` até chegar um asset.
- Migrar os mocks: Açougue/Proteínas/Peixaria → `carnes`, Matinais → `padaria`, Grãos & Cereais → `graos`.

```dart
enum LocalArmazenamento { geladeira, despensa, freezer } // substitui StorageLocation (manter os mesmos nomes)

enum UnidadeMedida {
  unidade('Unidade(s)', passo: 1),
  kg('kg', passo: 0.5),
  g('g', passo: 100),
  litro('Litro(s)', passo: 0.5),
  ml('ml', passo: 100),
  pacote('Pacote(s)', passo: 1);

  const UnidadeMedida(this.label, {required this.passo});
  final String label;
  final double passo;      // incremento dos steppers
}

enum TipoMovimentacao { consumido, desperdicado }

enum MotivoDescarte {
  vencimento('Vencimento', resultado: 'Vencido'),
  sobras('Sobras', resultado: 'Descartado'),
  deteriorado('Deteriorado', resultado: 'Deteriorado'); // mofo/estragou

  const MotivoDescarte(this.label, {required this.resultado});
  final String label;
  final String resultado; // texto à direita no card do relatório
}
```
- `StorageLocation` (em `models/product.dart`) vira um alias ou é substituído por `LocalArmazenamento`, mantendo os valores `geladeira/despensa/freezer` para não quebrar os widgets.
- `WasteReason` (em `waste_mock_data.dart`) é substituído por `MotivoDescarte`. A cor de cada motivo vai para a UI, num mapa de cores.
- `AddProductOptions.units` passa a ser `UnidadeMedida.values.map((u) => u.label)`.

### 1.2 Entidades

```dart
class Item {
  final int? localId;            // null antes de salvar
  final String uuid;
  final String nome;             // 1..80 caracteres, sem espaços nas pontas
  final String? marca;
  final String? variante;
  final Categoria categoria;
  final LocalArmazenamento local;
  final String? posicao;         // "Prateleira 2", "Porta"
  final double quantidade;       // atual, > 0 enquanto ativo
  final double quantidadeInicial;// quantidade no cadastro (base do preço unitário)
  final UnidadeMedida unidade;
  final String? conteudo;        // tamanho da embalagem, ex.: "1 litro" (texto livre, exibição)
  final int? precoCentavos;      // preço pago pela quantidadeInicial (opcional)
  final DateTime compradoEm;     // data sem hora; padrão = dia do cadastro
  final DateTime venceEm;        // data sem hora; obrigatória
  final DateTime? abertoEm;      // data sem hora
  final bool notificar;          // toggle "Notificar vencimento"
  final String? observacoes;
  final String? fotoPath;        // caminho RELATIVO ao diretório de documentos (Fase 8)
  final String? codigoBarras;
  final DateTime criadoEm;       // UTC
  final DateTime atualizadoEm;   // UTC
  final DateTime? excluidoEm;    // UTC; exclusão suave
}

class Movimentacao {
  final int? localId;
  final String uuid;
  final String itemUuid;         // sem FK rígida (o item pode ser excluído)
  // Cópia ("snapshot") dos dados do item no momento, para os relatórios não mudarem se o item for editado:
  final String nomeItem;
  final Categoria categoria;
  final LocalArmazenamento local;
  final String? posicao;
  final TipoMovimentacao tipo;
  final MotivoDescarte? motivo;  // obrigatório se tipo == desperdicado; null se consumido
  final double quantidade;
  final UnidadeMedida unidade;
  final int valorCentavos;       // valor da quantidade movimentada (0 se o item não tinha preço)
  final int diasParaVencer;      // no momento do evento (negativo = já vencido)
  final DateTime ocorridoEm;     // UTC
  final DateTime atualizadoEm;
  final DateTime? excluidoEm;    // usado pelo "Desfazer"
}

class ItemCompra { uuid, nome, String? quantidadeTexto, bool marcado, OrigemCompra origem, String? receitaId, criadoEm, atualizadoEm, excluidoEm }
enum OrigemCompra { manual, receita, reposicao }

class Configuracoes {
  final int diasAntecedencia;    // 1..7, padrão 3 (substitui AddProductOptions.notifyDaysBefore)
  final int horaAlerta;          // 0..23, padrão 9
  final int minutoAlerta;        // padrão 0
}
```

### 1.3 Item "ativo"
Um item é **ativo** quando `excluidoEm == null && quantidade > 0`. Todas as telas de estoque listam só itens ativos.
Ao consumir ou descartar tudo, o item fica com `quantidade = 0` e **continua no banco**: o histórico precisa dele e o "Desfazer" o restaura.

### 1.4 `Product` vira o modelo da UI
Hoje as telas usam `Product` (`daysToExpire`, `freshness`, `status`, `shortRemaining`, `unitPrice`...). Para **não reescrever os widgets**:
- O `Product` ganha `id` (o uuid do item), `quantidadeValor`, `unidade` e `precoCentavos`, e é criado por
  `Product.fromItem(Item item, DateTime hoje)`, que calcula `daysToExpire`, `freshness` e `quantity` (texto formatado).
- `daysToExpire` e `freshness` continuam sendo campos do `Product`, mas **calculados** no mapeamento, nunca salvos.
- Widgets que recebem `Product` não mudam. O `Product` deixa de ter construtor `const` com dados fixos, e os mocks vão para as fixtures.

---

## 2. Regras de negócio (fórmulas)
Todas são **funções puras** em `lib/domain/regras/`, cada uma com teste unitário. Nos exemplos, `hoje` é uma data sem hora.

### 2.1 Validade (`validade.dart`)
```dart
int diasEntre(DateTime de, DateTime ate) =>
    DateTime.utc(ate.year, ate.month, ate.day).difference(DateTime.utc(de.year, de.month, de.day)).inDays;

int diasParaVencer(Item i, DateTime hoje) => diasEntre(hoje, i.venceEm);   // 0 = vence hoje; <0 = vencido

ExpiryStatus status(int dias) => dias <= 0 ? ExpiryStatus.today
    : dias <= Product.soonThresholdDays ? ExpiryStatus.soon : ExpiryStatus.ok;   // limiar único = 4

double cicloPercorrido(Item i, DateTime hoje) {      // = Product.freshness (0..1)
  final total = diasEntre(i.compradoEm, i.venceEm);
  if (total <= 0) return 1;
  return (diasEntre(i.compradoEm, hoje) / total).clamp(0.0, 1.0);
}
```
Rótulos (já existem parcialmente na UI; centralizar):

| dias | `shortRemaining` | pílula/status |
|---|---|---|
| < 0 | "Vencido" | "Venceu há N dia(s)" |
| 0 | "Hoje!" | "Vence hoje" |
| 1 | "1 dia" | "Vence amanhã" |
| 2..29 | "N dias" | "Vence em N dias" |
| ≥ 30 | "N meses" (`round(dias/30)`) | "No prazo" |

> Atenção: hoje o `ExpiryStatus.today` cobre "vencido" e "vence hoje". Mantenha assim (não crie `expired`) para não mexer nas cores. Só os **textos** distinguem os dois casos.

### 2.2 Valores (`valores.dart`)
```dart
// Valor (centavos) de uma quantidade q do item, proporcional ao preço pago
int valorDe(Item i, double q) =>
    i.precoCentavos == null || i.quantidadeInicial <= 0 ? 0 : (i.precoCentavos! * q / i.quantidadeInicial).round();

int valorRestante(Item i) => valorDe(i, i.quantidade);
int precoUnitario(Item i) => valorDe(i, 1);              // "R$ 6,50 / unidade" na tela de Detalhes
```
**Preço digitado:** o campo "Preço Pago" mantém só os dígitos; "1250" equivale a R$ 12,50, então `precoCentavos = int.parse(digitos)`. Campo vazio vira `null`.

### 2.3 Peso aproximado (relatório de desperdício)
Converter para kg: `kg` × 1; `g` ÷ 1000; `litro` × 1 (aproximação: 1 L ≈ 1 kg); `ml` ÷ 1000. `unidade`/`pacote` **não entram** na soma.
Se a soma der 0, mostrar "—".

### 2.4 Períodos (Histórico)
Sempre fechados nas duas pontas, comparando a data local de `ocorridoEm`:
- **Este mês**: do dia 1 do mês atual até hoje. Rótulo: "Este Mês (Out)", com a abreviação do mês atual.
- **Últimos 30 dias**: de `hoje - 29` até `hoje`.
- **3 meses**: de `hoje - 89` até `hoje`.
- **Este ano**: de 01/01 até hoje.

### 2.5 Métricas (`metricas.dart`)
Definições **propostas**, a confirmar (ver Decisões pendentes):

| Métrica | Fórmula |
|---|---|
| **Consumo geral** (nº de itens) | nº de movimentações `consumido` no período |
| **Aproveitamento** (%) | `consumidas / (consumidas + desperdiçadas)` em nº de movimentações; se o denominador for 0, "—" |
| **Economia do mês** ("R$ X preservados", na Início) | soma de `valorCentavos` das movimentações `consumido` no mês com `diasParaVencer <= soonThresholdDays` (consumido enquanto vencia) |
| **Crescimento da economia** (+94%) | `(mesAtual - mesAnterior) / mesAnterior × 100`, arredondado; se `mesAnterior == 0`, esconder a pílula |
| **Valor em risco hoje** | soma de `valorRestante` dos itens ativos com `status == today` |
| **Prejuízo do mês** | soma de `valorCentavos` das movimentações `desperdicado` no mês atual |
| **Variação do prejuízo** (+R$ 42) | `prejuízoMês - prejuízoMêsAnterior`; positivo em vermelho, com seta para cima; negativo em verde |
| **Motivos** | soma de valor por `motivo` no mês; % = valor do motivo ÷ total; arredondar e garantir que a soma dê 100 (ajustar a diferença no maior) |
| **Ranking de itens** | agrupar `consumido` por `normalizar(nomeItem)`; vezes = nº de movimentações; quantidade = soma por unidade ("14x • 14 Litros"; se houver unidades misturadas, só "14x"); valor = soma; frequência = vezes ÷ maior número de vezes |
| **Ranking por categoria** | mesmo cálculo, agrupado por `categoria` |
| **Dica de economia** | os 2 itens de maior valor no período; participação = valor deles ÷ total; economia estimada = 10% do valor deles, arredondado para múltiplo de R$ 5. É uma heurística: deixar documentado no código |

### 2.6 Textos do relatório de desperdício
- `motivo == vencimento`: se `diasParaVencer < 0`, "Venceu há N dias" (N ≥ 7 vira "há N sem", com `N ~/ 7`); se for 0, "Venceu hoje".
- `deteriorado`: "Estragou antes" (o usuário pode trocar por "Mofo no pacote" se for adicionado um campo de observação no descarte; opcional).
- `sobras`: "Sobra descartada".
- Local mostrado: `local.label`, mais ` • posição` quando existir.

---

## Fase 0: Fundação (`feat/arquitetura-estado`)
**Objetivo:** trocar a infraestrutura sem mudar nada visual. Ao final, o app continua idêntico, mas sem mocks importados nas telas e sem callbacks de navegação repassados entre telas.

### Passos
1. **Pacotes:** `flutter pub add flutter_riverpod go_router uuid` e `flutter pub add --dev mocktail`.
2. **Config:** aplicar as regras 9 e 10 da seção 0.4 e rodar `dart format -l 120 lib test` **num commit separado**, só de formatação.
3. **Domínio:** criar `lib/domain/` com os enums, as entidades e as regras das seções 1 e 2, com testes unitários (ver "Testes").
4. **Relógio** (`lib/core/time/clock.dart`):
   ```dart
   abstract class Clock { DateTime now(); }
   class SystemClock implements Clock { const SystemClock(); @override DateTime now() => DateTime.now(); }
   class FixedClock implements Clock { FixedClock(this.fixed); final DateTime fixed; @override DateTime now() => fixed; }

   final clockProvider = Provider<Clock>((ref) => const SystemClock());

   /// Data de hoje (sem hora). Recalcula ao voltar do background e à meia-noite.
   final hojeProvider = NotifierProvider<HojeNotifier, DateTime>(HojeNotifier.new);
   ```
   O `HojeNotifier`:
   - devolve `DateUtils.dateOnly(clock.now())`;
   - registra um `AppLifecycleListener(onResume: _atualizar)`;
   - agenda um `Timer` até a próxima meia-noite.

   Cancelar ambos em `ref.onDispose`.
5. **Repositórios (interfaces):** em `lib/data/repositories/`:
   ```dart
   abstract class ItemRepository {
     Stream<List<Item>> watchAtivos();
     Stream<Item?> watchPorUuid(String uuid);
     Future<Item> salvar(Item item);            // insert ou update (atualiza atualizadoEm)
     Future<void> excluir(String uuid);          // exclusão suave
   }
   abstract class MovimentacaoRepository {
     Stream<List<Movimentacao>> watchEntre(DateTime inicioUtc, DateTime fimUtc);
     Future<Movimentacao> registrar({required Item item, required TipoMovimentacao tipo, required double quantidade, MotivoDescarte? motivo});
     Future<void> desfazer(String movimentacaoUuid);
   }
   abstract class ComprasRepository { ... }    // Fase 7
   abstract class ReceitaRepository { Future<List<Receita>> catalogo(); Stream<Set<String>> watchFavoritas(); Future<void> alternarFavorita(String id); }
   abstract class ConfigRepository { Stream<Configuracoes> watch(); Future<void> salvar(Configuracoes c); }
   ```
   Implementações `Mock*Repository` com dados em memória (vindos das fixtures) e `StreamController.broadcast`, que emitem a lista atual ao assinar.
   > Atenção: o stream mock precisa emitir o valor atual **para cada novo assinante** (use `Stream.multi` ou um `StreamController` que reemite o último valor). Sem isso, a tela fica carregando para sempre.
6. **Providers** (`lib/app/providers.dart`):
   ```dart
   final itemRepositoryProvider = Provider<ItemRepository>((ref) => MockItemRepository(...)); // Fase 1 troca para Drift
   final itensAtivosProvider = StreamProvider<List<Item>>((ref) => ref.watch(itemRepositoryProvider).watchAtivos());
   final produtosProvider = Provider<AsyncValue<List<Product>>>((ref) {
     final hoje = ref.watch(hojeProvider);
     return ref.watch(itensAtivosProvider).whenData((l) => [for (final i in l) Product.fromItem(i, hoje)]);
   });
   final itemProvider = StreamProvider.family<Item?, String>((ref, uuid) => ref.watch(itemRepositoryProvider).watchPorUuid(uuid));
   ```
7. **Fixtures:** mover os dados de `HomeMockData`, `StockMockData`, `ConsumptionMockData`, `WasteMockData` e `RecipesMockData` para `test/fixtures/fixtures.dart`, que também serve de seed do mock.
   - Usar **data fixa 2026-11-03** e converter `daysToExpire` em `venceEm = hoje + dias`.
   - O que hoje é contagem fixa no mock (ex.: 84 itens, R$ 201,36) passa a ser gerado como movimentações que somam o mesmo valor, para os testes atuais continuarem válidos.
   - Os `*MockData` são apagados no fim desta fase.
8. **Navegação** (`lib/app/router.dart`):
   ```dart
   final rootNavigatorKey = GlobalKey<NavigatorState>();

   final routerProvider = Provider<GoRouter>((ref) => GoRouter(
     navigatorKey: rootNavigatorKey,
     initialLocation: '/inicio',
     routes: [
       StatefulShellRoute.indexedStack(
         builder: (context, state, shell) => MainShell(navigationShell: shell),
         branches: [
           StatefulShellBranch(routes: [GoRoute(path: '/inicio', builder: (_, _) => const HomePage())]),
           StatefulShellBranch(routes: [GoRoute(path: '/estoque', builder: (_, s) => StockPage(categoriaInicial: s.uri.queryParameters['categoria']))]),
           StatefulShellBranch(routes: [GoRoute(path: '/compras', builder: (_, _) => const ShoppingPage())]),
           StatefulShellBranch(routes: [GoRoute(path: '/receitas', builder: (_, _) => const RecipesPage())]),
         ],
       ),
       // Rotas empilhadas: SEMPRE no navigator raiz para cobrir header e bottom nav.
       GoRoute(path: '/item/novo', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => AddProductPage(prefill: s.uri.queryParameters)),
       GoRoute(path: '/item/:id', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => ProductDetailPage(itemId: s.pathParameters['id']!)),
       GoRoute(path: '/item/:id/editar', parentNavigatorKey: rootNavigatorKey, builder: (_, s) => AddProductPage(editarId: s.pathParameters['id'])),
       GoRoute(path: '/historico', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const ConsumptionHistoryPage()),
       GoRoute(path: '/desperdicio', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const WasteReportPage()),
       GoRoute(path: '/notificacoes', parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const NotificationSettingsPage()), // Fase 5
     ],
   ));
   ```
   - `'/item/novo'` precisa vir **antes** de `'/item/:id'`; senão "novo" é lido como id.
   - `MainShell` recebe `StatefulNavigationShell`:
     - o título do header vem de `AppTab.values[shell.currentIndex]`;
     - ao tocar numa aba: `shell.goBranch(i, initialLocation: i == shell.currentIndex)`;
     - o botão "+" chama `context.push('/item/novo')`.
   - Trocar os callbacks atuais:

     | Callback atual | Substituir por |
     |---|---|
     | `onSeeStock` | `context.go('/estoque')` |
     | `onSeeRecipes` | `context.go('/receitas')` |
     | `onSeeUrgentItems` | `context.go('/estoque?status=hoje')` |
     | `ProductDetailPage.onSeeRecipes` | (remover) |
     | `StockPage.onSeeRecipes` | (remover) |

   - `ConsumptionHistoryPage` passa a abrir com `context.push('/historico')`; o card do estoque, com `context.push('/item/${p.id}')`.
9. **App** (`main.dart`):
   ```dart
   void main() => runApp(const ProviderScope(child: MeuEstoqueApp()));
   // MeuEstoqueApp vira ConsumerWidget e usa MaterialApp.router(routerConfig: ref.watch(routerProvider),
   //   scaffoldMessengerKey: rootScaffoldMessengerKey, ... locale/theme iguais aos atuais)
   ```
10. **SnackBars globais** (`snackbar_service.dart`):
    - `rootScaffoldMessengerKey` e uma função `mostrarSnackBar(String msg, {SnackBarAction? acao})`.
    - Isso elimina o padrão atual de "pegar o messenger antes do `pop`" em `AddProductPage._save` e `ProductDetailPage._finish`.
    - A ação "Ver relatório" vira `rootNavigatorKey.currentContext!.push('/desperdicio')` (ou `ref.read(routerProvider).push(...)`).
11. **Telas:** trocar `StatelessWidget`/`StatefulWidget` por `ConsumerWidget`/`ConsumerStatefulWidget` onde forem ler providers. Tratar `AsyncValue` com:
    ```dart
    switch (ref.watch(produtosProvider)) {
      AsyncData(:final value) => ..., AsyncError(:final error) => ErroView(error), _ => const CarregandoView(),
    }
    ```
    Criar `shared/widgets/carregando_view.dart` e `erro_view.dart` (simples, com `AppTextStyles`).

### Testes
- `test/domain/validade_test.dart`:
  - `diasEntre` atravessando o horário de verão (ex.: 2026-10-31 → 2026-11-02 com o fuso `America/Sao_Paulo`; se não houver horário de verão no ano, testar 2018-11-03 → 2018-11-05);
  - virada de ano;
  - `status` em -1, 0, 1, 4, 5;
  - `cicloPercorrido` com compra = vencimento (resultado 1) e hoje antes da compra (resultado 0).
- `test/domain/valores_test.dart`:
  - item sem preço → 0;
  - arredondamento (R$ 10,00 dividido por 3 unidades);
  - consumo parcial.
- `test/domain/metricas_test.dart`: cada linha da tabela 2.5, incluindo denominador 0 e o ajuste para a soma dar 100%.
- `test/widget_test.dart`:
  - adaptar o `pumpWidget` para `ProviderScope(overrides: [clockProvider.overrideWithValue(FixedClock(DateTime(2026, 11, 3))), ...repositórios mock com fixtures], child: MeuEstoqueApp())`;
  - **todas as asserções atuais continuam valendo** (os textos são os mesmos).

### Pronto quando
- `grep -r "MockData" lib/` não encontra nada.
- Nenhum `onSee*` sendo repassado entre telas.
- Navegação: voltar do Android fecha as rotas empilhadas antes de sair do app, e a troca de aba preserva o scroll de cada aba.
- Analyze e testes passando.

### Armadilhas
- `go_router` com `StatefulShellRoute`: cada aba tem seu próprio navigator. Rotas empilhadas **sem** `parentNavigatorKey: rootNavigatorKey` abrem dentro da aba, por baixo da bottom nav.
- Riverpod 3 tenta de novo, automaticamente, providers que dão erro. Nos testes isso pode esconder falhas: use `ProviderScope(retry: (_, _) => null, ...)` nos testes (confira o nome do parâmetro na versão instalada).
- Em `Notifier` com `await`, confira `ref.mounted` antes de alterar o estado depois do `await`.
- `IndexedStack` mantém as abas vivas: providers `autoDispose` lidos por abas não visíveis continuam ativos (comportamento esperado).

---

## Fase 1: Persistência local (`feat/persistencia-local`)
**Objetivo:** os dados sobrevivem ao fechar o app.

### Passos
1. **Pacotes:**
   - `flutter pub add drift drift_flutter path_provider path`
   - `flutter pub add --dev drift_dev build_runner`
2. **`build.yaml`** na raiz (opcional; manter o padrão de `DateTime` em segundos Unix para instantes UTC):
   ```yaml
   targets:
     $default:
       builders:
         drift_dev:
           options:
             databases:
               app: lib/data/db/app_database.dart
   ```
3. **Converter de data sem hora** (`lib/data/db/converters.dart`):
   ```dart
   class DataSemHoraConverter extends TypeConverter<DateTime, String> {
     const DataSemHoraConverter();
     @override DateTime fromSql(String v) { final p = v.split('-').map(int.parse).toList(); return DateTime(p[0], p[1], p[2]); }
     @override String toSql(DateTime d) =>
         '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
   }
   ```
   Para colunas que aceitam nulo (`abertoEm`), use `NullAwareTypeConverter.wrap(const DataSemHoraConverter())`.
4. **Tabelas** (`lib/data/db/app_database.dart`):
   ```dart
   @DataClassName('ItemRow')
   class Itens extends Table {
     IntColumn get localId => integer().autoIncrement()();          // PK (autoIncrement já implica PK)
     TextColumn get uuid => text().unique()();
     TextColumn get nome => text().withLength(min: 1, max: 80)();
     TextColumn get marca => text().nullable()();
     TextColumn get variante => text().nullable()();
     TextColumn get categoria => textEnum<Categoria>()();
     TextColumn get local => textEnum<LocalArmazenamento>()();
     TextColumn get posicao => text().nullable()();
     RealColumn get quantidade => real()();
     RealColumn get quantidadeInicial => real()();
     TextColumn get unidade => textEnum<UnidadeMedida>()();
     TextColumn get conteudo => text().nullable()();
     IntColumn get precoCentavos => integer().nullable()();
     TextColumn get compradoEm => text().map(const DataSemHoraConverter())();
     TextColumn get venceEm => text().map(const DataSemHoraConverter())();
     TextColumn get abertoEm => text().map(NullAwareTypeConverter.wrap(const DataSemHoraConverter())).nullable()();
     BoolColumn get notificar => boolean().withDefault(const Constant(true))();
     TextColumn get observacoes => text().nullable()();
     TextColumn get fotoPath => text().nullable()();
     TextColumn get codigoBarras => text().nullable()();
     DateTimeColumn get criadoEm => dateTime()();
     DateTimeColumn get atualizadoEm => dateTime()();
     DateTimeColumn get excluidoEm => dateTime().nullable()();
   }

   @DataClassName('MovimentacaoRow')
   @TableIndex(name: 'idx_mov_ocorrido', columns: {#ocorridoEm})
   class Movimentacoes extends Table {
     IntColumn get localId => integer().autoIncrement()();
     TextColumn get uuid => text().unique()();
     TextColumn get itemUuid => text()();
     TextColumn get nomeItem => text()();
     TextColumn get categoria => textEnum<Categoria>()();
     TextColumn get local => textEnum<LocalArmazenamento>()();
     TextColumn get posicao => text().nullable()();
     TextColumn get tipo => textEnum<TipoMovimentacao>()();
     TextColumn get motivo => textEnum<MotivoDescarte>().nullable()();
     RealColumn get quantidade => real()();
     TextColumn get unidade => textEnum<UnidadeMedida>()();
     IntColumn get valorCentavos => integer()();
     IntColumn get diasParaVencer => integer()();
     DateTimeColumn get ocorridoEm => dateTime()();
     DateTimeColumn get atualizadoEm => dateTime()();
     DateTimeColumn get excluidoEm => dateTime().nullable()();
   }

   class ItensCompra extends Table { /* uuid, nome, quantidadeTexto?, marcado, origem(textEnum), receitaId?, criadoEm, atualizadoEm, excluidoEm? */ }
   class ReceitasFavoritas extends Table { TextColumn get receitaId => text()(); DateTimeColumn get criadoEm => dateTime()();
     @override Set<Column> get primaryKey => {receitaId}; }
   class ConfiguracoesTabela extends Table {           // linha única, id = 1
     IntColumn get id => integer().withDefault(const Constant(1))();
     IntColumn get diasAntecedencia => integer().withDefault(const Constant(3))();
     IntColumn get horaAlerta => integer().withDefault(const Constant(9))();
     IntColumn get minutoAlerta => integer().withDefault(const Constant(0))();
     @override Set<Column> get primaryKey => {id};
   }

   @DriftDatabase(tables: [Itens, Movimentacoes, ItensCompra, ReceitasFavoritas, ConfiguracoesTabela])
   class AppDatabase extends _$AppDatabase {
     AppDatabase([QueryExecutor? executor]) : super(executor ?? driftDatabase(name: 'meu_estoque'));
     @override int get schemaVersion => 1;
     @override MigrationStrategy get migration => MigrationStrategy(
       onCreate: (m) async {
         await m.createAll();
         await into(configuracoesTabela).insert(const ConfiguracoesTabelaCompanion());   // linha padrão
       },
       beforeOpen: (details) async => customStatement('PRAGMA foreign_keys = ON'),
     );
   }
   ```
   > `textEnum` grava o **nome** do enum. A tabela `Itens` gera a classe `ItemRow`; o `@DataClassName` existe para não colidir com a entidade de domínio `Item`.
5. **Gerar o código:** `dart run build_runner build --delete-conflicting-outputs`. **Commitar** os `*.g.dart`, para que analyze e testes rodem sem a etapa de geração.
6. **Repositórios Drift** (`DriftItemRepository`, etc.):
   - converter `ItemRow` ↔ `Item` em funções `toDomain`/`toCompanion` (num arquivo `mappers.dart`);
   - `watchAtivos()`: `(select(itens)..where((t) => t.excluidoEm.isNull() & t.quantidade.isBiggerThanValue(0))..orderBy([(t) => OrderingTerm.asc(t.venceEm)])).watch()`;
   - `salvar()`: preencher `atualizadoEm = clock.now().toUtc()`; no insert, também `criadoEm` e `uuid = const Uuid().v4()`.
7. **Banco nos providers:**
   ```dart
   final databaseProvider = Provider<AppDatabase>((ref) { final db = AppDatabase(); ref.onDispose(db.close); return db; });
   final itemRepositoryProvider = Provider<ItemRepository>((ref) => DriftItemRepository(ref.watch(databaseProvider), ref.watch(clockProvider)));
   ```
8. **Seed de desenvolvimento** (`lib/data/seed/dev_seed.dart`): se `kDebugMode` e a tabela `itens` estiver vazia, inserir os dados das fixtures. **Nunca** rodar em release (`assert` ou `if (kDebugMode)`).
9. **Migrations futuras:**
   - a cada mudança de schema, subir o `schemaVersion` e implementar `onUpgrade` com `m.addColumn(...)`/`m.createTable(...)`;
   - usar `dart run drift_dev make-migrations` para gerar snapshots do schema e testes de migration;
   - nunca editar uma migration que já foi publicada.

### Web
O target web existe no projeto.
- **Opção A (recomendada por ora):** web só como prévia, usando os repositórios mock (`if (kIsWeb)` em `databaseProvider`/`itemRepositoryProvider`).
- **Opção B:** Drift na web exige `sqlite3.wasm` e `drift_worker.js` dentro de `web/` (ver a documentação do `drift_flutter`). Notificações locais não funcionam na web de qualquer forma.

### Testes
- `test/data/item_repository_test.dart` com `AppDatabase(NativeDatabase.memory())` (`import 'package:drift/native.dart'`):
  - salvar → `watchAtivos` emite;
  - excluir → some da lista;
  - quantidade 0 → some;
  - ordenação por `venceEm`;
  - ida e volta da data sem hora (o dia não muda em nenhum fuso).
- Chamar `await db.close()` no `tearDown`.
- Se o `flutter test` no Windows falhar com "Failed to load dynamic library sqlite3", seguir a seção de testes da documentação do `drift`/`sqlite3` (instalar a `sqlite3.dll` no PATH ou usar o mecanismo de bibliotecas nativas da versão instalada).

### Pronto quando
Cadastrar (via seed), fechar o app de verdade (deslizar para fechar) e abrir de novo: o mesmo estoque aparece.

---

## Fase 2: Ciclo de vida do item (`feat/crud-itens`)
**Objetivo:** cadastrar, editar, consumir, descartar e desfazer, tudo salvo no banco.

### 2.1 Adicionar Item
Converter a `AddProductPage` em `ConsumerStatefulWidget` com um `AddItemController`:
`NotifierProvider.autoDispose<AddItemController, AddItemState>` guardando os campos do formulário.

**Validação no "Salvar no Estoque"**, mostrando o erro abaixo de cada campo:

| Campo | Regra | Mensagem |
|---|---|---|
| Nome | `trim()` com 1 a 80 caracteres | "Informe o nome do produto" (já existe) |
| Validade | obrigatória | "Informe a data de validade" |
| Validade no passado | permitido, mas pede confirmação | diálogo "Este item já está vencido. Salvar mesmo assim?" |
| Quantidade | > 0 | (o stepper já impede ≤ 0) |
| Preço | ≥ 0, opcional | n/a |

**Mapeamento dos campos atuais:**

| Campo atual | Vira |
|---|---|
| `_category` | `Categoria` |
| `_unit` | `UnidadeMedida` |
| `_quantity` | `quantidade` e `quantidadeInicial` (iguais no cadastro) |
| `_location` | `local` |
| `_notify` | `notificar` |
| preço | `precoCentavos` |
| `compradoEm` | hoje |

- O stepper de quantidade usa `unidade.passo`, e o valor é exibido sem ",0" quando é inteiro.
- **Duplo toque:** desabilitar o botão enquanto salva (`isSaving`).
- **Saída sem salvar:** `PopScope` com diálogo "Descartar alterações?" se algum campo foi preenchido.
- **Depois de salvar:** `context.pop()` e SnackBar global `"<nome>" salvo no estoque`.
- **Pré-preenchimento** por query params (`/item/novo?nome=Leite&categoria=laticinios`), usado pela Fase 7.
- **Modo edição** (`/item/:id/editar`): carrega o item, título "Editar Item", e salvar faz update (mantém `uuid`, `criadoEm` e `quantidadeInicial`, a não ser que a quantidade aumente; ver 2.3).

### 2.2 Detalhes do Item
- `ProductDetailPage(itemId)` lê `itemProvider(itemId)`. Se vier `null` (item excluído), executa `context.pop()`.
- **"Editar"** (lápis) → `context.push('/item/$id/editar')`.
- **"Mais opções"** (⋮) → menu com **"Excluir item"**: diálogo de confirmação, depois exclusão suave, **sem** movimentação (é correção de cadastro), e cancelamento das notificações (Fase 5).
- **"Compartilhar":** fica para depois (`share_plus`) ou é escondido.

### 2.3 Movimentações (o coração)
Um caso de uso `MovimentarEstoque`, em `lib/domain/casos_uso/` ou num `Notifier`, sempre dentro de **uma transação**:

```
consumir(item, q) / descartar(item, q, motivo):
  q = min(q, item.quantidade)
  mov = Movimentacao(snapshot do item, tipo, motivo, q, valorDe(item, q), diasParaVencer(item, hoje), ocorridoEm = agoraUtc)
  item.quantidade -= q               (o item com 0 sai das listas)
  salvar ambos; retornar mov.uuid
desfazer(movUuid):
  mov.excluidoEm = agora; item.quantidade += mov.quantidade   (na mesma transação)
```

**Gatilhos na UI:**

| Ação | Efeito | SnackBar |
|---|---|---|
| Detalhes → **"Marcar como Consumido"** | consome **tudo** e fecha a tela | `"<nome>" marcado como consumido` + **Desfazer** |
| Detalhes → **"Registrar como Desperdiçado"** | abre um painel com o **motivo** (3 opções, `MotivoDescarte`) e descarta tudo | `... registrado como desperdício` + **Ver relatório**; o Desfazer fica disponível no relatório (ver Fase 4) |
| Detalhes → stepper **"−"** | consome `unidade.passo` (consumo parcial registrado) | "Consumido 1 un • Desfazer" |
| Detalhes → stepper **"+"** | aumenta `quantidade` **e** `quantidadeInicial` em `passo`, e aumenta `precoCentavos` proporcionalmente (mantém o preço unitário); **sem** movimentação | n/a |
| Estoque → card **"Consumir"** | igual a "Marcar como Consumido" (tudo) | com Desfazer |
| Estoque → card **"Descartar"** | painel de motivo, depois descarta tudo | com Desfazer |

- Uma SnackBar com Desfazer dura **5 segundos**. Mostrar uma nova fecha a anterior (`hideCurrentSnackBar`).
- **Painel de motivo:** um widget novo em `shared/widgets/discard_reason_sheet.dart`, porque é usado em 2 telas.

### Testes
- Unidade (banco em memória):
  - consumir parcial e total;
  - valor proporcional;
  - snapshot de `diasParaVencer`;
  - desfazer restaura a quantidade e "exclui" a movimentação;
  - descartar sem motivo lança `ArgumentError`.
- Widget:
  - cadastrar um item novo → aparece no Estoque;
  - consumir pelo card → some e aparece a SnackBar → Desfazer → volta;
  - editar o nome → atualiza no Estoque.

### Pronto quando
Todo botão de ação dessas telas faz o que diz, e o efeito sobrevive a fechar e abrir o app.

---

## Fase 3: Números da Início e do Estoque (`feat/metricas-inicio`)
**Objetivo:** nenhum número fixo nas telas Início e Estoque.

| Elemento (arquivo atual) | Fonte |
|---|---|
| Banner "Produtos que vencem hoje" (`expiring_today_banner.dart`) | ativos com `status == today`, ordenados por `venceEm`; até 3 fotos; "N itens"; valor em risco (2.5) |
| "Ver todos" do banner | `context.go('/estoque?status=hoje')` |
| Pílula "Economia inteligente do mês" (`savings_pill.dart`) | economia do mês + crescimento (2.5); tocar → `/historico` |
| Chips de categoria (`category_chips.dart`) | `Categoria.values`; tocar → `context.go('/estoque?categoria=<nome>')` |
| Resumo do Estoque (`storage_summary_card.dart`) | contagem de ativos por `local`; ocupação = contagem ÷ capacidade (**ver Decisões pendentes**; padrão: geladeira 24, despensa 64, freezer 32 itens, configurável depois) |
| "N itens no total" | contagem de ativos |
| Últimos itens cadastrados (`recent_item_card.dart`) | 4 ativos mais recentes por `criadoEm` |
| Banner "O que cozinhar hoje?" | nº de receitas com pelo menos 1 ingrediente urgente (Fase 6; até lá, nº total do catálogo) |
| Sino do header (`AppTopBar.notificationCount`) | nº de ativos com status `today` ou `soon` |
| Badge da aba Compras (`shoppingBadge`) | itens de compra não marcados (Fase 7; até lá, 0 e escondido) |
| Estoque: filtros de status, local e busca | já existem; passam a operar sobre `produtosProvider`; `StockPage` lê os query params `status`/`categoria` como filtro inicial |
| Barra de resumo do Estoque (`stock_summary_bar.dart`) | "Total: N itens • R$ X": soma de `valorRestante` dos ativos |

Criar providers derivados em `lib/app/providers.dart` (`resumoInicioProvider`, `contagemAlertasProvider`), que combinam `produtosProvider`, `movimentacoesDoMesProvider` e `hojeProvider`.

### Testes
- Testes de widget com fixtures cobrindo cada número da tabela.
- Teste mudando o `FixedClock` para o dia seguinte: o banner "vence hoje" muda.

---

## Fase 4: Relatórios (`feat/relatorios`)

### 4.1 Histórico de Consumo
- `movimentacoesNoPeriodoProvider = StreamProvider.family<List<Movimentacao>, ConsumptionPeriod>`. Converter o período (2.4) em intervalo UTC: do início do primeiro dia local até o fim do último.
- Ranking por item e por categoria, card "Consumo geral" + aproveitamento e "Dica inteligente", seguindo a seção 2.5.
- O rótulo "Este Mês (Out)" usa a abreviação do mês atual.
- **Estado vazio:** sem movimentações no período, mostrar "Nenhum consumo registrado neste período" no lugar do ranking e esconder a dica.
- O emoji de cada item vem de `categoria` (mapa da UI). Tons: `CategoryTone` por categoria.

### 4.2 Desperdício de Alimentos
- Fonte: movimentações `desperdicado` do mês atual (e do mês anterior, para a variação).
- O cabeçalho dos motivos usa `formatMonthYear` (já existe).
- "6 mais recentes" passa a ser a contagem real, até 6, ordenada por `ocorridoEm` decrescente.
- **Desfazer:** arrastar um item da lista para o lado (`Dismissible`) mostra "Desfazer descarte?" e chama `desfazer(movUuid)`.
- "Ver Receitas Rápidas" → `context.go('/receitas')`; "Ajustar Notificações" → `context.push('/notificacoes')` (Fase 5).
- **Estado vazio:** "Nenhum desperdício este mês 🎉" com os cards zerados.

### Testes
- Fixtures com movimentações em 3 meses diferentes: verificar cada período e cada número.
- Teste do arredondamento dos motivos somando 100%.

---

## Fase 5: Notificações (`feat/notificacoes`)
**Objetivo:** avisar antes de vencer, mesmo com o app fechado.

### Configuração nativa
- `flutter pub add flutter_local_notifications timezone flutter_timezone`

**Android** (`android/app/build.gradle.kts`):
```kotlin
android { compileOptions { isCoreLibraryDesugaringEnabled = true } }
dependencies { coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4") } // conferir a versão exigida no README do plugin
```
`AndroidManifest.xml`:
- adicionar `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` e `RECEIVE_BOOT_COMPLETED`;
- adicionar os `receiver` `ScheduledNotificationReceiver` e `ScheduledNotificationBootReceiver`, **copiados do README da versão instalada**.

Usar `AndroidScheduleMode.inexactAllowWhileIdle`. Ele não exige a permissão de alarme exato, que a Play Store restringe; o aviso pode atrasar alguns minutos, o que é aceitável.

Criar um canal `validade` com nome "Alertas de validade" e importância alta.

**iOS:**
- pedir permissão por `requestPermissions(alert: true, badge: true, sound: true)` no primeiro item salvo com `notificar = true`, nunca na abertura do app;
- configurar o `AppDelegate` conforme o README.

### Fuso horário
Na inicialização, antes do `runApp`, depois de `WidgetsFlutterBinding.ensureInitialized()`:
```dart
tz.initializeTimeZones();
final local = await FlutterTimezone.getLocalTimezone();     // em versões recentes retorna um objeto: usar .identifier (conferir a API)
tz.setLocalLocation(tz.getLocation(local.identifier));
```

### Regras de agendamento (`NotificacaoService`)
Para cada item ativo com `notificar == true`:

| Aviso | Quando | Texto |
|---|---|---|
| Antecipado | `venceEm - diasAntecedencia` às `horaAlerta:minutoAlerta` | "🥛 Leite Integral vence em 3 dias", com `local • posição` no corpo |
| No dia | `venceEm` às `horaAlerta:minutoAlerta` | "⚠️ Leite Integral vence hoje", com "Consuma ou registre o descarte" |

- Datas no passado **não são agendadas**.
- **IDs:** `item.localId * 10 + 1` (antecipado) e `item.localId * 10 + 2` (no dia). `payload` = `item.uuid`.

**Reconciliação** (essencial; o iOS aceita no máximo **64** notificações pendentes):
```
reconciliar():
  pendentes = calcular todos os avisos futuros dos itens ativos
  ordenar por data; manter os 60 primeiros
  cancelAll(); agendar esses 60
```
Chamar `reconciliar()`:
- ao abrir o app;
- ao voltar do background;
- depois de qualquer salvar, consumir, descartar, desfazer ou excluir (com espera de 2 s entre chamadas seguidas);
- ao mudar as configurações.

Tocar na notificação → `router.push('/item/<payload>')`. Para o app aberto a partir de uma notificação (app estava fechado), ler `getNotificationAppLaunchDetails()` na inicialização.

### Tela "Ajustar Notificações" (`/notificacoes`)
- **Conteúdo:** antecedência (1 a 7 dias, stepper), horário (`showTimePicker`) e um link para as configurações do sistema se a permissão foi negada.
- **Design:** sem design no Figma; seguir o padrão visual atual (usar `AppTitleTopBar`, `DetailCard`, `form_widgets`).
- **Card do formulário:** o "Notificar vencimento" de Adicionar Item passa a mostrar `"Avisar ${config.diasAntecedencia} dias antes"`.

### Testes
- Unidade: `NotificacaoService` com um adaptador falso do plugin. Cobrir:
  - datas no passado ignoradas;
  - limite de 60;
  - IDs;
  - mudança de antecedência reagenda.
- Manual (Android):
  1. Criar um item vencendo amanhã, com antecedência de 1 dia e horário daqui a 2 minutos.
  2. Fechar o app e confirmar que a notificação chega.
  3. Tocar nela e confirmar que abre os Detalhes do item.
  4. Reiniciar o aparelho e confirmar que o próximo aviso continua agendado.

### 5b: Widget de tela de bloqueio/início (`feat/widget-tela-inicio`, opcional)
Frame "Widget Tela de Bloqueio" do Figma. Exige código nativo:
- **Android:** `AppWidgetProvider` + layout XML.
- **iOS:** extensão WidgetKit em Swift + **App Group** compartilhado.

Com `home_widget`:
- o app grava um resumo (até 4 itens vencendo) em `HomeWidget.saveWidgetData` sempre que roda o `reconciliar()`;
- depois chama `HomeWidget.updateWidget`.

Planejar como fase própria: é a parte com mais código nativo do projeto.

---

## Fase 6: Receitas (`feat/receitas-logica`)

### Catálogo (`assets/data/receitas.json`; registrar `assets/data/` no `pubspec.yaml`)
```json
[
  {
    "id": "omelete-tomate-queijo",
    "nome": "Omelete Cremosa com Tomate e Queijo",
    "imagem": "assets/images/receita_omelete.jpg",
    "minutos": 10,
    "dificuldade": "Fácil",
    "rendimento": "🍳 1 porção",
    "tags": ["vegetariano", "semGluten"],
    "ingredientes": [
      { "nome": "Ovos", "termos": ["ovo"], "essencial": true },
      { "nome": "Tomate", "termos": ["tomate"], "essencial": true },
      { "nome": "Queijo", "termos": ["queijo", "mussarela", "prato"], "essencial": true },
      { "nome": "Sal", "termos": ["sal"], "essencial": false, "basico": true }
    ],
    "preparo": ["Bata os ovos com sal.", "Adicione o tomate e o queijo.", "Cozinhe em fogo baixo por 5 minutos."]
  }
]
```
- `basico: true` (sal, óleo, água) **não conta** em "Você tem X/Y" nem em "Falta".
- As imagens das receitas novas precisam ser adicionadas a `assets/images/` e ao `AppImages`.
- A chave `imagem` do JSON é usada direto no `Image.asset`: é a **única exceção** à regra "caminhos só via `AppImages`". Documentar no `CLAUDE.md`.
- Validar o JSON num teste: ids únicos e todas as imagens existentes (`File(path).existsSync()` no teste).

### Comparação com o estoque (`receitas_match.dart`)
```
normalizar(s) = minúsculas, sem acento (mapa á→a, ç→c...), espaços colapsados
ingrediente casa com item ativo se algum termo T: normalizar(item.nome) contém T como palavra inteira (regex \bT)
  (aceitar também o plural simples: termo + "s")
para cada receita:
  usados = itens ativos que casaram (o mais urgente por ingrediente)
  tem = nº de ingredientes não-básicos com match; total = nº de ingredientes não-básicos
  faltantes = ingredientes não-básicos sem match
  urgência = menor diasParaVencer entre os usados (null se nenhum)
  urgentes = usados com status today/soon
  valorSalvo = soma de valorRestante dos urgentes
```
- **Ordenação:** nº de urgentes (desc), faltantes (asc), minutos (asc).
- **Card** (`recipe_card.dart`):
  - **selo:** a partir da urgência (usar `status(dias)` e os rótulos de 2.1); sem urgência, mostrar a dica (`tip`) ou nada;
  - **faixa de aproveitamento:** "Usa N itens críticos: A e B" (verde) se `faltantes` estiver vazio; senão "Aproveita: A" (âmbar);
  - **selo da faixa:** `"Salva ${formatCentavos(valorSalvo)}"`, ou `"Falta N item(ns)"`;
  - **rodapé:** "Você tem tem/total ingredientes" + "Ver Preparo"; ou "Tem tem/total (Falta X)" + "+ Lista".
- **Banner Desperdício Zero:**
  - itens urgentes = ativos `today`/`soon` (chips: vermelho se `today`, âmbar se `soon`; até 3 + "Ver N itens");
  - economia = soma de `valorRestante` dos urgentes que aparecem em pelo menos uma receita.
- **Filtros:** já existem. "Vencendo Hoje" = urgência ≤ 0; os demais pelas tags.
- **Favoritas:** salvas na tabela `ReceitasFavoritas`. Adicionar um filtro "♥ Favoritas" opcional.
- **"Ver Preparo":** nova rota `/receita/:id` com foto, ingredientes (✓ tem / ✗ falta) e passos numerados. **Sem design**: seguir o padrão visual.
- **"+ Lista":** adiciona `faltantes` em Compras (Fase 7; até lá, só a SnackBar), sem duplicar: compara `normalizar(nome)` com os itens não marcados.

### Testes
- Comparação com plural, acentos e "queijo" casando com "Queijo Mussarela Fatiado".
- Ingrediente básico ignorado.
- Ordenação.
- Valor salvo.

---

## Fase 7: Compras (`feat/compras`)
- **Precisa de design no Figma** antes de começar. Peça o frame. Conteúdo mínimo esperado:
  - campo "Adicionar item";
  - lista agrupada em "A comprar" e "Comprados";
  - origem ("da receita X");
  - limpar os comprados.
- **Repositório:** `ComprasRepository` (watch, adicionar com deduplicação, marcar/desmarcar, remover, limpar marcados).
- **Marcar como comprado:** SnackBar "Adicionar ao estoque?" → `context.push('/item/novo?nome=<nome>')`.
- **Badge da aba:** nº de não marcados (esconder quando for 0).
- **Reposição (opcional):** ao consumir o último item de um nome que já foi comprado 2 ou mais vezes, sugerir "Adicionar à lista de compras?".

---

## Fase 8: Câmera e código de barras (`feat/camera-scanner`)

### Fotos (`image_picker`)
- `ios/Runner/Info.plist`: `NSCameraUsageDescription` = "Para fotografar seus produtos" e `NSPhotoLibraryUsageDescription` = "Para escolher fotos dos seus produtos".
- `pickImage(source: ..., maxWidth: 1080, imageQuality: 75)`.
- **Copie o arquivo** para `getApplicationDocumentsDirectory()/fotos/<uuid>.jpg` e salve **só o caminho relativo** `fotos/<uuid>.jpg`.
  - O caminho devolvido pelo picker é temporário.
  - No iOS, o caminho absoluto do container muda entre atualizações do app.
- Ao exibir, montar o caminho completo e usar `Image.file`, com `errorBuilder` caindo no ícone da categoria.
- Ao excluir o item, apagar o arquivo.
- Itens sem foto usam a imagem da categoria. As imagens do Figma ficam só no seed de desenvolvimento.

### Código de barras (`mobile_scanner`)
- `NSCameraUsageDescription` (o mesmo texto já serve).
- Botão de escanear no campo "Nome do Produto" (precisa de um ícone novo em `AppIcons`).
- **Consulta à Open Food Facts:**
  ```
  GET https://world.openfoodfacts.org/api/v2/product/<codigo>.json?fields=product_name,brands,quantity,categories_tags
  Header: User-Agent: MeuEstoque/1.0 (contato@seu-email)
  ```
  - `status == 1` → preencher nome (`product_name`), marca (`brands`, primeiro item antes da vírgula) e conteúdo (`quantity`);
  - categoria: mapear `categories_tags` (en:dairies → laticinios, en:beverages → bebidas, en:meats → carnes...); sem correspondência → `outros`.
  - Timeout de 8 s. Sem internet ou produto não encontrado → SnackBar "Produto não encontrado, preencha manualmente", **sem travar** o formulário.
  - Guardar `codigoBarras` no item. Antes de consultar a API, procurar no próprio banco um item com o mesmo código e reaproveitar os dados dele.

---

## Fase 9: Nuvem e família (`feat/sync-supabase`, opcional)

### Backend (Supabase)
- **Tabelas espelhando as locais:** mesmas colunas, `uuid` como PK, mais `casa_id uuid not null`.
- **Casas e membros:** tabelas `casas(id, nome, criado_por)` e `membros(casa_id, user_id, papel)`.
- **RLS** em todas as tabelas: `using (casa_id in (select casa_id from membros where user_id = auth.uid()))`.
- **Gatilho** atualizando `atualizado_em = now()` em cada update.
- **Fotos:** bucket de Storage `fotos` com política por `casa_id`.

### App
- **Credenciais:** `supabase_flutter`; URL e anon key via `--dart-define-from-file=env.json`. O `env.json` vai no `.gitignore`; **nunca** commitar chaves.
- **Login:**
  - e-mail mágico e/ou Google;
  - telas de login e criação/entrada em casa (por código de convite);
  - sem design no Figma.
- **Sincronização offline-first:**
  1. **Envio:** tabela local `sync_pendentes(tabela, uuid, operacao)`, preenchida em cada `salvar`/`excluir`. Um `SyncService` envia em lotes (`upsert`) quando há conexão.
  2. **Recebimento:** guardar `ultimoSync` por tabela; baixar `where atualizado_em > ultimoSync`; aplicar localmente se `remoto.atualizadoEm > local.atualizadoEm` (vence a última gravação).
  3. **Tempo real:** canal Realtime por `casa_id` dispara um recebimento imediato.
  4. **Gatilhos de sincronização:** ao abrir o app, ao voltar do background, ao recuperar a rede e a cada 15 min com o app aberto.
- **Primeiro login com dados locais:** perguntar "Enviar seu estoque atual para a nuvem?" e enviar tudo.
- **Notificações e widget** continuam locais: rodar o `reconciliar()` depois de cada recebimento.

### Testes
- Conflito: duas edições do mesmo item, vence a mais recente.
- Exclusão sincronizada.
- Fila de envio sobrevive a fechar o app.

---

## Fase 10: Qualidade e publicação
- **CI** (`.github/workflows/ci.yml`): disparar em `pull_request` com os passos:
  1. `subosito/flutter-action` fixando a versão 3.47.x;
  2. `flutter pub get`;
  3. `dart run build_runner build --delete-conflicting-outputs`;
  4. `git diff --exit-code`, para garantir que os `.g.dart` commitados estão atualizados;
  5. `flutter analyze`;
  6. `flutter test`.
- **Erros em produção:** `sentry_flutter` ou Firebase Crashlytics. Envolver o `runApp` e configurar `FlutterError.onError`.
- **Ícone e splash:** `flutter_launcher_icons` e `flutter_native_splash` com o logo do app.
- **Identificador do app:** decidir o final antes da 1ª publicação (hoje `br.com.meuestoque.meu_estoque`). Mudá-lo depois de publicado cria outro app na loja.
- **Android:** chave de assinatura (`key.properties` fora do git) e `flutter build appbundle`.
- **iOS:** conta Apple Developer, perfis de assinatura e `flutter build ipa`.
- **Header:**
  - busca global → `/estoque` com foco no campo de busca;
  - perfil → tela simples (nome, casa, configurações, sobre, versão).
- **Primeiro uso:** 3 telas de boas-vindas + pedido da permissão de notificação no momento certo.
- **Acessibilidade:**
  - `Semantics` nos botões só com ícone (alguns já têm `tooltip`);
  - contraste;
  - teste com fonte do sistema em 1,3×.

---

## Armadilhas conhecidas (checklist)
- [ ] `double` para dinheiro → usar centavos (`int`).
- [ ] `DateTime.now()` espalhado → usar `clockProvider`/`hojeProvider`.
- [ ] `difference().inDays` com horas → usar `diasEntre` com `DateTime.utc` sem hora.
- [ ] Renomear um valor de enum gravado no banco → proibido; só adicionar.
- [ ] Rota empilhada sem `parentNavigatorKey: rootNavigatorKey` → abre por baixo da bottom nav.
- [ ] `'/item/:id'` declarado antes de `'/item/novo'` → "novo" vira id.
- [ ] Mostrar SnackBar com o `context` de uma tela que acabou de dar `pop` → usar o `rootScaffoldMessengerKey`.
- [ ] Stream mock que não reemite o valor atual para cada novo assinante → tela carregando para sempre.
- [ ] Esquecer `db.transaction` em consumir/descartar/desfazer → estoque e histórico divergem.
- [ ] Mais de 64 notificações no iOS → reconciliar só as 60 mais próximas.
- [ ] Alarme exato no Android → usar `inexactAllowWhileIdle`.
- [ ] Caminho absoluto de foto salvo no banco → salvar relativo.
- [ ] Seed de desenvolvimento rodando em release → proteger com `kDebugMode`.
- [ ] `dart format` sem `page_width: 120` → reformata o projeto inteiro.
- [ ] Esquecer de rodar `build_runner` depois de mudar uma tabela → erro de compilação ou `.g.dart` desatualizado (a CI pega).
- [ ] Mudar o schema sem subir `schemaVersion` e sem `onUpgrade` → app quebra para quem já tem o banco.
- [ ] Testes de widget sem `ProviderScope` com overrides → usam banco/relógio reais e ficam instáveis.

---

## Decisões pendentes
1. **Nuvem:** começar só no aparelho (recomendado) ou já com Supabase?
2. **Métricas (2.5):** as definições de economia, aproveitamento e dica servem?
3. **Ocupação do Resumo do Estoque:** usar a capacidade padrão (geladeira 24, despensa 64, freezer 32 itens) configurável, ou trocar a barra por outra informação?
4. **Categorias canônicas (1.1):** a lista de 8 categorias está boa?
5. **Telas sem design:** Compras, Preparo da receita, Ajustar Notificações, Login/Casa, Perfil e Boas-vindas. Desenhar no Figma ou seguir o padrão visual atual?
6. **Web:** manter só como prévia com dados mock (recomendado) ou suportar banco na web?

## Status das fases
| Fase | Branch | Status |
|---|---|---|
| 0 Fundação | `feat/arquitetura-estado` | ⏳ |
| 1 Persistência local | `feat/persistencia-local` | ⏳ |
| 2 Ciclo de vida do item | `feat/crud-itens` | ⏳ |
| 3 Números da Início e do Estoque | `feat/metricas-inicio` | ⏳ |
| 4 Relatórios | `feat/relatorios` | ⏳ |
| 5 Notificações | `feat/notificacoes` | ⏳ |
| 5b Widget de tela | `feat/widget-tela-inicio` | ⏳ |
| 6 Receitas | `feat/receitas-logica` | ⏳ |
| 7 Compras | `feat/compras` | ⏳ |
| 8 Câmera e código de barras | `feat/camera-scanner` | ⏳ |
| 9 Nuvem e família | `feat/sync-supabase` | ⏳ |
| 10 Qualidade e publicação | n/a | ⏳ |

As Fases **0 a 5** já deixam o app funcional no dia a dia.
