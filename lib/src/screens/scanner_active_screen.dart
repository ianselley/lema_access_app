import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ScannerActiveScreen extends StatelessWidget {
  const ScannerActiveScreen({
    super.key,
    this.onOpenValid,
    this.onOpenUsed,
    this.onOpenInvalid,
    this.onOpenNotFound,
    this.onOpenNetworkError,
    this.onManualEntry,
    this.onManualSearch,
  });

  final VoidCallback? onOpenValid;
  final VoidCallback? onOpenUsed;
  final VoidCallback? onOpenInvalid;
  final VoidCallback? onOpenNotFound;
  final VoidCallback? onOpenNetworkError;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _ScannerHeader(
                    eventName: 'TechSummit Madrid 2024',
                    operatorName: 'Operador LEMA',
                    title: textTheme.displayMedium,
                  ),
                  const SizedBox(height: 20),
                  _ScannerViewport(),
                  const SizedBox(height: 18),
                  _LiveStatusRow(),
                  const SizedBox(height: 18),
                  _TipsPanel(),
                  const SizedBox(height: 18),
                  _QuickActions(
                    onOpenValid: onOpenValid,
                    onOpenUsed: onOpenUsed,
                    onOpenInvalid: onOpenInvalid,
                    onOpenNotFound: onOpenNotFound,
                    onOpenNetworkError: onOpenNetworkError,
                    onManualEntry: onManualEntry,
                    onManualSearch: onManualSearch,
                  ),
                  const SizedBox(height: 18),
                  _ResultPreviewStrip(
                    title: 'Resultados demo',
                    subtitle:
                        'Usa estas acciones para abrir cada estado sin salir del flujo de escaneo.',
                    entries: [
                      _DemoEntry(
                        label: 'Válido',
                        state: TicketState.valid,
                        onTap: onOpenValid,
                      ),
                      _DemoEntry(
                        label: 'Ya usado',
                        state: TicketState.used,
                        onTap: onOpenUsed,
                      ),
                      _DemoEntry(
                        label: 'Inválido',
                        state: TicketState.invalid,
                        onTap: onOpenInvalid,
                      ),
                      _DemoEntry(
                        label: 'No encontrado',
                        state: TicketState.notFound,
                        onTap: onOpenNotFound,
                      ),
                      _DemoEntry(
                        label: 'Error de red',
                        state: TicketState.networkError,
                        onTap: onOpenNetworkError,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _OperatorFooter(
                    onManualEntry: onManualEntry,
                    onManualSearch: onManualSearch,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScannerHeader extends StatelessWidget {
  const _ScannerHeader({
    required this.eventName,
    required this.operatorName,
    required this.title,
  });

  final String eventName;
  final String operatorName;
  final TextStyle? title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ESCÁNER ACTIVO',
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(eventName, style: title),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  const LemaTag(label: 'En vivo', icon: Icons.sensors),
                  LemaTag(
                    label: operatorName,
                    color: AppColors.surfaceHigh,
                    textColor: AppColors.onSurface,
                    icon: Icons.badge_outlined,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const _NetworkBadge(),
      ],
    );
  }
}

class _NetworkBadge extends StatelessWidget {
  const _NetworkBadge();

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Conectado',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.success),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('LATENCIA 12 MS', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ScannerViewport extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      padding: EdgeInsets.zero,
      color: AppColors.surfaceLow,
      child: AspectRatio(
        aspectRatio: 1.18,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt,
                borderRadius: BorderRadius.circular(10),
                gradient: const RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Color(0x22EF8354), AppColors.backgroundAlt],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.26),
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const _ScannerCorners(),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.92, end: 1),
                            duration: const Duration(milliseconds: 1400),
                            curve: Curves.easeInOut,
                            builder: (context, scale, child) {
                              return Transform.scale(
                                scale: scale,
                                child: child,
                              );
                            },
                            child: Container(
                              width: 92,
                              height: 92,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                border: Border.all(
                                  color: AppColors.primaryStrong.withValues(
                                    alpha: 0.55,
                                  ),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner,
                                size: 42,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Alinea el código dentro del marco',
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'El lector detecta automáticamente tickets válidos, usados, inválidos y búsquedas manuales.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.onSurfaceMuted),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: _ScanLine(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: CustomPaint(painter: _ScannerCornerPainter()),
    );
  }
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryStrong.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    const corner = 26.0;
    final path = Path()
      ..moveTo(0, corner)
      ..lineTo(0, 0)
      ..lineTo(corner, 0)
      ..moveTo(size.width - corner, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, corner)
      ..moveTo(0, size.height - corner)
      ..lineTo(0, size.height)
      ..lineTo(corner, size.height)
      ..moveTo(size.width - corner, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, size.height - corner);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryStrong.withValues(alpha: 0.35),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _LiveStatusRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LemaMetricPanel(
            label: 'Estado',
            value: 'Leyendo',
            accent: AppColors.primary,
            trailing: const Icon(Icons.sensors, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: LemaMetricPanel(
            label: 'Sesión',
            value: 'Operativa',
            accent: AppColors.success,
            trailing: const Icon(Icons.shield, color: AppColors.success),
          ),
        ),
      ],
    );
  }
}

