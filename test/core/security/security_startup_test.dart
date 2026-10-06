// Security Assessment SA-01, SA-02, SA-04 — device-threat detection
// (ADR-0002, PD-08) at start-up, and the platform settings it depends on.

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:employee_transfer_project/core/security/security_service.dart';
import 'package:employee_transfer_project/core/security/security_startup.dart';
import 'package:employee_transfer_project/core/security/threat_response.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); // freeRASP registers platform channels
  late List<String> calls;

  ThreatResponse response(String env) =>
      ThreatResponse(env: env, warn: (r) => calls.add('warn:$r'), block: (r) => calls.add('block:$r'))..markReady();

  setUp(() => calls = []);

  group('SA-01: a failed start never stops the app', () {
    test('Android and iOS: a start that throws is reported as a threat; UAT warns', () async {
      for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
        calls.clear();
        await SecurityStartup.run(
          platform: platform,
          isWeb: false,
          response: response('uat'),
          start: (_) async => throw Exception('native start failed'),
        );
        expect(calls, ['warn:${SecurityStartup.couldNotStart}'], reason: platform.name);
      }
    });

    test('PROD: a start that throws blocks (fails closed)', () async {
      await SecurityStartup.run(
        platform: TargetPlatform.android,
        isWeb: false,
        response: response('prod'),
        start: (_) async => throw Exception('native start failed'),
      );
      expect(calls, ['block:${SecurityStartup.couldNotStart}']);
    });

    test('a start that succeeds adds nothing; threats it reports reach the response', () async {
      await SecurityStartup.run(
        platform: TargetPlatform.iOS,
        isWeb: false,
        response: response('uat'),
        start: (onThreat) async => onThreat('Rooted/jailbroken device detected.'),
      );
      expect(calls, ['warn:Rooted/jailbroken device detected.']);
    });

    test('web and desktop: detection is not started (freeRASP supports Android and iOS only)', () async {
      var started = 0;
      Future<void> start(void Function(String) _) async => started++;
      await SecurityStartup.run(platform: TargetPlatform.android, isWeb: true, response: response('prod'), start: start);
      for (final platform in [TargetPlatform.macOS, TargetPlatform.windows, TargetPlatform.linux]) {
        await SecurityStartup.run(platform: platform, isWeb: false, response: response('prod'), start: start);
      }
      expect(started, 0);
      expect(calls, isEmpty);
    });

    test('the real SecurityService.start on Android, with the placeholder signing hash, is caught', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      await SecurityStartup.run(
        platform: TargetPlatform.android,
        isWeb: false,
        response: response('uat'),
        start: (onThreat) => SecurityService.start(onThreatDetected: onThreat),
      );
      expect(calls, ['warn:${SecurityStartup.couldNotStart}']);
    });
  });

  group('SA-02: freeRASP uses each platform\'s own app ID', () {
    test('Android package name matches applicationId', () {
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();
      final applicationId = RegExp(r'applicationId\s*=\s*"([^"]+)"').firstMatch(gradle)!.group(1);
      expect(SecurityService.androidPackageName, applicationId);
    });

    test('iOS bundle ID matches the Runner app target', () {
      final pbxproj = File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
      final ids = RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);')
          .allMatches(pbxproj)
          .map((m) => m.group(1)!)
          .where((id) => !id.endsWith('RunnerTests'))
          .toSet();
      expect(ids, hasLength(1));
      expect(SecurityService.iosBundleId, ids.single);
    });
  });

  group('SA-05: threats acted on', () {
    test('root, hooks, debugger, simulator and app tampering all reach the response', () {
      final reasons = <String>[];
      final cb = SecurityService.threatCallback(reasons.add);
      for (final fire in [cb.onPrivilegedAccess, cb.onHooks, cb.onDebug, cb.onSimulator, cb.onAppIntegrity]) {
        fire!();
      }
      expect(reasons, hasLength(5));
      expect(reasons.last, SecurityService.appTampered);
    });
  });

  group('iOS release config', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('release builds run freeRASP in production mode; debug builds in development mode', () {
      expect(SecurityService.config(releaseMode: true).isProd, isTrue);
      expect(SecurityService.config(releaseMode: false).isProd, isFalse);
    });

    test('iOS config uses the iOS bundle ID and the Team ID given at build time', () {
      final ios = SecurityService.config(releaseMode: true, iosTeamId: 'ABCDE12345').iosConfig!;
      expect(ios.bundleIds, [SecurityService.iosBundleId]);
      expect(ios.teamId, 'ABCDE12345');
    });
  });

  test('SA-10: screen capture is blocked in PROD only', () {
    expect(SecurityService.blocksScreenCapture(env: 'prod'), isTrue);
    expect(SecurityService.blocksScreenCapture(env: 'uat'), isFalse);
  });

  test('SA-04: Android backup and device transfer are off for app data', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));

    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();
    expect(rules, contains('<cloud-backup>'));
    expect(rules, contains('<device-transfer>'));
    expect(RegExp('<exclude domain="root" path="."').allMatches(rules), hasLength(2));
  });
}
