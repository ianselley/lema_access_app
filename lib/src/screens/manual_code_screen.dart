import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualCodeScreen extends StatefulWidget {
  const ManualCodeScreen({super.key, this.onSubmitCode, this.onOpenSearch});

  final VoidCallback? onSubmitCode;
  final VoidCallback? onOpenSearch;

  @override
  State<ManualCodeScreen> createState() => _ManualCodeScreenState();
}

class _ManualCodeScreenState extends State<ManualCodeScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _append(String value) {
    final nextValue = '${_codeController.text}$value';
    _codeController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
    setState(() {});
  }

  void _backspace() {
    final text = _codeController.text;
    if (text.isEmpty) {
      return;
    }

    final nextValue = text.substring(0, text.length - 1);
    _codeController.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
    setState(() {});
  }

  void _clear() {
    _codeController.clear();
    setState(() {});
  }

  void _submit() {
    widget.onSubmitCode?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasCode = _codeController.text.trim().isNotEmpty;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.vertical -
                42,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.keyboard_alt_outlined,
                      color: AppColors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Entrada manual',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Código del ticket', style: textTheme.titleLarge),
                      ],
                    ),
                  ),
                  LemaTag(
                    label: 'Operativo',
                    color: AppColors.surfaceHigh,
                    textColor: AppColors.primary,
                    icon: Icons.bolt,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              LemaPanel(
                color: AppColors.surfaceHighest,
                borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Introduce el código',
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Escribe o pega el código exacto del ticket para validar la entrada manualmente.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _codeController,
                      focusNode: _focusNode,
                      textCapitalization: TextCapitalization.characters,
                      keyboardType: TextInputType.text,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9\-]'),
                        ),
                        LengthLimitingTextInputFormatter(24),
                      ],
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 1.6,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Código',
                        hintText: 'LEMA-4831',
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _QuickActionChip(
                          label: 'Pegar ejemplo',
                          icon: Icons.content_paste,
                          onTap: () {
                            _codeController.text = 'LEMA-4831';
                            _codeController.selection = TextSelection.collapsed(
                              offset: _codeController.text.length,
                            );
                            setState(() {});
                          },
                        ),
                        _QuickActionChip(
                          label: 'Limpiar',
                          icon: Icons.clear_all,
                          onTap: _clear,
                        ),
                        _QuickActionChip(
                          label: 'Borrar',
                          icon: Icons.backspace_outlined,
                          onTap: _backspace,
                        ),
                        _QuickActionChip(
                          label: 'Pegar último',
                          icon: Icons.history,
                          onTap: () {
                            _codeController.text = 'LEMA-8932';
                            _codeController.selection = TextSelection.collapsed(
                              offset: _codeController.text.length,
                            );
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LemaPanel(
                color: AppColors.surfaceLow,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acceso rápido',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _DigitChip(label: '1', onTap: () => _append('1')),
                        _DigitChip(label: '2', onTap: () => _append('2')),
                        _DigitChip(label: '3', onTap: () => _append('3')),
                        _DigitChip(label: '4', onTap: () => _append('4')),
                        _DigitChip(label: '5', onTap: () => _append('5')),
                        _DigitChip(label: '6', onTap: () => _append('6')),
                        _DigitChip(label: '7', onTap: () => _append('7')),
                        _DigitChip(label: '8', onTap: () => _append('8')),
                        _DigitChip(label: '9', onTap: () => _append('9')),
                        _DigitChip(label: '0', onTap: () => _append('0')),
                        _DigitChip(label: '-', onTap: () => _append('-')),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LemaPrimaryButton(
                label: 'Validar código',
                icon: Icons.check_circle_outline,
                onPressed: hasCode ? _submit : null,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: widget.onOpenSearch,
                icon: const Icon(Icons.search),
                label: const Text('Buscar manualmente'),
              ),
              const SizedBox(height: 12),
              Text(
                'Si el código no coincide, usa la búsqueda manual para localizar el ticket.',
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(icon, size: 16, color: AppColors.primary),
      label: Text(label),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelMedium?.copyWith(color: AppColors.onSurface),
      backgroundColor: AppColors.surfaceHigh,
      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.18)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _DigitChip extends StatelessWidget {
  const _DigitChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      child: ActionChip(
        onPressed: onTap,
        label: Text(label),
        labelStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w800,
        ),
        backgroundColor: AppColors.surfaceHighest,
        side: BorderSide(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
