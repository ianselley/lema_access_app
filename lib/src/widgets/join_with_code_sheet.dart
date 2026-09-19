import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event_models.dart';
import '../providers/membership_providers.dart';
import '../theme/app_theme.dart';
import 'lema_components.dart';

Future<void> showJoinWithCodeSheet(BuildContext context) async {
  final claimedResult =
      await showModalBottomSheet<AccessScannerInviteClaimResult>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: SafeArea(
              top: false,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  border: Border(
                    top: BorderSide(color: Color(0xFF2A2325), width: 1),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.onSurfaceMuted.withValues(
                              alpha: 0.32,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      JoinWithCodePanel(
                        autofocus: true,
                        onClaimed: (result) {
                          Navigator.of(sheetContext).pop(result);
                        },
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  if (!context.mounted || claimedResult == null) {
    return;
  }

  _showStatusNotification(
    context,
    scannerInviteClaimSuccessMessage(claimedResult),
  );
}

void _showStatusNotification(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.secondary,
        duration: const Duration(seconds: 4),
      ),
    );
}

class JoinWithCodePanel extends ConsumerStatefulWidget {
  const JoinWithCodePanel({super.key, this.autofocus = false, this.onClaimed});

  final bool autofocus;
  final ValueChanged<AccessScannerInviteClaimResult>? onClaimed;

  @override
  ConsumerState<JoinWithCodePanel> createState() => _JoinWithCodePanelState();
}

class _JoinWithCodePanelState extends ConsumerState<JoinWithCodePanel> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(accessScannerInviteClaimControllerProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final result = await ref
        .read(accessScannerInviteClaimControllerProvider.notifier)
        .claimCode(_codeController.text);

    if (!mounted) {
      return;
    }

    if (result == null) {
      _showStatusNotification(
        context,
        ref.read(accessScannerInviteClaimControllerProvider).message ??
            'No se pudo aplicar el código. Inténtalo de nuevo.',
        isError: true,
      );
      return;
    }

    if (widget.onClaimed == null) {
      _showStatusNotification(context, scannerInviteClaimSuccessMessage(result));
    }
    widget.onClaimed?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final claimState = ref.watch(accessScannerInviteClaimControllerProvider);
    final canSubmit =
        !claimState.isLoading &&
        normalizeScannerInviteCode(_codeController.text).length == 6;

    return LemaPanel(
      color: AppColors.surfaceLow,
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.16),
      padding: const EdgeInsets.all(18),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                LemaTag(
                  label: 'scanner',
                  color: AppColors.surfaceHigh,
                  textColor: AppColors.primary,
                  icon: Icons.vpn_key_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Unirse con código', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Introduce el código de invitación para activar tu acceso como scanner en una marca o en eventos.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _codeController,
              autofocus: widget.autofocus,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: const [_ScannerInviteCodeFormatter()],
              decoration: const InputDecoration(
                labelText: 'Código',
                hintText: 'Ejemplo: A1B-2C3',
              ),
              onChanged: (_) {
                if (claimState.status != AccessScannerInviteClaimStatus.idle) {
                  ref
                      .read(accessScannerInviteClaimControllerProvider.notifier)
                      .reset();
                }
                setState(() {});
              },
              onFieldSubmitted: (_) => _submit(),
              validator: (value) {
                final normalizedCode = normalizeScannerInviteCode(value ?? '');
                if (normalizedCode.length != 6) {
                  return 'Introduce un código válido de 6 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            LemaPrimaryButton(
              label: claimState.isLoading
                  ? 'Aplicando código...'
                  : 'Activar acceso',
              icon: claimState.isLoading
                  ? Icons.hourglass_top
                  : Icons.vpn_key_outlined,
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerInviteCodeFormatter extends TextInputFormatter {
  const _ScannerInviteCodeFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var normalized = normalizeScannerInviteCode(newValue.text);
    final removedSeparator =
        oldValue.text.endsWith('-') &&
        oldValue.text.length == newValue.text.length + 1 &&
        oldValue.text.substring(0, oldValue.text.length - 1) == newValue.text;

    if (removedSeparator && normalized.length == 3) {
      normalized = normalized.substring(0, 2);
    }

    final formatted = _formatInviteCode(normalized);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatInviteCode(String normalized) {
    if (normalized.length < 3) {
      return normalized;
    }

    return '${normalized.substring(0, 3)}-${normalized.substring(3)}';
  }
}

String scannerInviteClaimSuccessMessage(AccessScannerInviteClaimResult result) {
  if (result.isBrandMemberClaim) {
    return '¡Código aplicado! Ya eres scanner en esta marca.';
  }

  final eventCount = result.resolvedEventCount;
  if (eventCount == 1) {
    return 'Ya puedes operar 1 evento como scanner.';
  }

  return 'Ya puedes operar $eventCount eventos como scanner.';
}

String scannerInviteClaimDetailMessage(AccessScannerInviteClaimResult result) {
  if (result.isBrandMemberClaim) {
    return 'Tu acceso de marca quedó activado y se reflejará en tus eventos disponibles.';
  }

  final eventCount = result.resolvedEventCount;
  if (eventCount == 1) {
    return 'El evento asignado ya debería aparecer en tu lista.';
  }

  return 'Los $eventCount eventos asignados ya deberían aparecer en tu lista.';
}
