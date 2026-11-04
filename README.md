# 🥫 Meu Estoque

App Flutter para controlar os alimentos de casa: validade, locais de armazenamento, consumo, desperdício e receitas
que aproveitam o que está perto de vencer.

> **Versão de apresentação:** tudo roda **localmente** no aparelho (sem servidor, sem internet, sem login).
> Os dados ficam salvos no próprio celular/navegador.

---

## 1. Pré-requisitos

| Ferramenta | Versão | Para quê |
|---|---|---|
| [Flutter SDK](https://docs.flutter.dev/get-started/install) | **3.47** ou mais recente (Dart 3.13+) | obrigatório |
| [Git](https://git-scm.com/downloads) | qualquer | baixar o projeto |
| [Android Studio](https://developer.android.com/studio) | recente | emulador Android e SDK do Android |
| Xcode (só no Mac) | 16+ | rodar no iPhone / simulador iOS |
| Google Chrome | qualquer | rodar a versão web (opcional) |

Editor recomendado: **VS Code** com a extensão *Flutter* (ou o próprio Android Studio com o plugin Flutter).

### Conferir a instalação
```bash
flutter --version
flutter doctor
```
O `flutter doctor` precisa mostrar ✓ pelo menos em **Flutter** e em **Android toolchain** (ou **Chrome**, se for rodar na web).
Se aparecer pendência de licenças do Android, rode `flutter doctor --android-licenses` e aceite tudo.

---

## 2. Baixar o projeto
```bash
git clone https://github.com/BrenoMoura00/Meu-Estoque.git
cd Meu-Estoque
flutter pub get
```

---

## 3. Rodar

### 3.1 Escolher onde rodar
Liste os dispositivos disponíveis:
```bash
flutter devices
```

- **Celular Android físico** (recomendado): ative *Opções do desenvolvedor* → *Depuração USB*, conecte no USB e aceite o aviso no celular.
- **Emulador Android**: Android Studio → *Device Manager* → *Create device* → escolha um Pixel → dê ▶ para ligar.
- **iPhone / simulador iOS** (só no Mac): `open -a Simulator`, ou conecte o iPhone e confie no computador.
- **Navegador**: Chrome instalado já aparece como `chrome`.

### 3.2 Iniciar o app
```bash
flutter run                 # usa o único dispositivo conectado (ou pergunta qual)
flutter run -d chrome       # navegador
flutter run -d <id>         # um dispositivo específico, id vindo do `flutter devices`
```
Com o app rodando, no terminal: **`r`** recarrega (hot reload), **`R`** reinicia, **`q`** sai.

> A primeira execução demora alguns minutos (o Gradle baixa dependências). As próximas são rápidas.

---

## 4. Dados de exemplo
Na **primeira vez** que o app abre, ele cria automaticamente:
- 13 itens no estoque (alguns vencendo hoje, outros em breve e no prazo);
- um histórico de consumo e de descartes deste mês e do mês anterior.

As datas são relativas ao dia em que o app foi aberto pela primeira vez.

**Para voltar aos dados de exemplo** (ex.: no dia da apresentação):
- **Android**: Configurações → Apps → Meu Estoque → Armazenamento → **Limpar dados**.
- **iPhone**: apague o app e instale de novo (`flutter run`).
- **Chrome**: DevTools (F12) → *Application* → *Local Storage* → limpar → recarregar a página.

---

## 5. O que dá para testar

| Tela | O que funciona |
|---|---|
| **Estoque** | Busca, filtros por local e validade, consumir/descartar (com **Desfazer**), abrir detalhes |
| **Adicionar Item** (botão +) | Cadastro completo, foto pela **câmera** ou **galeria**, validação de nome e validade |
| **Detalhes do Item** | Status da validade, valor, unidades (− / +), consumir, registrar desperdício |
| **Início** | Itens que vencem hoje, valor em risco, resumo por local, últimos cadastrados, economia do mês |
| **Histórico de Consumo** | Ranking por item e por categoria, filtro de período, aproveitamento, dica de economia |
| **Desperdício** | Prejuízo do mês, comparação com o mês anterior, peso, motivos, itens descartados |
| **Receitas** | Cruza os ingredientes com o estoque (tem / falta), prioriza o que vence antes, modo de preparo, favoritos |

**Ainda não funciona:** aba Compras e "+ Lista", busca do topo, sino, perfil, editar, compartilhar e notificações.

### Observações por plataforma
- **Emulador Android**: a câmera é simulada; a galeria funciona normalmente.
- **iPhone**: na primeira foto, o app pede permissão de câmera/fotos.
- **Chrome**: tudo funciona, mas fotos somem ao recarregar a página (no celular ficam salvas).

---

## 6. Testes automatizados
```bash
flutter analyze   # verificação de código (deve mostrar "No issues found!")
flutter test      # testes automatizados
```

---

## 7. Estrutura do código
```
lib/
  main.dart                 inicialização (carrega o estoque local e as fotos)
  core/                     tema (cores, textos), assets e formatadores
  data/
    estoque_store.dart      estado central do app + persistência local (shared_preferences)
    relatorios.dart         cálculos do Histórico, Desperdício e economia
    receitas.dart           cruzamento das receitas com o estoque
    fotos.dart              câmera/galeria e armazenamento das fotos
  models/                   modelos compartilhados (Product...)
  shared/widgets/           componentes reutilizáveis
  features/<tela>/          cada tela: data/ (dados de exemplo) e presentation/ (tela e widgets)
assets/icons, assets/images ícones e imagens do design (Figma)
```

---

## 8. Problemas comuns

| Problema | Solução |
|---|---|
| `flutter: command not found` | Adicione a pasta `flutter/bin` ao PATH e abra um terminal novo |
| `No devices found` | Ligue o emulador ou conecte o celular com depuração USB ativa; confira com `flutter devices` |
| Erro de licenças do Android | `flutter doctor --android-licenses` |
| Erro estranho de build depois de atualizar o projeto | `flutter clean` e depois `flutter pub get` |
| Câmera não abre no emulador | Normal em alguns emuladores; use a **Galeria** ou um celular físico |
| Números "estranhos" nos relatórios | Os dados de exemplo usam a data da 1ª abertura; limpe os dados do app (seção 4) |

Encontrou um bug? Mande **print + o passo a passo** do que fez antes de acontecer.
