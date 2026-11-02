import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// Sombra padrão de campos e cards de formulário.
final formShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))];

/// Rótulo de campo com texto auxiliar opcional à direita.
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel(this.text, {super.key, this.trailing, this.trailingStyle});

  final String text;
  final String? trailing;
  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context) {
    final label = Text(text, style: AppTextStyles.label.copyWith(color: AppColors.onSurfaceVariant));
    if (trailing == null) return label;

    return Row(
      children: [
        label,
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            trailing!,
            style: trailingStyle ?? AppTextStyles.body.copyWith(color: AppColors.outline),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Rótulo + campo, com 4px entre eles.
class LabeledField extends StatelessWidget {
  const LabeledField({super.key, required this.label, required this.child});

  final Widget label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [label, const SizedBox(height: 4), child],
      );
}

/// Caixa branca arredondada (48px) usada como fundo de campos.
class InputBox extends StatelessWidget {
  const InputBox({super.key, required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        height: 48,
        padding: padding,
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: formShadow,
        ),
        child: child,
      );
}

/// Estilo do texto digitado em campos.
TextStyle get inputTextStyle => AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w400, letterSpacing: 0);

/// InputDecoration sem bordas, para usar dentro de [InputBox].
InputDecoration bareInputDecoration({String? hint, Color? hintColor}) => InputDecoration(
      border: InputBorder.none,
      isCollapsed: true,
      hintText: hint,
      hintStyle: inputTextStyle.copyWith(color: hintColor ?? AppColors.outline.withValues(alpha: 0.7)),
    );
