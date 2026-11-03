import 'package:flutter/material.dart';

/// Paleta do app, extraída do Figma. Nunca use cores hardcoded nas telas:
/// adicione aqui e referencie por `AppColors.x`.
abstract final class AppColors {
  // Marca
  static const primary = Color(0xFF006948);
  static const primaryLight = Color(0xFF00855D);
  static const mint = Color(0xFF85F8C4);
  static const mintOverlay = Color(0x4D68DBA9); // rgba(104,219,169,0.3)
  static const onMintVariant = Color(0xFF005137);
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

  // Histórico de consumo (tons neutros "slate" e verdes "emerald" do Figma)
  static const ink = Color(0xFF0F172A);
  static const slate700 = Color(0xFF334155);
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);
  static const emerald950 = Color(0xFF022C22);
  static const emerald900 = Color(0xFF064E3B);
  static const emerald700 = Color(0xFF047857);
  static const emerald600 = Color(0xFF059669);
  static const emerald500 = Color(0xFF10B981);
  static const emerald400 = Color(0xFF34D399);
  static const emerald200 = Color(0xFFA7F3D0);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald50 = Color(0xFFECFDF5);

  // Tons de categoria (fundo / borda / texto)
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue700 = Color(0xFF1D4ED8);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber800 = Color(0xFF92400E);
  static const orange50 = Color(0xFFFFF7ED);
  static const orange100 = Color(0xFFFFEDD5);
  static const orange700 = Color(0xFFC2410C);
  static const yellow50 = Color(0xFFFEFCE8);
  static const yellow100 = Color(0xFFFEF9C3);
  static const yellow800 = Color(0xFF854D0E);
  static const rose50 = Color(0xFFFFF1F2);
  static const rose100 = Color(0xFFFFE4E6);
  static const rose700 = Color(0xFFBE123C);
  static const rose200 = Color(0xFFFECDD3);
  static const rose500 = Color(0xFFF43F5E);
  static const rose600 = Color(0xFFE11D48);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber700 = Color(0xFFB45309);
  static const amber900 = Color(0xFF78350F);
  static const emerald300 = Color(0xFF6EE7B7);
  static const teal800 = Color(0xFF115E59);
}
