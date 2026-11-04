import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/waste_report/data/waste_mock_data.dart';

/// Pergunta o motivo do descarte. Retorna null se o usuário cancelar.
Future<WasteReason?> escolherMotivoDescarte(BuildContext context, String nomeItem) {
  return showModalBottomSheet<WasteReason>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Por que descartar?', style: AppTextStyles.title),
            const SizedBox(height: 4),
            Text(nomeItem, style: AppTextStyles.body, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            for (final r in WasteReason.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: r.color, shape: BoxShape.circle),
                ),
                title: Text(r.label, style: AppTextStyles.subtitle),
                subtitle: Text(_descricao(r), style: AppTextStyles.body),
                onTap: () => Navigator.of(context).pop(r),
              ),
          ],
        ),
      ),
    ),
  );
}

String _descricao(WasteReason r) => switch (r) {
  WasteReason.vencimento => 'Passou da data de validade',
  WasteReason.sobras => 'Sobrou e não foi aproveitado',
  WasteReason.deteriorado => 'Estragou ou mofou antes de vencer',
};
