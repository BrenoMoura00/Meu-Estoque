import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Ícone SVG do Figma. Mantém o tamanho nativo do asset por padrão;
/// passe [color] apenas quando o design pedir outra cor.
class AppSvg extends StatelessWidget {
  const AppSvg(this.asset, {super.key, this.width, this.height, this.color});

  final String asset;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
        asset,
        width: width,
        height: height,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      );
}
