import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../models/product.dart';

/// Cores e textos da tela de detalhes conforme a situação de validade.
class ExpiryPalette {
  const ExpiryPalette._({
    required this.accent,
    required this.container,
    required this.onContainer,
    required this.pillLabel,
    required this.priority,
    required this.priorityColor,
  });

  factory ExpiryPalette.of(Product product) => switch (product.status) {
    ExpiryStatus.today => const ExpiryPalette._(
      accent: AppColors.errorBright,
      container: AppColors.errorContainer,
      onContainer: AppColors.onErrorContainer,
      pillLabel: 'Vence hoje',
      priority: 'Prioridade máxima',
      priorityColor: AppColors.error,
    ),
    ExpiryStatus.soon => ExpiryPalette._(
      accent: AppColors.warning,
      container: AppColors.warningContainer.withValues(alpha: 0.3),
      onContainer: AppColors.onWarning,
      pillLabel: product.daysToExpire == 1 ? 'Vence amanhã' : 'Vence em breve',
      priority: 'Prioridade alta',
      priorityColor: AppColors.warningText,
    ),
    ExpiryStatus.ok => ExpiryPalette._(
      accent: AppColors.primary,
      container: AppColors.mint.withValues(alpha: 0.25),
      onContainer: AppColors.onMint,
      pillLabel: 'No prazo',
      priority: 'Sem urgência',
      priorityColor: AppColors.primary,
    ),
  };

  /// Cor forte (ícone, barra, pílula).
  final Color accent;

  /// Fundo do card de status.
  final Color container;

  /// Texto sobre o card de status.
  final Color onContainer;
  final String pillLabel;
  final String priority;
  final Color priorityColor;
}
