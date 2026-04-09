import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/event_providers.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class ManualSearchScreen extends ConsumerStatefulWidget {
  const ManualSearchScreen({super.key, this.onSearch});

  final VoidCallback? onSearch;

  @override
  ConsumerState<ManualSearchScreen> createState() => _ManualSearchScreenState();
}

class _ManualSearchScreenState extends ConsumerState<ManualSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _recentQueries = <String>[
    'María Fernández',
    'LEMA-4831',
    'juan@dominio.com',
    '+34 600 000 000',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyRecentQuery(String query) {
    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    setState(() {});
  }

  void _runSearch() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      return;
    }

    ref.read(accessManualSearchQueryProvider.notifier).state = query;
    ref.read(accessSelectedTicketProvider.notifier).state = null;
    ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
    widget.onSearch?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hasQuery = _searchController.text.trim().isNotEmpty;
    final eventId = ref.watch(accessCurrentEventIdProvider);
    final hasEventContext = eventId != null && eventId.trim().isNotEmpty;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'BÚSQUEDA MANUAL',
              style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text('Localizar ticket', style: textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
              hasEventContext
                  ? 'Evento activo conectado.'
                  : 'Necesitas un evento activo para buscar.',
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceMuted,
              ),
            ),
            const SizedBox(height: 20),
            LemaPanel(
              color: AppColors.surfaceHighest,
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
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
                      hintText: 'Nombre, código, pedido, email o teléfono',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _runSearch(),
                  ),
                  if (!hasEventContext) ...[
                    const SizedBox(height: 14),
                    _ContextNotice(
                      title: 'Falta evento activo',
                      message: 'Selecciona un evento antes de buscar.',
                    ),
                  ],
                  const SizedBox(height: 16),
                  LemaPrimaryButton(
                    label: 'Buscar',
                    icon: Icons.manage_search_rounded,
                    onPressed: hasQuery && hasEventContext ? _runSearch : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(18),
              child: Wrap(
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
            ),
            const OperatorShellBottomSpacer(),
          ],
        ),
      ),
    );
  }
}

class _ContextNotice extends StatelessWidget {
  const _ContextNotice({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.labelLarge?.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
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
