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

  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) {
    return;
  }

  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(content: Text(scannerInviteClaimSuccessMessage(claimedResult))),
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

    if (result == null) {
      return;
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
                const Spacer(),
                Icon(
                  Icons.qr_code_2_rounded,
                  color: AppColors.primary.withValues(alpha: 0.9),
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
                hintText: 'Ejemplo: A1B2C3',
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
            if (claimState.status ==
                AccessScannerInviteClaimStatus.failure) ...[
              const SizedBox(height: 12),
              _ClaimStatusBanner(
                message:
                    claimState.message ??
                    'No se pudo aplicar el código. Inténtalo de nuevo.',
                accent: AppColors.error,
                backgroundOpacity: 0.08,
                borderOpacity: 0.24,
                icon: Icons.error_outline,
              ),
            ],
            if (claimState.status == AccessScannerInviteClaimStatus.success &&
                claimState.result != null) ...[
              const SizedBox(height: 12),
              _ClaimStatusBanner(
                message: scannerInviteClaimSuccessMessage(claimState.result!),
                accent: AppColors.secondary,
                backgroundOpacity: 0.10,
                borderOpacity: 0.22,
                icon: Icons.verified_user_outlined,
                detail: scannerInviteClaimDetailMessage(claimState.result!),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'El acceso se asigna en cuanto el código sea válido y esté disponible.',
              style: textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimStatusBanner extends StatelessWidget {
  const _ClaimStatusBanner({
    required this.message,
    required this.accent,
    required this.backgroundOpacity,
    required this.borderOpacity,
    required this.icon,
    this.detail,
  });

  final String message;
  final String? detail;
  final Color accent;
  final double backgroundOpacity;
  final double borderOpacity;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: accent.withValues(alpha: backgroundOpacity),
      borderColor: accent.withValues(alpha: borderOpacity),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: textTheme.bodyMedium?.copyWith(color: accent),
                ),
                if (detail != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    detail!,
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
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
    final normalized = normalizeScannerInviteCode(newValue.text);
    return TextEditingValue(
      text: normalized,
      selection: TextSelection.collapsed(offset: normalized.length),
    );
  }
}

String scannerInviteClaimSuccessMessage(AccessScannerInviteClaimResult result) {
  if (result.isBrandMemberClaim) {
    return 'Ya formas parte de la marca como scanner.';
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
