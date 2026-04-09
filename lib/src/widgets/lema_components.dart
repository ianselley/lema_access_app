import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum TicketState { valid, used, invalid, notFound, networkError }

class StatusTone {
  const StatusTone({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.label,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final String label;
  final IconData icon;
}

class LemaPanel extends StatelessWidget {
  const LemaPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              borderColor ?? AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: child,
    );

    if (onTap == null) {
      return panel;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: panel,
    );
  }
}

class LemaMetricPanel extends StatelessWidget {
  const LemaMetricPanel({
    super.key,
    required this.label,
    required this.value,
    this.accent,
    this.trailing,
  });

  final String label;
  final String value;
  final Color? accent;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return LemaPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: textTheme.labelSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: textTheme.headlineMedium?.copyWith(
                    color: accent ?? AppColors.onSurface,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ],
      ),
    );
  }
}

class LemaSectionHeading extends StatelessWidget {
  const LemaSectionHeading({
    super.key,
    required this.kicker,
    required this.title,
    this.trailing,
  });

  final String kicker;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker.toUpperCase(),
                style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
              ),
              const SizedBox(height: 6),
              Text(title, style: textTheme.displayMedium),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class LemaProgressBar extends StatelessWidget {
  const LemaProgressBar({
    super.key,
    required this.value,
    this.color,
    this.background,
  });

  final double value;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        minHeight: 8,
        value: value.clamp(0, 1),
        backgroundColor: background ?? AppColors.backgroundAlt,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? AppColors.primaryStrong,
        ),
      ),
    );
  }
}

class LemaTag extends StatelessWidget {
  const LemaTag({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}

class LemaPrimaryButton extends StatelessWidget {
  const LemaPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          iconColor: AppColors.black,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        ),
      ),
    );
  }
}

