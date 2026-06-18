import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart' as auth;
import '../providers/profile_providers.dart' as profile;
import '../theme/app_theme.dart';
import '../widgets/join_with_code_sheet.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ProfileSessionScreen extends ConsumerWidget {
  const ProfileSessionScreen({super.key, this.onLogout});
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(profile.accessMeProvider);

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: meAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            _ProfileErrorView(error: error, onLogout: onLogout),
        data: (me) {
          final profile = me!;

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'PERFIL',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Sesión activa', style: textTheme.displayMedium),
                const SizedBox(height: 20),
                LemaPanel(
                  color: AppColors.surfaceHighest,
                  borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: textTheme.displayMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profile.email ?? 'Sin correo en la sesión',
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          LemaTag(
                            label: profile.roles.isEmpty
                                ? 'Sin rol'
                                : profile.roles.first,
                            color: AppColors.surfaceHigh,
                            textColor: AppColors.primary,
                          ),
                          LemaTag(
                            label: '${profile.accessibleEventCount} eventos',
                            color: AppColors.surfaceHigh,
                            textColor: AppColors.secondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const JoinWithCodePanel(),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(auth.accessAuthActionProvider.notifier)
                        .signOut();
                    if (!context.mounted) {
                      return;
                    }
                    onLogout?.call();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileErrorView extends StatelessWidget {
  const _ProfileErrorView({required this.error, this.onLogout});

  final Object error;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: LemaPanel(
          color: AppColors.surfaceHighest,
          borderColor: AppColors.error.withValues(alpha: 0.28),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('No se pudo cargar el perfil', style: textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                error.toString(),
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              if (onLogout != null) ...[
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: onLogout,
                  child: const Text('Volver al acceso'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
