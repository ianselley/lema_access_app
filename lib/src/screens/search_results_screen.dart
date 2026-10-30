import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/rpc_exception.dart';
import '../core/failure.dart';
import '../models/ticket_models.dart';
import '../providers/activity_refresh_providers.dart';
import '../providers/event_providers.dart';
import '../providers/ticket_providers.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

  @override
  ConsumerState<SearchResultsScreen> createState() =>
      _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  final _searchController = TextEditingController();
  final _vip = <AccessTicketSearchItem>[];
  final _normal = <AccessTicketSearchItem>[];
  Timer? _debounce;
  String _query = '';
  String? _activeKey;
  int _generation = 0;
  int _status = 0; // Todas, escaneadas, sin escanear.
  bool _vipMore = false;
  bool _normalMore = false;
  bool _loadingVip = false;
  bool _loadingNormal = false;
  Object? _error;
  AccessTicketBrowseCount? _count;

  bool? get _checkedIn => _status == 0 ? null : _status == 1;

  @override
  void initState() {
    super.initState();
    _query = ref.read(accessManualSearchQueryProvider).trim();
    _searchController.text = _query;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _applyQuery() {
    final query = _searchController.text.trim();
    if (query == _query) return;
    ref.read(accessManualSearchQueryProvider.notifier).state = query;
    setState(() => _query = query);
  }

  void _reset(String eventId, bool canBrowse, int activityTick) {
    final key = '$eventId|$canBrowse|$_query|$_status|$activityTick';
    if (_activeKey == key) return;
    _activeKey = key;
    final generation = ++_generation;
    _vip.clear();
    _normal.clear();
    _count = null;
    _error = null;
    _vipMore = _normalMore = false;
    _loadingVip = _loadingNormal = false;
    if (!canBrowse && _query.isEmpty) return;
    _loadGroup(eventId, true, generation);
    _loadGroup(eventId, false, generation);
    if (canBrowse) _loadCount(eventId, generation);
  }

  Future<void> _loadCount(String eventId, int generation) async {
    try {
      final count = await ref
          .read(accessTicketServiceProvider)
          .countEventTickets(
            eventId: eventId,
            query: _query,
            checkedIn: _checkedIn,
          );
      if (mounted && generation == _generation) setState(() => _count = count);
    } catch (error) {
      if (mounted && generation == _generation) setState(() => _error = error);
    }
  }

  Future<void> _loadGroup(String eventId, bool vip, int generation) async {
    if (vip ? _loadingVip : _loadingNormal) return;
    final items = vip ? _vip : _normal;
    final offset = items.length;
    setState(() {
      if (vip) {
        _loadingVip = true;
      } else {
        _loadingNormal = true;
      }
    });
    try {
      final page = await ref
          .read(accessTicketServiceProvider)
          .listEventTickets(
            eventId: eventId,
            query: _query,
            checkedIn: _checkedIn,
            vip: vip,
            offset: offset,
          );
      if (!mounted || generation != _generation) return;
      setState(() {
        items.addAll(page.items);
        if (vip) {
          _vipMore = page.hasMore;
        } else {
          _normalMore = page.hasMore;
        }
      });
    } catch (error) {
      if (mounted && generation == _generation) {
        setState(() {
          _error = error;
          if (vip) {
            _vipMore = false;
          } else {
            _normalMore = false;
          }
        });
      }
    } finally {
      if (mounted && generation == _generation) {
        setState(() {
          if (vip) {
            _loadingVip = false;
          } else {
            _loadingNormal = false;
          }
        });
      }
    }
  }

  void _openTicket(AccessTicketSearchItem item) {
    ref
        .read(accessSelectedTicketProvider.notifier)
        .state = AccessTicketSelection(
      eventId: ref.read(accessCurrentEventIdProvider)!,
      ticketId: item.ticket.id,
      query: _query,
      matchReason: item.matchReason,
      ticket: item.ticket,
      contextLabel: _query.isEmpty ? 'Listado de entradas' : 'Búsqueda',
    );
    ref.read(accessLatestCheckInOutcomeProvider.notifier).state = null;
    widget.onOpenTicketDetail?.call();
  }

  @override
  Widget build(BuildContext context) {
    final eventId = ref.watch(accessCurrentEventIdProvider);
    final activityTick = ref.watch(accessActivityRefreshTickProvider);
    final home = eventId == null
        ? null
        : ref.watch(accessEventHomeProvider(eventId));
    final canBrowse = home?.valueOrNull?.canViewCurrentOccupancy;
    if (eventId != null &&
        canBrowse != null &&
        _activeKey != '$eventId|$canBrowse|$_query|$_status|$activityTick') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _reset(eventId, canBrowse, activityTick);
      });
    }
    final showResults = canBrowse == true || _query.isNotEmpty;
    final initialLoading =
        (_loadingVip || _loadingNormal) && _vip.isEmpty && _normal.isEmpty;
    final hasVip = _count?.vip != null ? _count!.vip > 0 : _vip.isNotEmpty;
    final hasNormal = _count?.total != null
        ? _count!.total > _count!.vip
        : _normal.isNotEmpty;
    final textTheme = Theme.of(context).textTheme;

    return LemaScaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          if (eventId == null || canBrowse == null) return;
          _activeKey = null;
          _reset(eventId, canBrowse, activityTick);
        },
        child: CustomScrollView(
          cacheExtent: 900,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            if (canBrowse == false && !showResults)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: OperatorShellScope.maybeOf(context) == null
                        ? 0
                        : OperatorShellScope.bottomNavigationOverlayHeight,
                  ),
                  child: Center(child: _searchField(context)),
                ),
              )
            else
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _searchField(context),
                    if (eventId == null) ...[
                      const SizedBox(height: 16),
                      const _ContextNotice(
                        title: 'Falta evento activo',
                        message: 'Selecciona un evento antes de buscar.',
                        accent: AppColors.warning,
                      ),
                    ],
                    if (canBrowse == null && eventId != null) ...[
                      const SizedBox(height: 24),
                      const _LoadingPanel(),
                    ],
                    if (canBrowse != null && showResults) ...[
                      const SizedBox(height: 20),
                      Text('Estado del ticket', style: textTheme.labelLarge),
                      const SizedBox(height: 8),
                      SegmentedButton<int>(
                        expandedInsets: EdgeInsets.zero,
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(value: 0, label: Text('Todas')),
                          ButtonSegment(value: 1, label: Text('Escaneadas')),
                          ButtonSegment(value: 2, label: Text('Sin escanear')),
                        ],
                        selected: {_status},
                        onSelectionChanged: (selection) =>
                            setState(() => _status = selection.first),
                      ),
                      if (canBrowse) ...[
                        const SizedBox(height: 14),
                        Text(
                          _count == null
                              ? 'Contando resultados…'
                              : '${_count!.total} resultados',
                          style: textTheme.titleMedium,
                        ),
                      ],
                      const SizedBox(height: 18),
                      if (_error != null) _ErrorPanel(error: _error!),
                      if (initialLoading) const _LoadingPanel(),
                      if (!initialLoading &&
                          _error == null &&
                          !hasVip &&
                          !hasNormal)
                        _EmptyResultsPanel(query: _query),
                      if (hasVip) ...[
                        Text('VIP', style: textTheme.titleLarge),
                        const SizedBox(height: 12),
                      ],
                    ],
                  ],
                ),
              ),
            if (showResults && hasVip) _ticketSliver(_vip, vip: true),
            if (showResults && hasNormal)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  child: Text('Entradas', style: textTheme.titleLarge),
                ),
              ),
            if (showResults && hasNormal) _ticketSliver(_normal, vip: false),
            if (canBrowse != false || showResults)
              const SliverToBoxAdapter(child: OperatorShellBottomSpacer()),
          ],
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Buscar ticket', style: Theme.of(context).textTheme.displayMedium),
      const SizedBox(height: 14),
      TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: 'Nombre, contacto, pedido o código',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  onPressed: () {
                    _debounce?.cancel();
                    _searchController.clear();
                    _applyQuery();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        onChanged: (_) {
          setState(() {});
          _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 350), _applyQuery);
        },
        onSubmitted: (_) {
          _debounce?.cancel();
          _applyQuery();
        },
      ),
    ],
  );

  Widget _ticketSliver(
    List<AccessTicketSearchItem> items, {
    required bool vip,
  }) => SliverList.builder(
    itemCount: items.length + ((vip ? _vipMore : _normalMore) ? 1 : 0),
    itemBuilder: (context, index) {
      if (index == items.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final eventId = ref.read(accessCurrentEventIdProvider);
          if (mounted && eventId != null) {
            _loadGroup(eventId, vip, _generation);
          }
        });
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AccessTicketResultCard(
          item: items[index],
          onTap: () => _openTicket(items[index]),
        ),
      );
    },
  );
}

