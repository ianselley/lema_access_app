import 'package:flutter/material.dart';

import '../models/demo_models.dart';
import '../theme/app_theme.dart';
import '../widgets/lema_components.dart';
import '../widgets/lema_scaffold.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key, this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final results = <SearchResultEntry>[
      const SearchResultEntry(
        name: 'María Fernández',
        ticketType: 'Entrada general',
        orderCode: '#LEMA-4831',
        status: TicketState.valid,
      ),
      const SearchResultEntry(
        name: 'María Fernández',
        ticketType: 'Entrada general',
        orderCode: '#LEMA-4831',
        status: TicketState.used,
      ),
      const SearchResultEntry(
        name: 'Marta Fernández',
        ticketType: 'Pase operador',
        orderCode: '#LEMA-1190',
        status: TicketState.invalid,
      ),
      const SearchResultEntry(
        name: 'María Fernanda',
        ticketType: 'Lista invitada',
        orderCode: '#LEMA-7724',
        status: TicketState.notFound,
      ),
      const SearchResultEntry(
        name: 'María Fernández',
        ticketType: 'Entrada general',
        orderCode: '#LEMA-4831',
        status: TicketState.networkError,
      ),
    ];

    return LemaScaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(textTheme: textTheme),
            const SizedBox(height: 18),
            LemaPanel(
              color: AppColors.surfaceHighest,
              padding: const EdgeInsets.all(18),
              borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
              child: Row(
                children: [
                  Expanded(
                    child: _CountCard(
                      label: 'Coincidencias',
                      value: '5',
                      detail: '1 principal y 4 alternativas',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CountCard(
                      label: 'Consulta',
                      value: 'María',
                      detail: 'Búsqueda manual reciente',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Resultados',
              style: textTheme.titleLarge?.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                for (var index = 0; index < results.length; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ResultCard(
                      entry: results[index],
                      highlighted: index == 0,
                      onTap: index == 0 ? onOpenTicketDetail : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            LemaPanel(
              color: AppColors.surfaceLow,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.tips_and_updates_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Abre el resultado principal para revisar el detalle del ticket y confirmar el acceso manual.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
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

class _Header extends StatelessWidget {
  const _Header({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return LemaPanel(
      color: AppColors.backgroundAlt,
      padding: const EdgeInsets.all(18),
      borderColor: AppColors.outlineVariant.withValues(alpha: 0.18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
                    Text(
                      'Resultados de búsqueda',
                      style: textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              const LemaStatusPill(label: 'En vivo', color: AppColors.success),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Revisión de coincidencias en el evento activo',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({
    required this.label,
    required this.value,
    required this.detail,
  });

  final String label;
  final String value;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            detail,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.entry,
    required this.highlighted,
    this.onTap,
  });

  final SearchResultEntry entry;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final tone = toneForState(entry.status);

    return LemaStatusStripCard(
      accent: tone.accent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      style: textTheme.headlineMedium?.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.ticketType,
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceMuted,
                      ),
                    ),
                  ],
                ),
              ),
              LemaTag(
                label: tone.label,
                color: tone.background.withValues(alpha: 0.14),
                textColor: tone.accent,
                icon: tone.icon,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MetaTile(label: 'Código', value: entry.orderCode),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetaTile(
                  label: 'Estado',
                  value: highlighted ? 'Principal' : 'Alternativa',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            highlighted
                ? 'Coincidencia principal para abrir el detalle del ticket.'
                : 'Resultado alternativo por similitud de nombre o tipo de entrada.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTile extends StatelessWidget {
  const _MetaTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelSmall?.copyWith(
              color: AppColors.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
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
