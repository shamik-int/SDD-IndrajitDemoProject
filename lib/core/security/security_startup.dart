import 'package:flutter/foundation.dart';

import 'threat_response.dart';

/// Starts device-threat detection (ADR-0002) in a way that can never stop the
/// app from opening (Security Assessment SA-01).
///
/// freeRASP supports Android and iOS only, so nothing is started on web or
/// desktop. On Android and iOS, a start that fails — for example an invalid
/// signing hash, rejected by freeRASP before it starts — is reported to the
/// [ThreatResponse] as a threat: PROD blocks (fails closed), UAT warns.
class SecurityStartup {
  SecurityStartup._();

  static const couldNotStart = 'Device security check could not start.';

  static bool supports(TargetPlatform platform, {required bool isWeb}) =>
      !isWeb && (platform == TargetPlatform.android || platform == TargetPlatform.iOS);

  static Future<void> run({
    required TargetPlatform platform,
    required bool isWeb,
    required ThreatResponse response,
    required Future<void> Function(void Function(String reason) onThreat) start,
  }) async {
    if (!supports(platform, isWeb: isWeb)) return;
    try {
      await start(response.onThreat);
    } catch (_) {
      response.onThreat(couldNotStart);
    }
  }
}
