import 'package:flutter/material.dart';

/// Paleta do app, extraída do Figma. Nunca use cores hardcoded nas telas:
/// adicione aqui e referencie por `AppColors.x`.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFF006948);
  static const primaryLight = Color(0xFF00855D);
  static const mint = Color(0xFF85F8C4);
  static const mintOverlay = Color(0x4D68DBA9); // rgba(104,219,169,0.3)
  static const onMint = Color(0xFF002114);

  // Superfícies
  static const background = Color(0xFFFAF8FF);
  static const surface = Colors.white;
  static const surfaceLow = Color(0xFFF2F3FF);
  static const surfaceContainer = Color(0xFFEAEDFF);
  static const surfaceHigh = Color(0xFFE2E7FF);
  static const surfaceHighOverlay = Color(0x66E2E7FF); // rgba(226,231,255,0.4)
  static const surfaceInverse = Color(0xF2283044); // rgba(40,48,68,0.95)
  static const onSurfaceInverseVariant = Color(0xFFBCCAC0);
  static const outline = Color(0xFF6D7A72);
  static const placeholder = Color(0xFF9CA3AF);
  static const track = Color(0xFFDAE2FD);

  // Texto
  static const onSurface = Color(0xFF131B2E);
  static const onSurfaceVariant = Color(0xFF3D4A42);

  // Erro / vencimento
  static const error = Color(0xFFB61722);
  static const onErrorContainer = Color(0xFF930013);
  static const errorContainer = Color(0x66FFDAD7); // rgba(255,218,215,0.4)
  static const errorContainerSolid = Color(0xFFFFDAD7);
  static const errorBright = Color(0xFFDA3437); // status "Vence hoje"

  // Alerta / atenção
  static const warning = Color(0xFFFEA619);
  static const warningContainer = Color(0xFFFFDDB8);
  static const warningContainerOverlay = Color(0x66FFDDB8);
  static const onWarningContainer = Color(0xFF2A1700);
  static const onWarning = Color(0xFF684000);
  static const warningText = Color(0xFF855300);

  // Sombras
  static const shadow = Color(0xFF131B2E);
}