class _TipsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Indicaciones rápidas', style: textTheme.titleLarge),
          const SizedBox(height: 14),
          const _TipLine(
            icon: Icons.flash_on,
            label: 'Mantén el código centrado y estable durante un segundo.',
          ),
          const SizedBox(height: 10),
          const _TipLine(
            icon: Icons.nfc,
            label:
                'Si el escaneo falla, prueba entrada manual o búsqueda por nombre.',
          ),
          const SizedBox(height: 10),
          const _TipLine(
            icon: Icons.lock_outline,
            label: 'El resultado se valida antes de confirmar acceso.',
          ),
        ],
      ),
    );
  }
}

class _TipLine extends StatelessWidget {
  const _TipLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primaryStrong),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onOpenValid,
    required this.onOpenUsed,
    required this.onOpenInvalid,
    required this.onOpenNotFound,
    required this.onOpenNetworkError,
    required this.onManualEntry,
    required this.onManualSearch,
  });

  final VoidCallback? onOpenValid;
  final VoidCallback? onOpenUsed;
  final VoidCallback? onOpenInvalid;
  final VoidCallback? onOpenNotFound;
  final VoidCallback? onOpenNetworkError;
  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  Widget build(BuildContext context) {
    final actions = <_ActionData>[
      _ActionData(label: 'Manual', icon: Icons.edit_note, onTap: onManualEntry),
      _ActionData(
        label: 'Buscar',
        icon: Icons.manage_search,
        onTap: onManualSearch,
      ),
      _ActionData(
        label: 'Válido',
        icon: Icons.check_circle,
        onTap: onOpenValid,
      ),
      _ActionData(
        label: 'Usado',
        icon: Icons.history_toggle_off,
        onTap: onOpenUsed,
      ),
      _ActionData(label: 'Inválido', icon: Icons.block, onTap: onOpenInvalid),
      _ActionData(
        label: 'No encontrado',
        icon: Icons.search_off,
        onTap: onOpenNotFound,
      ),
      _ActionData(
        label: 'Red',
        icon: Icons.wifi_off,
        onTap: onOpenNetworkError,
      ),
    ];

    return LemaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.9,
            ),
            itemBuilder: (context, index) {
              final action = actions[index];
              return _ActionTile(data: action);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionData {
  const _ActionData({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.data});

  final _ActionData data;

  @override
  Widget build(BuildContext context) {
    final enabled = data.onTap != null;

    return Material(
      color: AppColors.surfaceHigh,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: enabled
                  ? AppColors.outlineVariant.withValues(alpha: 0.22)
                  : AppColors.outlineVariant.withValues(alpha: 0.12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                data.icon,
                size: 18,
                color: enabled ? AppColors.primary : AppColors.onSurfaceMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: enabled
                        ? AppColors.onSurface
                        : AppColors.onSurfaceMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultPreviewStrip extends StatelessWidget {
  const _ResultPreviewStrip({
    required this.title,
    required this.subtitle,
    required this.entries,
  });

  final String title;
  final String subtitle;
  final List<_DemoEntry> entries;

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: entries
                .map(
                  (entry) => _DemoChip(
                    label: entry.label,
                    tone: toneForState(entry.state),
                    onTap: entry.onTap,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _DemoEntry {
  const _DemoEntry({
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String label;
  final TicketState state;
  final VoidCallback? onTap;
}

class _DemoChip extends StatelessWidget {
  const _DemoChip({
    required this.label,
    required this.tone,
    required this.onTap,
  });

  final String label;
  final StatusTone tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(tone.icon, size: 16, color: tone.foreground),
      label: Text(label),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelLarge?.copyWith(color: tone.foreground),
      backgroundColor: tone.background.withValues(alpha: 0.16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isEnabled
              ? tone.background.withValues(alpha: 0.4)
              : AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _OperatorFooter extends StatelessWidget {
  const _OperatorFooter({
    required this.onManualEntry,
    required this.onManualSearch,
  });

  final VoidCallback? onManualEntry;
  final VoidCallback? onManualSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LemaPrimaryButton(
            label: 'Entrada manual',
            icon: Icons.edit_note,
            onPressed: onManualEntry,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onManualSearch,
            icon: const Icon(Icons.manage_search, size: 18),
            label: const Text('Buscar'),
          ),
        ),
      ],
    );
  }
}
