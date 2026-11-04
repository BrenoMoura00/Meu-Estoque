import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/fotos.dart';
import '../../../data/estoque_store.dart';
import '../../../models/product.dart';
import '../../../shared/widgets/app_detail_top_bar.dart';
import '../../../shared/widgets/app_svg.dart';
import '../../../shared/widgets/form_widgets.dart';
import '../data/add_product_options.dart';
import 'widgets/category_selector.dart';
import 'widgets/expiry_date_field.dart';
import 'widgets/notify_toggle_card.dart';
import 'widgets/photo_capture_card.dart';
import 'widgets/quantity_unit_row.dart';
import 'widgets/storage_selector.dart';

/// Tela "Adicionar Item" (Figma node 12:496), aberta pelo botão "+".
/// Valida nome e validade e salva no estoque local ([estoque]).
class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key, this.product});

  /// Quando informado, abre o formulário no modo de edição.
  final Product? product;

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _amountController = TextEditingController(text: '1');

  String _category = AddProductOptions.categories.first.label;
  DateTime? _expiry;
  bool _notify = true;
  int _quantity = 1;
  String _unit = AddProductOptions.units.first;
  StorageLocation _location = StorageLocation.geladeira;
  bool _showNameError = false;
  String? _photo;

  Future<void> _pickPhoto({required bool camera}) async {
    try {
      final path = await Fotos.escolher(camera: camera);
      if (path != null && mounted) setState(() => _photo = path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(camera ? 'Não foi possível abrir a câmera' : 'Não foi possível abrir a galeria')),
        );
    }
  }

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    if (product != null) {
      _nameController.text = product.name;
      _priceController.text = product.price.toStringAsFixed(2).replaceAll('.', ',');
      _category = product.category ?? AddProductOptions.categories.first.label;
      _expiry = DateUtils.dateOnly(DateTime.now()).add(Duration(days: product.daysToExpire));
      _unit = AddProductOptions.units.contains(product.measureUnit)
          ? product.measureUnit!
          : AddProductOptions.units.first;
      final amount = product.amount ?? product.units.toDouble();
      _quantity = (_unit == 'Unidade(s)' || _unit == 'Pacote(s)') ? amount.round() : 1;
      _amountController.text = amount.toString().replaceAll('.', ',');
      _location = product.location;
      _photo = product.imagePath == AppImages.logo ? null : product.imagePath;
    }
    _nameController.addListener(() => setState(() {
          if (_nameController.text.trim().isNotEmpty) _showNameError = false;
        }));
    _amountController.addListener(_refreshTotal);
  }

  void _refreshTotal() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) {
      setState(() => _showNameError = true);
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    if (_expiry == null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Informe a data de validade')));
      return;
    }
    final isUnit = _unit == 'Unidade(s)' || _unit == 'Pacote(s)';
    final perPackage = double.tryParse(_amountController.text.replaceAll(',', '.'));
    final amount = isUnit ? _quantity.toDouble() : (perPackage == null ? null : perPackage * _quantity);
    if (amount == null || !amount.isFinite || amount <= 0) {
      messenger.showSnackBar(const SnackBar(content: Text('Informe uma quantidade maior que zero')));
      return;
    }
    final price = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    if (widget.product?.id case final String id) {
      final ok = estoque.editar(
        id: id,
        name: _nameController.text.trim(),
        amount: amount,
        measureUnit: _unit,
        location: _location,
        venceEm: _expiry!,
        price: price,
        category: _category,
        imagePath: _photo,
      );
      if (!ok) {
        messenger.showSnackBar(const SnackBar(content: Text('Não foi possível atualizar o produto')));
        return;
      }
      Navigator.of(context).pop();
      messenger.showSnackBar(const SnackBar(duration: Duration(seconds: 4), content: Text('Produto atualizado')));
      return;
    }
    estoque.adicionar(
      name: _nameController.text.trim(),
      quantity: '${amount == amount.roundToDouble() ? amount.toInt() : amount} $_unit',
      units: isUnit ? _quantity : 1,
      amount: amount,
      measureUnit: _unit,
      location: _location,
      venceEm: _expiry!,
      price: price,
      category: _category,
      imagePath: _photo ?? AppImages.logo,
    );
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('"${_nameController.text.trim()}" salvo no estoque'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceInverse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppDetailTopBar(title: widget.product == null ? 'Adicionar Item' : 'Editar Item'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, padding.top, 16, 24),
          children: [
            PhotoCaptureCard(
              photoPath: _photo,
              onTakePhoto: () => _pickPhoto(camera: true),
              onPickFromGallery: () => _pickPhoto(camera: false),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: FormFieldLabel(
                'Nome do Produto',
                trailing: '*Obrigatório',
                trailingStyle: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
              child: _nameField(),
            ),
            if (_showNameError)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('Informe o nome do produto',
                    style: AppTextStyles.caption.copyWith(color: AppColors.error, fontWeight: FontWeight.w500)),
              ),
            const SizedBox(height: 16),
            LabeledField(
              label: const FormFieldLabel('Categoria'),
              child: CategorySelector(
                categories: AddProductOptions.categories,
                selected: _category,
                onChanged: (c) => setState(() => _category = c),
              ),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: const FormFieldLabel('Data de Validade'),
              child: ExpiryDateField(value: _expiry, onChanged: (d) => setState(() => _expiry = d)),
            ),
            const SizedBox(height: 16),
            NotifyToggleCard(
              value: _notify,
              daysBefore: AddProductOptions.notifyDaysBefore,
              onChanged: (v) => setState(() => _notify = v),
            ),
            const SizedBox(height: 16),
            QuantityUnitRow(
              quantity: _quantity,
              onQuantityChanged: (q) => setState(() => _quantity = q),
              unit: _unit,
              units: AddProductOptions.units,
              onUnitChanged: (u) => setState(() => _unit = u),
            ),
            if (_unit != 'Unidade(s)' && _unit != 'Pacote(s)') ...[
              const SizedBox(height: 8),
              LabeledField(
                label: FormFieldLabel('Medida por embalagem em $_unit (aceita decimais)'),
                child: InputBox(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: bareInputDecoration(hint: 'Ex.: 1,5'),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Builder(builder: (context) {
                final medida = double.tryParse(_amountController.text.replaceAll(',', '.'));
                if (medida == null || !medida.isFinite || medida <= 0) return const SizedBox.shrink();
                final total = medida * _quantity;
                final texto = total == total.roundToDouble()
                    ? total.toInt().toString()
                    : total.toStringAsFixed(3).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '').replaceAll('.', ',');
                return Text('Total no estoque: $texto $_unit', style: AppTextStyles.caption);
              }),
            ],
            const SizedBox(height: 16),
            LabeledField(
              label: const FormFieldLabel('Local de Armazenamento'),
              child: StorageSelector(selected: _location, onChanged: (l) => setState(() => _location = l)),
            ),
            const SizedBox(height: 16),
            LabeledField(
              label: const FormFieldLabel('Preço Pago (Opcional)', trailing: 'Ajuda no controle de desperdício'),
              child: _priceField(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _SaveBar(onSave: _save),
    );
  }

  Widget _nameField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: _showNameError ? Border.all(color: AppColors.error) : null,
      ),
      child: InputBox(
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: inputTextStyle.copyWith(color: AppColors.onSurface),
                cursorColor: AppColors.primary,
                decoration: bareInputDecoration(hint: 'Ex.: Tomate Italiano'),
              ),
            ),
            if (_nameController.text.isNotEmpty)
              IconButton(
                tooltip: 'Limpar texto',
                onPressed: _nameController.clear,
                icon: const AppSvg(AppIcons.clear, width: 15, height: 15),
              ),
          ],
        ),
      ),
    );
  }

  Widget _priceField() {
    return InputBox(
      child: Row(
        children: [
          Text('R\$', style: AppTextStyles.title.copyWith(color: AppColors.outline)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              style: inputTextStyle.copyWith(color: AppColors.onSurface),
              cursorColor: AppColors.primary,
              decoration: bareInputDecoration(hint: '0,00', hintColor: AppColors.placeholder),
            ),
          ),
        ],
      ),
    );
  }
}

/// Área fixa inferior com o botão "Salvar no Estoque".
class _SaveBar extends StatelessWidget {
  const _SaveBar({required this.onSave});
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          color: AppColors.background.withValues(alpha: 0.9),
          padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  spreadRadius: -3,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onSave,
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppSvg(AppIcons.saveCheck, width: 16.7, height: 16.7, color: Colors.white),
                      const SizedBox(width: 4),
                      Text('Salvar no Estoque', style: AppTextStyles.subtitle.copyWith(color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
