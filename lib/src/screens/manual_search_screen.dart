import 'package:flutter/material.dart';

import 'search_results_screen.dart';

class ManualSearchScreen extends StatelessWidget {
  const ManualSearchScreen({super.key, this.onOpenTicketDetail});

  final VoidCallback? onOpenTicketDetail;

  @override
  Widget build(BuildContext context) =>
      SearchResultsScreen(onOpenTicketDetail: onOpenTicketDetail);
}
