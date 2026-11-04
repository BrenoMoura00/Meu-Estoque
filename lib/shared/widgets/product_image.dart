import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../data/fotos.dart';

/// Imagem de produto: foto tirada pelo usuário ([Fotos]) ou asset do app.
/// Se a foto não puder ser carregada, mostra o logo.
class ProductImage extends StatelessWidget {
  const ProductImage(this.path, {super.key, this.fit = BoxFit.cover, this.width, this.height});

  final String path;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext _, Object _, StackTrace? _) =>
        Image.asset(AppImages.logo, fit: BoxFit.contain, width: width, height: height);

    if (!Fotos.ehFoto(path)) return Image.asset(path, fit: fit, width: width, height: height, errorBuilder: fallback);
    final file = Fotos.arquivo(path);
    if (file != null) return Image.file(file, fit: fit, width: width, height: height, errorBuilder: fallback);
    return Image.network(path, fit: fit, width: width, height: height, errorBuilder: fallback);
  }
}