class LemaStatusPill extends StatelessWidget {
  const LemaStatusPill({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}

class LemaResultScreenLayout extends StatelessWidget {
  const LemaResultScreenLayout({
    super.key,
    required this.accent,
    required this.content,
    required this.actions,
  });

  final Color accent;
  final List<Widget> content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Positioned(
              top: -96,
              left: -40,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.16),
                        blurRadius: 120,
                        spreadRadius: 56,
                      ),
                    ],
                  ),
                  child: const SizedBox(width: 180, height: 180),
                ),
              ),
            ),
            Positioned(
              right: -28,
              bottom: 108,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.1),
                        blurRadius: 96,
                        spreadRadius: 36,
                      ),
                    ],
                  ),
                  child: const SizedBox(width: 120, height: 120),
                ),
              ),
            ),
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [...content, const Spacer(), ...actions],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LemaResultHero extends StatelessWidget {
  const LemaResultHero({
    super.key,
    required this.kicker,
    required this.status,
    required this.accent,
    this.icon = Icons.qr_code_scanner_rounded,
    this.subject,
    this.supporting,
  });

  final String kicker;
  final String status;
  final Color accent;
  final IconData icon;
  final String? subject;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trimmedSubject = subject?.trim();
    final trimmedSupporting = supporting?.trim();

    return LemaPanel(
      color: AppColors.surfaceLow,
      borderColor: accent.withValues(alpha: 0.24),
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Positioned(
            right: -36,
            top: -30,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.14),
                      blurRadius: 80,
                      spreadRadius: 18,
                    ),
                  ],
                ),
                child: const SizedBox(width: 96, height: 96),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    LemaTag(
                      label: kicker,
                      color: accent.withValues(alpha: 0.14),
                      textColor: accent,
                    ),
                    const Spacer(),
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.35),
                            blurRadius: 14,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.18),
                        ),
                      ),
                      child: Icon(icon, size: 30, color: accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            status.toUpperCase(),
                            style: textTheme.displayMedium?.copyWith(
                              color: accent,
                            ),
                          ),
                          if (trimmedSubject != null &&
                              trimmedSubject.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              trimmedSubject,
                              style: textTheme.headlineMedium,
                            ),
                          ],
                          if (trimmedSupporting != null &&
                              trimmedSupporting.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              trimmedSupporting,
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LemaResultFocusCard extends StatelessWidget {
  const LemaResultFocusCard({
    super.key,
    required this.accent,
    required this.icon,
    required this.title,
    this.meta,
    this.description,
  });

  final Color accent;
  final IconData icon;
  final String title;
  final String? meta;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final trimmedMeta = meta?.trim();
    final trimmedDescription = description?.trim();

    return LemaPanel(
      color: AppColors.surfaceLow,
      borderColor: accent.withValues(alpha: 0.22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 22, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineMedium?.copyWith(color: accent),
                    ),
                    if (trimmedMeta != null && trimmedMeta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        trimmedMeta,
                        style: textTheme.labelLarge?.copyWith(
                          color: AppColors.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (trimmedDescription != null && trimmedDescription.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundAlt.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: accent.withValues(alpha: 0.12)),
              ),
              child: Text(
                trimmedDescription,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class LemaResultFacts extends StatelessWidget {
  const LemaResultFacts({super.key, required this.facts, this.accent});

  final List<LemaResultFact> facts;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final useTwoColumns = availableWidth >= 360;
        final itemWidth = useTwoColumns
            ? (availableWidth - 12) / 2
            : availableWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: facts
              .map((fact) {
                return SizedBox(
                  width: itemWidth,
                  child: _LemaResultFactCard(fact: fact, accent: accent),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class LemaResultFact {
  const LemaResultFact({required this.label, required this.value, this.icon});

  final String label;
  final String value;
  final IconData? icon;
}

class _LemaResultFactCard extends StatelessWidget {
  const _LemaResultFactCard({required this.fact, this.accent});

  final LemaResultFact fact;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceHighest.withValues(alpha: 0.6),
      borderColor: (accent ?? AppColors.outlineVariant).withValues(alpha: 0.14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (fact.icon != null) ...[
                Icon(
                  fact.icon,
                  size: 14,
                  color: accent ?? AppColors.onSurfaceMuted,
                ),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  fact.label.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            fact.value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

String? lemaJoinText(List<String?> values, {String separator = ' · '}) {
  final cleaned = values
      .map((value) => value?.trim())
      .whereType<String>()
      .where((value) => value.isNotEmpty)
      .toList(growable: false);
  if (cleaned.isEmpty) {
    return null;
  }
  return cleaned.join(separator);
}

class LemaStatusStripCard extends StatelessWidget {
  const LemaStatusStripCard({
    super.key,
    required this.accent,
    required this.child,
    this.onTap,
  });

  final Color accent;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
              child: const SizedBox(width: 4),
            ),
            Expanded(
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ],
        ),
      ),
    );
  }
}

StatusTone toneForState(TicketState state) {
  switch (state) {
    case TicketState.valid:
      return const StatusTone(
        background: AppColors.success,
        foreground: AppColors.black,
        accent: AppColors.success,
        label: 'Válido',
        icon: Icons.check_circle,
      );
    case TicketState.used:
      return const StatusTone(
        background: AppColors.warning,
        foreground: AppColors.black,
        accent: AppColors.warning,
        label: 'Ya usado',
        icon: Icons.history_toggle_off,
      );
    case TicketState.invalid:
      return const StatusTone(
        background: AppColors.error,
        foreground: Colors.white,
        accent: AppColors.error,
        label: 'Inválido',
        icon: Icons.block,
      );
    case TicketState.notFound:
      return const StatusTone(
        background: Color(0xFF6B7280),
        foreground: Colors.white,
        accent: Color(0xFF9CA3AF),
        label: 'No encontrado',
        icon: Icons.search_off,
      );
    case TicketState.networkError:
      return const StatusTone(
        background: Color(0xFF8B5CF6),
        foreground: Colors.white,
        accent: Color(0xFF8B5CF6),
        label: 'Error de red',
        icon: Icons.wifi_off,
      );
  }
}
