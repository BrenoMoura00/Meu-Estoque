import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografia do app (Plus Jakarta Sans), espelhando os estilos do Figma.
/// Use `.copyWith(color: ...)` para variar cor; não crie TextStyle solto nas telas.
abstract final class AppTextStyles {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    required double lineHeight,
    double letterSpacing = 0,
    Color color = AppColors.onSurface,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        height: lineHeight / size,
        letterSpacing: letterSpacing,
        color: color,
      );

  /// 32 bold — números de destaque (ex.: "3 itens")
  static final display = _base(size: 32, weight: FontWeight.w700, lineHeight: 32, letterSpacing: -0.64);

  /// 20 semibold — números dos cards de resumo
  static final number = _base(size: 20, weight: FontWeight.w600, lineHeight: 25, letterSpacing: -0.2);

  /// 17 semibold — títulos de seção e nome de produto
  static final title = _base(size: 17, weight: FontWeight.w600, lineHeight: 24);

  /// 14 bold — destaques curtos
  static final bodyStrong = _base(size: 14, weight: FontWeight.w700, lineHeight: 20, letterSpacing: 0.14);

  /// 14 semibold — subtítulos
  static final subtitle = _base(size: 14, weight: FontWeight.w600, lineHeight: 20, letterSpacing: 0.14);

  /// 12 semibold — botões, labels, links
  static final label = _base(size: 12, weight: FontWeight.w600, lineHeight: 16, letterSpacing: 0.24);

  /// 12 medium
  static final bodyMedium = _base(
      size: 12, weight: FontWeight.w500, lineHeight: 18, color: AppColors.onSurfaceVariant);

  /// 12 regular — textos de apoio
  static final body = _base(
      size: 12, weight: FontWeight.w400, lineHeight: 18, color: AppColors.onSurfaceVariant);

  /// 11 bold — overlines, badges
  static final caption = _base(size: 11, weight: FontWeight.w700, lineHeight: 14, letterSpacing: 0.33);

  /// 11 semibold — pílulas de status
  static final captionMedium = _base(size: 11, weight: FontWeight.w600, lineHeight: 14, letterSpacing: 0.33);

  /// 11 regular — tags de local
  static final tag = _base(
      size: 11, weight: FontWeight.w400, lineHeight: 16, color: AppColors.onSurfaceVariant);

  /// 10 regular — micro textos
  static final micro = _base(
      size: 10, weight: FontWeight.w400, lineHeight: 14, color: AppColors.onSurfaceVariant);
}