class _ContextNotice extends StatelessWidget {
  const _ContextNotice({
    required this.title,
    required this.message,
    required this.accent,
  });

  final String title;
  final String message;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: accent.withValues(alpha: 0.08),
      borderColor: accent.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: textTheme.titleLarge),
          const SizedBox(height: 6),
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

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const LemaPanel(
      color: AppColors.surfaceLow,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(strokeWidth: 2.4),
        ),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final AccessRpcException? rpcError = error is AccessRpcException
        ? error as AccessRpcException
        : null;
    final message =
        rpcError?.displayMessage ??
        (error is AccessFailure
            ? (error as AccessFailure).displayMessage
            : 'No se pudo cargar la búsqueda.');

    return LemaPanel(
      color: AppColors.error.withValues(alpha: 0.08),
      borderColor: AppColors.error.withValues(alpha: 0.24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No se pudo cargar la búsqueda', style: textTheme.titleLarge),
          const SizedBox(height: 6),
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

class _EmptyResultsPanel extends StatelessWidget {
  const _EmptyResultsPanel({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return LemaPanel(
      color: AppColors.surfaceLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.confirmation_number_outlined,
                size: 20,
                color: AppColors.onSurfaceMuted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  query.isEmpty ? 'No hay tickets' : 'Sin coincidencias',
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            query.isEmpty
                ? 'No hay tickets para mostrar.'
                : 'No hay tickets que coincidan con "$query".',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class AccessTicketResultCard extends StatelessWidget {
  const AccessTicketResultCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final AccessTicketSearchItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = _ticketStatusPresentation(item.ticket.status);

    return LemaStatusStripCard(
      accent: status.accent,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.ticket.attendee.fullName ?? 'Sin nombre',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.ticket.ticketTypeLabel} · ${item.ticket.code}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              LemaStatusPill(label: status.label, color: status.accent),
              if (item.matchReason != TicketSearchMatchReason.other) ...[
                const SizedBox(height: 8),
                Text(
                  item.matchReason.label,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _TicketStatusPresentation {
  const _TicketStatusPresentation({required this.label, required this.accent});

  final String label;
  final Color accent;
}

_TicketStatusPresentation _ticketStatusPresentation(String status) {
  switch (status) {
    case 'issued':
      return const _TicketStatusPresentation(
        label: 'Sin escanear',
        accent: AppColors.warning,
      );
    case 'checked_in':
      return const _TicketStatusPresentation(
        label: 'Escaneada',
        accent: AppColors.success,
      );
    case 'cancelled':
    case 'voided':
      return const _TicketStatusPresentation(
        label: 'Cancelado',
        accent: AppColors.error,
      );
    default:
      return const _TicketStatusPresentation(
        label: 'Desconocido',
        accent: AppColors.onSurfaceMuted,
      );
  }
}
