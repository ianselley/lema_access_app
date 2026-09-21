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

  @override
  void initState() {
    super.initState();
    final initialQuery = ref.read(accessManualSearchQueryProvider).trim();
    if (initialQuery.isEmpty) {
      return;
    }

    _searchController.value = TextEditingValue(
      text: initialQuery,
      selection: TextSelection.collapsed(offset: initialQuery.length),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final bottomSpacerHeight = OperatorShellScope.maybeOf(context) == null
        ? 0.0
        : OperatorShellScope.bottomNavigationOverlayHeight;

    return LemaScaffold(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final topOffset = (constraints.maxHeight * 0.2).clamp(72.0, 156.0);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomSpacerHeight),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: topOffset.toDouble()),
                        Text('Buscar ticket', style: textTheme.displayMedium),
                        const SizedBox(height: 6),
                        Text(
                          'Encuentra una entrada por sus datos',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        LemaPanel(
                          color: AppColors.surfaceLow,
                          borderColor: AppColors.primary.withValues(
                            alpha: 0.22,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.confirmation_number_outlined,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Datos del ticket',
                                          style: textTheme.titleLarge,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Busca dentro del evento activo',
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
                              TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.visiblePassword,
                                autocorrect: false,
                                enableSuggestions: false,
                                smartDashesType: SmartDashesType.disabled,
                                smartQuotesType: SmartQuotesType.disabled,
                                style: textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText:
                                      'Nombre, contacto, pedido o código',
                                  hintText: 'Ej. Ana García o ABC123',
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: AppColors.primary,
                                  ),
                                  suffixIcon: hasQuery
                                      ? IconButton(
                                          tooltip: 'Borrar búsqueda',
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() {});
                                          },
                                          icon: const Icon(Icons.close_rounded),
                                        )
                                      : null,
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _runSearch(),
                              ),
                              if (!hasEventContext) ...[
                                const SizedBox(height: 14),
                                _ContextNotice(
                                  title: 'Falta evento activo',
                                  message:
                                      'Selecciona un evento antes de buscar.',
                                ),
                              ],
                              const SizedBox(height: 16),
                              LemaPrimaryButton(
                                label: 'Ver resultados',
                                icon: Icons.arrow_forward_rounded,
                                onPressed: hasQuery && hasEventContext
                                    ? _runSearch
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
