import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ProfileSessionScreen extends StatelessWidget {
  const ProfileSessionScreen({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_outline,
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
                        'Configuración',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Perfil / sesión', style: textTheme.titleLarge),
                    ],
                  ),
                ),
                const LemaStatusPill(
                  label: 'Operador activo',
                  color: AppColors.success,
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
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 74,
                        height: 74,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundAlt,
                          border: Border.all(
                            color: AppColors.primaryStrong,
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'staff.madrid@lema.io',
                              style: textTheme.displayMedium?.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Operador de acceso · Turno noche',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                LemaTag(
                                  label: 'Sesión segura',
                                  color: AppColors.surfaceHigh,
                                  textColor: AppColors.primary,
                                  icon: Icons.lock_outline,
                                ),
                                LemaTag(
                                  label: 'Madrid',
                                  color: AppColors.surfaceHigh,
                                  textColor: AppColors.secondary,
                                  icon: Icons.location_on_outlined,
                                ),
                              ],
                            ),
                          ],
                        ),
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
                    'Permisos y estado',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _StatusRow(
                    icon: Icons.camera_alt_outlined,
                    label: 'Cámara',
                    value: 'Concedido',
                    color: AppColors.success,
                  ),
                  const SizedBox(height: 12),
                  _StatusRow(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notificaciones',
                    value: 'Activas',
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 12),
                  _StatusRow(
                    icon: Icons.wifi_tethering_off_outlined,
                    label: 'Modo offline',
                    value: 'Preparado',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 12),
                  _StatusRow(
                    icon: Icons.shield_outlined,
                    label: 'Bloqueo de sesión',
                    value: 'Sin incidencias',
                    color: AppColors.onSurfaceMuted,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surface,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la app',
                    style: textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DetailRow(
                    icon: Icons.phone_iphone_outlined,
                    label: 'Versión',
                    value: 'v1.2.4 (Build 443)',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.event_outlined,
                    label: 'Evento',
                    value: 'TechSummit Madrid 2024',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.devices_outlined,
                    label: 'Dispositivo',
                    value: 'iPhone 15 Pro · iOS',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.update_outlined,
                    label: 'Última sincronización',
                    value: 'Hace 4 min',
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
                  Row(
                    children: [
                      Text('Soporte y legal', style: textTheme.titleLarge),
                      const Spacer(),
                      const LemaTag(
                        label: 'Sin navegación',
                        color: AppColors.surfaceHigh,
                        textColor: AppColors.onSurfaceMuted,
                        icon: Icons.layers_outlined,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      _ShortcutTile(
                        label: 'Términos y condiciones',
                        icon: Icons.description_outlined,
                        accent: AppColors.primary,
                      ),
                      _ShortcutTile(
                        label: 'Privacidad',
                        icon: Icons.privacy_tip_outlined,
                        accent: AppColors.secondary,
                      ),
                      _ShortcutTile(
                        label: 'Soporte técnico',
                        icon: Icons.support_agent_outlined,
                        accent: AppColors.primaryStrong,
                      ),
                      _ShortcutTile(
                        label: 'Cerrar otras sesiones',
                        icon: Icons.logout_outlined,
                        accent: AppColors.onSurfaceMuted,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surfaceHigh,
              borderColor: AppColors.error.withValues(alpha: 0.3),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.exit_to_app,
                          color: AppColors.error,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cerrar sesión',
                              style: textTheme.titleLarge?.copyWith(
                                color: AppColors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Salir del operador en este dispositivo y volver al acceso.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar sesión'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      foregroundColor: AppColors.error,
                      side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.label,
    required this.icon,
    required this.accent,
  });

  final String label;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 156,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
