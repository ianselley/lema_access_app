import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_scaffold.dart';

enum OperatorShellTab { scanner, manual, history }

class OperatorShellScreen extends StatelessWidget {
  const OperatorShellScreen({
    super.key,
    required this.tab,
    required this.child,
    this.onSelectScanner,
    this.onSelectManual,
    this.onSelectHistory,
  });

  final OperatorShellTab tab;
  final Widget child;
  final VoidCallback? onSelectScanner;
  final VoidCallback? onSelectManual;
  final VoidCallback? onSelectHistory;

  @override
  Widget build(BuildContext context) {
    return OperatorShellScope(
      bottomNavigation: _OperatorBottomNavigation(
        tab: tab,
        onSelectScanner: onSelectScanner,
        onSelectManual: onSelectManual,
        onSelectHistory: onSelectHistory,
      ),
      child: child,
    );
  }
}

class _OperatorBottomNavigation extends StatelessWidget {
  const _OperatorBottomNavigation({
    required this.tab,
    this.onSelectScanner,
    this.onSelectManual,
    this.onSelectHistory,
  });

  final OperatorShellTab tab;
  final VoidCallback? onSelectScanner;
  final VoidCallback? onSelectManual;
  final VoidCallback? onSelectHistory;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _NavButton(
              label: 'Escanear',
              icon: Icons.qr_code_scanner_rounded,
              selected: tab == OperatorShellTab.scanner,
              onPressed: onSelectScanner,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NavButton(
              label: 'Manual',
              icon: Icons.keyboard_alt_rounded,
              selected: tab == OperatorShellTab.manual,
              onPressed: onSelectManual,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _NavButton(
              label: 'Historial',
              icon: Icons.history_rounded,
              selected: tab == OperatorShellTab.history,
              onPressed: onSelectHistory,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.selected,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.black : AppColors.onSurface;
    final bg = selected ? AppColors.primary : Colors.transparent;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: fg),
              const SizedBox(height: 4),
              Text(
                label.toUpperCase(),
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
