import 'package:freerasp/freerasp.dart';

/// Root/jailbreak/Frida-hook detection — mandatory per ADR-0002. This class
/// only *detects* and reports; the response (block vs. warn) is wired by
/// whoever calls [start], per the Plan-stage decision for
/// `employee-internal-transfer`.
///
/// TODO before release (values unknown at scaffolding time — do not ship
/// with these placeholders):
///   - `signingCertHashes`: the app's real release-signing certificate hash.
///   - iOS `teamId`: the Apple Developer Team ID.
///   - `watcherMail`: address that receives Talsec threat alerts, if used.
class SecurityService {
  SecurityService._();

  static const _packageId = 'com.intglobal.employee_transfer_project';

  /// Starts threat monitoring. [onThreatDetected] fires with a short,
  /// PII-free reason string for any of root/jailbreak, Frida/hooking, or
  /// debugger attachment — the three detections ADR-0002 calls mandatory.
  /// Other available freeRASP signals (emulator, unofficial store, etc.) are
  /// wired but not yet mapped to a required behaviour — extend as the Plan
  /// stage decides.
  static Future<void> start({
    required void Function(String reason) onThreatDetected,
  }) async {
    Talsec.instance.attachListener(
      ThreatCallback(
        onPrivilegedAccess: () => onThreatDetected('Rooted/jailbroken device detected.'),
        onHooks: () => onThreatDetected('Runtime hooking framework (e.g. Frida) detected.'),
        onDebug: () => onThreatDetected('Debugger attached.'),
        onSimulator: () => onThreatDetected('Running on an emulator/simulator.'),
      ),
    );

    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: _packageId,
        signingCertHashes: ['TODO-real-release-signing-cert-hash'],
      ),
      iosConfig: IOSConfig(
        bundleIds: [_packageId],
        teamId: 'TODO-apple-team-id',
      ),
      watcherMail: 'TODO-security-alerts@intglobal.com',
      isProd: false, // flip to true for release builds once config above is real
    );

    await Talsec.instance.start(config);
  }
}
