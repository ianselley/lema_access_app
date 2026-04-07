import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

enum _ManualSearchFilter { name, code, order, vip }

class ManualSearchScreen extends StatefulWidget {
  const ManualSearchScreen({super.key, this.onSearch});

  final VoidCallback? onSearch;

  @override
  State<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends State<ManualSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  _ManualSearchFilter _selectedFilter = _ManualSearchFilter.name;

  static const List<String> _recentQueries = <String>[
    'María Fernández',
    'LEMA-4831',
    'VIP Madrid',
    'Entrada general',
  ];

  static const List<String> _searchHints = <String>[
    'Escribe un nombre completo o parcial.',
    'Prueba con el código del ticket si lo tienes.',
    'Filtra por tipo para reducir resultados.',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _runSearch() {
    if (_searchController.text.trim().isEmpty) {
      return;
    }

    widget.onSearch?.call();
  }

  void _applyRecentQuery(String query) {
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() {});
  }

  String _filterLabel(_ManualSearchFilter filter) {
    switch (filter) {
      case _ManualSearchFilter.name:
        return 'Nombre';
      case _ManualSearchFilter.code:
        return 'Código';
      case _ManualSearchFilter.order:
        return 'Pedido';
      case _ManualSearchFilter.vip:
        return 'VIP';
    }
  }

  IconData _filterIcon(_ManualSearchFilter filter) {
    switch (filter) {
      case _ManualSearchFilter.name:
        return Icons.person_search_rounded;
      case _ManualSearchFilter.code:
        return Icons.qr_code_2_rounded;
      case _ManualSearchFilter.order:
        return Icons.receipt_long_rounded;
      case _ManualSearchFilter.vip:
        return Icons.workspace_premium_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.vertical -
                42,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.manage_search_rounded,
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
                          'Búsqueda manual',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Localizar ticket', style: textTheme.titleLarge),
                      ],
                    ),
                  ),
                  LemaTag(
                    label: 'Operativo',
                    color: AppColors.surfaceHigh,
                    textColor: AppColors.primary,
                    icon: Icons.bolt_rounded,
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
                    Text(
                      'Busca por nombre, código o pedido',
                      style: textTheme.displayMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Usa el criterio que tengas a mano y refina la búsqueda con un filtro rápido.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.words,
                      keyboardType: TextInputType.text,
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Consulta',
                        hintText: 'María Fernández, LEMA-4831, VIP Madrid...',
                        prefixIcon: Icon(Icons.search_rounded),
                      ),
                      onChanged: (_) => setState(() {}),
                      onSubmitted: (_) => _runSearch(),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final filter in _ManualSearchFilter.values)
                          _SearchFilterChip(
                            label: _filterLabel(filter),
                            icon: _filterIcon(filter),
                            selected: _selectedFilter == filter,
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
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
                      'Búsquedas recientes',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final query in _recentQueries)
                          _RecentQueryChip(
                            label: query,
                            onTap: () => _applyRecentQuery(query),
                          ),
                      ],
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
                      'Sugerencias de uso',
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final hint in _searchHints) ...[
                      _HintRow(label: hint),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              LemaPrimaryButton(
                label: 'Buscar',
                icon: Icons.manage_search_rounded,
                onPressed: hasQuery ? _runSearch : null,
              ),
              const SizedBox(height: 12),
              Text(
                'La búsqueda abre el listado de resultados para revisar el ticket exacto.',
                textAlign: TextAlign.center,
                style: textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchFilterChip extends StatelessWidget {
  const _SearchFilterChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.black : AppColors.onSurface;
    final bg = selected ? AppColors.primary : AppColors.surfaceHigh;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 8),
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

class _RecentQueryChip extends StatelessWidget {
  const _RecentQueryChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      label: Text(label),
      avatar: const Icon(
        Icons.history_rounded,
        size: 16,
        color: AppColors.primary,
      ),
      labelStyle: Theme.of(
        context,
      ).textTheme.labelSmall?.copyWith(color: AppColors.onSurface),
      backgroundColor: AppColors.backgroundAlt,
      side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.15)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 5),
          decoration: const BoxDecoration(
            color: AppColors.primaryStrong,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ),
      ],
    );
  }
}
