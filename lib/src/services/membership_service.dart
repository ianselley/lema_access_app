import '../core/debug_log.dart';
import '../core/rpc_client.dart';
import '../models/event_models.dart';

class AccessMembershipService {
  AccessMembershipService(this._rpc);

  final AccessRpcClient _rpc;

  Future<AccessScannerInviteClaimResult> claimScannerInviteCode(
    String code,
  ) async {
    final response = await _rpc.call(
      'access_claim_scanner_invite_code',
      params: {'p_code': code.trim()},
    );
    final result = AccessScannerInviteClaimResult.fromJson(
      readMap(response['data']),
    );
    accessLog(
      'Scanner invite claimed: scope=${result.scope} eventCount=${result.resolvedEventCount} brandId=${result.brandId}',
      scope: 'membership',
    );
    return result;
  }
}
