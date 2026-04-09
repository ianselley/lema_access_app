import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import './bootstrap_loading_screen.dart';
import './login_screen.dart';
import './operator_app.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';
import '../core/debug_log.dart';
import '../providers/auth_providers.dart';
import '../providers/bootstrap_providers.dart';

class AccessGateScreen extends ConsumerWidget {
  const AccessGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(authSessionProvider);

    return sessionAsync.when(
      loading: () => const BootstrapLoadingScreen(
        title: 'Verificando sesión',
        subtitle: 'Comprobando el estado de autenticación y preparando la app.',
      ),
      error: (error, stackTrace) => _BootstrapErrorView(error: error),
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
          error: (error, stackTrace) => _BootstrapErrorView(error: error),
          data: (bootstrap) {
            accessLog(
              'Gate bootstrap resolved: profileExists=${bootstrap?.flags.profileExists} accessibleEventCount=${bootstrap?.accessibleEventCount}',
              scope: 'gate',
            );
            return const OperatorApp();
          },
        );
      },
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: LemaPanel(
            color: AppColors.surfaceLow,
            borderColor: AppColors.error.withValues(alpha: 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Error de sesión', style: textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
