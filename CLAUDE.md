# Meu Estoque

App Flutter de controle de alimentos em casa (validade, locais de armazenamento, economia, receitas).
Idioma da UI e dos nomes de domínio: **português (pt-BR)**. Código (classes, variáveis) pode misturar PT para domínio e EN para técnico.

## Fase atual
1. **Visual pronto**: todas as telas do Figma implementadas.
2. **Modo apresentação** (ver `PLANO_BACKEND.md`): lógica só local, sem back-end.
   - Estado central: `lib/data/estoque_store.dart` (`estoque`, `ChangeNotifier` + `shared_preferences`).
   - Telas leem `estoque.produtos`/`porId`/`recentes` e escutam mudanças; ações em `shared/widgets/stock_actions.dart`.
   - Relatórios (Histórico, Desperdício, economia da Início) calculados em `lib/data/relatorios.dart` a partir de `estoque.movimentos`.
   - Descarte sempre pergunta o motivo (`shared/widgets/discard_reason_sheet.dart`).
   - Receitas cruzam com o estoque em `lib/data/receitas.dart` (ingredientes com `termos` em `recipes_mock_data.dart`); favoritas em `estoque.favoritas`.
   - Testes: `SharedPreferences.setMockInitialValues({})` + `await estoque.load()` no `setUp`.
   - Não adicionar Riverpod/Drift/back-end sem pedido.

## Estrutura
```
lib/
  core/
    theme/         app_colors.dart, app_text_styles.dart, app_theme.dart
    constants/     app_assets.dart (AppIcons, AppImages)
    utils/         formatters.dart (formatBRL...)
  models/          modelos compartilhados (Product, Category, StorageSummary...)
  shared/widgets/  componentes reutilizáveis (AppTopBar, AppBottomNav, AppSvg, ProgressTrack, ExpiryPill, SectionHeader)
  features/
    shell/         MainShell (header + abas + bottom nav)
    <feature>/
      data/                mocks / repositórios
      presentation/        <feature>_page.dart
        widgets/           widgets específicos da tela
assets/icons/  SVGs do Figma (snake_case)
assets/images/ PNGs do Figma
```

## Regras
- **Cores**: só via `AppColors`. Nunca `Color(0x...)` dentro de telas/widgets. Cor nova → adicionar em `app_colors.dart`.
- **Texto**: só via `AppTextStyles` (+ `.copyWith`). Fonte: Plus Jakarta Sans (`google_fonts`).
- **Assets**: caminhos só via `AppIcons` / `AppImages`. Ícones SVG com `AppSvg`. Asset novo → baixar para `assets/`, registrar em `app_assets.dart`.
- **Reutilize** widgets de `shared/widgets` antes de criar novos. Se um widget aparece em 2+ telas, mova para `shared/widgets`.
- Um widget por arquivo; widgets privados (`_Nome`) podem ficar no mesmo arquivo.
- Layout com Row/Column/Flex (nada de posicionamento absoluto do Figma), textos longos com `maxLines` + `ellipsis`.
- Header e bottom nav ficam no `MainShell`; páginas usam `MediaQuery.paddingOf(context)` (já inclui as alturas deles).
- Largura de referência do design: 390px. Espaçamentos padrão: 16 lateral, 24 entre seções, 8 entre título e conteúdo; raios 8/12/16; pílulas 999.
- Rodar `flutter analyze` e `flutter test` antes de concluir uma tarefa.

## Figma
- MCP do Figma configurado em `.mcp.json`. Arquivo de design: `figma.com/design/2YLzQl2vKU1iFB967aQLWm`.
- Plano Starter = poucas chamadas/mês: pedir **um frame por vez** e não repetir leituras de telas já implementadas.
- Telas implementadas:
  - Início — node `12:689` → `features/home/presentation/home_page.dart`
  - Estoque — node `12:1057` → `features/stock/presentation/stock_page.dart` (filtros locais de busca/local/status)
  - Adicionar Item — node `12:496` → `features/add_product/presentation/add_product_page.dart`
    (rota empilhada pelo botão "+", usa `AppDetailTopBar`; ainda não persiste)
  - Histórico de Consumo — node `12:1821` → `features/consumption_history/presentation/consumption_history_page.dart`
    (rota empilhada ao tocar em "Economia inteligente do mês" na Início, usa `AppTitleTopBar`; período ainda não filtra)
  - Receitas Rápidas — node `12:2002` → `features/recipes/presentation/recipes_page.dart`
    (aba "Receitas" do MainShell; disponibilidade calculada com o estoque; "Ver Preparo" abre ingredientes + passos; "+ Lista" ainda é placeholder)
  - Detalhes do Item — node `12:332` → `features/product_detail/presentation/product_detail_page.dart`
    (rota empilhada ao tocar num card do Estoque, usa `AppDetailTopBar`; cores via `ExpiryPalette`; consumir/desperdiçar ainda não persiste)
  - Desperdício de Alimentos — node `12:1396` → `features/waste_report/presentation/waste_report_page.dart`
    (rota empilhada pela ação "Ver relatório" do aviso de "Registrar como Desperdiçado"; usa `AppTitleTopBar(outlined: true)`)
- Tons de item/categoria (fundo/borda/texto): `core/theme/category_tone.dart` (`CategoryTone`).
- `Product.freshness` = fração do ciclo de vida que já passou (0..1); `Product.units`/`unitPrice` para valor por unidade.
- Carrossel de pílulas de filtro: `shared/widgets/choice_pill_bar.dart` (`ChoicePillBar`, `dense` para a versão compacta).
- Telas internas: `AppDetailTopBar` (logo + título à esquerda) ou `AppTitleTopBar` (título centralizado + ação).
- Formulários: usar `shared/widgets/form_widgets.dart` (`FormFieldLabel`, `LabeledField`, `InputBox`, `bareInputDecoration`).
- App em pt-BR (`flutter_localizations`); datas com `formatDate` (dd/MM/aaaa).

## Domínio
- Validade: `Product.status` → `ExpiryStatus.today` (≤0 dias), `soon` (≤ `Product.soonThresholdDays` = 4), `ok`.
  Use sempre esse enum para cores/textos de validade; não repita limiares nas telas.

## Git
- Uma branch por tela/feature (`feat/tela-<nome>`), mensagens de commit em pt-BR.
