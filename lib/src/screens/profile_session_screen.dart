import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../access/bootstrap/access_bootstrap_providers.dart' as bootstrap;
import '../access/profile/access_profile_providers.dart' as profile;
import '../access/providers/access_providers.dart' as access;
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ProfileSessionScreen extends ConsumerWidget {
  const ProfileSessionScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(profile.accessMeProvider);
    final bootstrapAsync = ref.watch(bootstrap.accessBootstrapProvider);

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
                LemaPanel(
                  color: AppColors.surfaceLow,
                  padding: const EdgeInsets.all(18),
                  child: bootstrapAsync.when(
                    loading: () => const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                    error: (error, stackTrace) => Text(
                      error.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    data: (bootstrapData) {
                      if (bootstrapData == null ||
                          bootstrapData.eventsPreview.isEmpty) {
                        return Text(
                          'Sin evento sugerido.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        );
                      }

                      final suggestedEvent = bootstrapData.eventsPreview
                          .firstWhere(
                            (event) =>
                                event.id == bootstrapData.suggestedEventId,
                            orElse: () => bootstrapData.eventsPreview.first,
                          );

                      return _InfoRow(
                        label: 'Evento sugerido',
                        value: suggestedEvent.name,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref
                        .read(access.accessAuthActionProvider.notifier)
                        .signOut();
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
