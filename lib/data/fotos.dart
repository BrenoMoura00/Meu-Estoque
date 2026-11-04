import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Fotos de produtos tiradas/escolhidas no app.
///
/// No celular, a foto é copiada para `<documentos>/fotos/` e o item guarda só o caminho
/// **relativo** (`fotos/<id>.jpg`): o caminho absoluto muda entre atualizações no iOS.
/// Na web, guarda o próprio endereço devolvido pelo navegador (vale enquanto a aba estiver aberta).
abstract final class Fotos {
  static const _pasta = 'fotos';
  static String? _base;
  static final _picker = ImagePicker();

  /// Chamar uma vez no início do app.
  static Future<void> init() async {
    if (kIsWeb) return;
    try {
      _base = (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      _base = null; // ex.: testes sem plugin; fotos ficam indisponíveis
    }
  }

  /// Abre a câmera ou a galeria. Retorna o caminho a salvar no item, ou null se cancelado.
  static Future<String?> escolher({required bool camera}) async {
    final foto = await _picker.pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 75,
    );
    if (foto == null) return null;
    if (kIsWeb || _base == null) return foto.path;
    await Directory('$_base/$_pasta').create(recursive: true);
    final relativo = '$_pasta/${DateTime.now().microsecondsSinceEpoch}.jpg';
    await File(foto.path).copy('$_base/$relativo');
    return relativo;
  }

  /// O caminho é de uma foto do usuário (e não um asset do app)?
  static bool ehFoto(String path) => path.startsWith('$_pasta/') || path.startsWith('blob:') || path.startsWith('http');

  /// Arquivo local da foto (null na web ou se indisponível).
  static File? arquivo(String path) =>
      kIsWeb || _base == null || !path.startsWith('$_pasta/') ? null : File('$_base/$path');
}
