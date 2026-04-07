import 'package:flutter/material.dart';

enum TicketState { valid, used, invalid, notFound, networkError }

class EventSummary {
  const EventSummary({
    required this.id,
    required this.name,
    required this.location,
    required this.capacityLabel,
    required this.progress,
    required this.progressLabel,
    required this.statusLabel,
    required this.isActive,
  });

  final String id;
  final String name;
  final String location;
  final String capacityLabel;
  final double progress;
  final String progressLabel;
  final String statusLabel;
  final bool isActive;
}

class HistoryEntry {
  const HistoryEntry({
    required this.name,
    required this.ticketType,
    required this.timeAgo,
    required this.status,
  });

  final String name;
  final String ticketType;
  final String timeAgo;
  final TicketState status;
}

class SearchResultEntry {
  const SearchResultEntry({
    required this.name,
    required this.ticketType,
    required this.orderCode,
    required this.status,
  });

  final String name;
  final String ticketType;
  final String orderCode;
  final TicketState status;
}

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
