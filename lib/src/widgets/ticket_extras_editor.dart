import 'package:flutter/material.dart';

import '../core/failure.dart';
import '../core/rpc_exception.dart';
import '../models/add_on_models.dart';
import '../theme/app_theme.dart';

class TicketExtrasEditor extends StatefulWidget {
  const TicketExtrasEditor({
    super.key,
    required this.addOns,
    required this.onSave,
  });

  final List<AccessTicketAddOn> addOns;
  final Future<void> Function(
    List<String> undoRedemptionIds,
    List<Map<String, dynamic>> redemptions,
    Map<String, int> expectedQuantities,
  )
  onSave;

  @override
  State<TicketExtrasEditor> createState() => _TicketExtrasEditorState();
}

class _TicketExtrasEditorState extends State<TicketExtrasEditor> {
  final _undoIds = <String>{};
  final _redeemIds = <String>{};
  bool _saving = false;
  String? _error;

  bool get _changed => _undoIds.isNotEmpty || _redeemIds.isNotEmpty;

  Future<void> _save() async {
    if (!_changed) {
      Navigator.pop(context, false);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSave(
        _undoIds.toList(),
        [
          for (final addOn in widget.addOns)
            if (_redeemIds.contains(addOn.assignmentId))
              {
                'assignment_id': addOn.assignmentId,
                'quantity': addOn.remainingQuantity,
              },
        ],
        {
          for (final addOn in widget.addOns)
            if (_redeemIds.contains(addOn.assignmentId) ||
                addOn.redemptions.any((item) => _undoIds.contains(item.id)))
              addOn.assignmentId: addOn.redeemedQuantity,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = switch (error) {
          AccessFailure failure => failure.displayMessage,
          AccessRpcException failure => failure.displayMessage,
          _ => 'No se pudieron guardar los extras. Inténtalo de nuevo.',
        };
      });
    }
  }

  Widget _row({
    required String title,
    required bool checked,
    required bool changed,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      value: checked,
      onChanged: _saving ? null : onChanged,
      activeColor: AppColors.primaryStrong,
      title: Text(title),
      secondary: changed
          ? const Tooltip(
              message: 'Modificado',
              child: Icon(
                Icons.edit_outlined,
                color: AppColors.primaryStrong,
                size: 18,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_saving,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Editar extras',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Text('Marca los extras que se hayan consumido'),
              const SizedBox(height: 12),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final addOn in widget.addOns) ...[
                        for (final redemption in addOn.redemptions)
                          _row(
                            title:
                                '${redemption.quantity} × ${addOn.displayName}',
                            checked: !_undoIds.contains(redemption.id),
                            changed: _undoIds.contains(redemption.id),
                            onChanged: (checked) => setState(() {
                              checked == true
                                  ? _undoIds.remove(redemption.id)
                                  : _undoIds.add(redemption.id);
                            }),
                          ),
                        if (addOn.remainingQuantity > 0)
                          _row(
                            title:
                                '${addOn.remainingQuantity} × ${addOn.displayName}',
                            checked: _redeemIds.contains(addOn.assignmentId),
                            changed: _redeemIds.contains(addOn.assignmentId),
                            onChanged: (checked) => setState(() {
                              checked == true
                                  ? _redeemIds.add(addOn.assignmentId)
                                  : _redeemIds.remove(addOn.assignmentId);
                            }),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _changed
                      ? AppColors.primaryStrong
                      : Colors.grey.shade700,
                  foregroundColor: _changed
                      ? Colors.black
                      : AppColors.onSurface,
                ),
                onPressed: _saving ? null : _save,
                child: Text(
                  _saving
                      ? 'Guardando...'
                      : _changed
                      ? 'Confirmar cambios'
                      : 'Cerrar sin cambios',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
