import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';

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
      child: Row(
        children: [
          Container(
            width: 4,
            height: double.infinity,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(10),
              ),
            ),
          ),
          Expanded(
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ],
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
