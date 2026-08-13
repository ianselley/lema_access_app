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
    final checkedIn = ref.watch(accessManualSearchCheckedInProvider);
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
                          'Código, pedido, email, teléfono o nombre',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                        const SizedBox(height: 18),
                        LemaPanel(
                          color: AppColors.surfaceHighest,
                          borderColor: AppColors.outlineVariant.withValues(
                            alpha: 0.18,
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: _searchController,
                                textInputAction: TextInputAction.search,
                                textCapitalization: TextCapitalization.none,
                                keyboardType: TextInputType.visiblePassword,
                                autocorrect: false,
                                enableSuggestions: false,
                                smartDashesType: SmartDashesType.disabled,
                                smartQuotesType: SmartQuotesType.disabled,
                                style: textTheme.bodyLarge?.copyWith(
                                  color: AppColors.primary,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Consulta',
                                  hintText:
                                      'Código, pedido, email, teléfono o nombre',
                                  prefixIcon: Icon(Icons.search_rounded),
                                ),
                                onChanged: (_) => setState(() {}),
                                onSubmitted: (_) => _runSearch(),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  checkedIn
                                      ? 'Tickets escaneados'
                                      : 'Tickets sin escanear',
                                  style: textTheme.bodyLarge,
                                ),
                                value: checkedIn,
                                onChanged: (value) =>
                                    ref
                                            .read(
                                              accessManualSearchCheckedInProvider
                                                  .notifier,
                                            )
                                            .state =
                                        value,
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
                                label: 'Buscar',
                                icon: Icons.manage_search_rounded,
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
