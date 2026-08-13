import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './bootstrap_loading_screen.dart';
import './login_screen.dart';
import './operator_app.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import '../core/failure.dart';
import '../core/debug_log.dart';
import '../providers/auth_providers.dart';
import '../providers/bootstrap_providers.dart';
import '../providers/membership_providers.dart';
import '../services/deep_link_service.dart';

class AccessGateScreen extends ConsumerStatefulWidget {
  const AccessGateScreen({super.key, this.deepLinks});

  final AccessDeepLinkService? deepLinks;

  @override
  ConsumerState<AccessGateScreen> createState() => _AccessGateScreenState();
}

class _AccessGateScreenState extends ConsumerState<AccessGateScreen> {
  String? _claimedCode;

  void _claimPendingInvite() {
    final deepLinks = widget.deepLinks;
    final code = deepLinks?.pendingScannerInviteCode;
    if (code == null || code == _claimedCode) {
      return;
    }

    _claimedCode = code;
    Future<void>(() async {
      final result = await ref
          .read(accessScannerInviteClaimControllerProvider.notifier)
          .claimCode(code);
      if (result == null || !mounted) {
        return;
      }

      await deepLinks!.clearPendingScannerInviteCode();
      ref.invalidate(accessBootstrapProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(authSessionProvider);

    return sessionAsync.when(
      loading: () => const BootstrapLoadingScreen(
        title: 'Verificando sesión',
        subtitle: 'Comprobando el estado de autenticación y preparando la app.',
      ),
      error: (error, stackTrace) => _BootstrapErrorView(
        error: error,
        onRetry: () => ref.invalidate(authSessionProvider),
      ),
      data: (session) {
        accessLog(
          'Gate session resolved: session=${session?.user.id}',
          scope: 'gate',
        );
        if (session == null) {
          return const LoginScreen();
        }

        final bootstrapAsync = ref.watch(accessBootstrapProvider);
        return bootstrapAsync.when(
          loading: () => const BootstrapLoadingScreen(
            title: 'Cargando acceso',
            subtitle: 'Consultando el bootstrap real del backend.',
          ),
          error: (error, stackTrace) => _BootstrapErrorView(
            error: error,
            onRetry: () => ref.invalidate(accessBootstrapProvider),
          ),
          data: (bootstrap) {
            accessLog(
              'Gate bootstrap resolved: profileExists=${bootstrap?.flags.profileExists} accessibleEventCount=${bootstrap?.accessibleEventCount}',
              scope: 'gate',
            );
            if (bootstrap != null && bootstrap.profileExists == false) {
              return LoginScreen(
                initialStep: AccessAuthStep.completion,
                initialEmail: bootstrap.email ?? session.user.email,
              );
            }

            _claimPendingInvite();

            return const OperatorApp();
          },
        );
      },
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  String _resolveMessage() {
    if (error case AccessFailure(:final message)) {
      return message;
    }

    return error.toString();
  }

  String _resolveTitle() {
    if (error case AccessFailure(kind: AccessFailureKind.network)) {
      return 'No se pudo recuperar la sesión';
    }

    return 'Error de sesión';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.sync_problem_rounded,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 18),
              Text(_resolveTitle(), style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                _resolveMessage(),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              LemaPrimaryButton(
                label: 'Reiniciar',
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
