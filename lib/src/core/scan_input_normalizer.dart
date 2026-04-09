final RegExp _likelyScanTokenPattern = RegExp(r'^[A-Za-z0-9_-]{24,}$');

String normalizeAccessScanInput(String rawInput) {
  final trimmedInput = rawInput.trim();
  if (trimmedInput.isEmpty) {
    return trimmedInput;
  }

  return extractLemaTicketToken(trimmedInput) ?? trimmedInput;
}

String? extractLemaTicketToken(String rawInput) {
  final trimmedInput = rawInput.trim();
  if (trimmedInput.isEmpty) {
    return null;
  }

  if (_likelyScanTokenPattern.hasMatch(trimmedInput)) {
    return trimmedInput;
  }

  final uri = Uri.tryParse(trimmedInput);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return null;
  }

  final scheme = uri.scheme.toLowerCase();
  final host = uri.host.toLowerCase();
  if ((scheme != 'http' && scheme != 'https') ||
      !(host == 'lema.club' || host == 'www.lema.club')) {
    return null;
  }

  final segments = uri.pathSegments;
  if (segments.length < 2 || segments.first.toLowerCase() != 'ticket') {
    return null;
  }

  final token = segments[1].trim();
  return token.isEmpty ? null : token;
}
