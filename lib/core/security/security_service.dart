import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';

/// Root/jailbreak/Frida-hook detection — mandatory per ADR-0002. This class
/// only *detects* and reports; the response (block vs. warn) is wired by
/// whoever calls [start], per the Plan-stage decision for
/// `employee-internal-transfer`.
///
/// Start it through `SecurityStartup.run`, which skips unsupported platforms
/// and turns a failed start into a threat (Security Assessment SA-01).
///
/// Release values come from `--dart-define` at build time, never from the
/// repository (release blocker in PROJECT_CHECKLIST.md §8):
///   - `RASP_ANDROID_CERT_HASH`: the Android release certificate's SHA-256,
///     Base64. Without it freeRASP rejects the placeholder and Android
///     reports "could not start".
///   - `RASP_IOS_TEAM_ID`: the Apple Developer Team ID that signs the iOS
///     app. With the placeholder, app-integrity checks fail on a real build.
///   - `watcherMail`: address that receives Talsec threat alerts, if used.
class SecurityService {
  SecurityService._();

  /// Must match `applicationId` in `android/app/build.gradle.kts` (tested).
  static const androidPackageName = 'com.intglobal.employee_transfer_project';

  /// Must match the Runner target's `PRODUCT_BUNDLE_IDENTIFIER` (tested).
  /// iOS bundle IDs cannot contain underscores, so it differs from Android.
  static const iosBundleId = 'com.intglobal.employeeTransferProject';

  static const _androidCertHash =
      String.fromEnvironment('RASP_ANDROID_CERT_HASH', defaultValue: 'TODO-real-release-signing-cert-hash');
  static const _iosTeamId = String.fromEnvironment('RASP_IOS_TEAM_ID', defaultValue: 'TODO-apple-team-id');

  static const rooted = 'Rooted/jailbroken device detected.';
  static const hooked = 'Runtime hooking framework (e.g. Frida) detected.';
  static const debugger = 'Debugger attached.';
  static const simulator = 'Running on an emulator/simulator.';
  static const appTampered = 'This app has been modified or re-signed.';

  /// The threats acted on, each with a short, PII-free reason: the three
  /// ADR-0002 calls mandatory, the emulator, and app tampering or
  /// re-signing (Security Assessment SA-05). Other freeRASP signals are not
  /// acted on.
  static ThreatCallback threatCallback(void Function(String reason) onThreat) => ThreatCallback(
        onPrivilegedAccess: () => onThreat(rooted),
        onHooks: () => onThreat(hooked),
        onDebug: () => onThreat(debugger),
        onSimulator: () => onThreat(simulator),
        onAppIntegrity: () => onThreat(appTampered),
      );

  /// Production mode in release builds only; development mode relaxes the
  /// checks that would fire while debugging.
  static TalsecConfig config({required bool releaseMode, String iosTeamId = _iosTeamId}) => TalsecConfig(
        androidConfig: AndroidConfig(
          packageName: androidPackageName,
          signingCertHashes: [_androidCertHash],
        ),
        iosConfig: IOSConfig(
          bundleIds: [iosBundleId],
          teamId: iosTeamId,
        ),
        watcherMail: 'TODO-security-alerts@intglobal.com',
        isProd: releaseMode,
      );

  /// Screenshots and screen recording come out black in PROD (SA-10). UAT
  /// keeps them, so testers can record defects.
  static bool blocksScreenCapture({required String env}) => env == 'prod';

  /// Starts threat monitoring; [onThreatDetected] receives the reason.
  static Future<void> start({
    required void Function(String reason) onThreatDetected,
    bool blockScreenCapture = false,
  }) async {
    Talsec.instance.attachListener(threatCallback(onThreatDetected));
    await Talsec.instance.start(config(releaseMode: kReleaseMode));
    if (blockScreenCapture) await Talsec.instance.blockScreenCapture(enabled: true);
  }
}
