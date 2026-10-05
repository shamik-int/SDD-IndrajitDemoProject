import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/local_db/local_db_service.dart';
import 'core/security/security_service.dart';
import 'core/security/threat_response.dart';
import 'core/utils/common_utils.dart';
import 'data/transfer/portal/demo_data_seeder.dart';
import 'presentation/transfer/shared/device_block.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment selection — pass `--dart-define=ENV=prod` or `ENV=uat` at
  // build/run time (ADR-0001 §3). Without it, debug and profile runs are UAT
  // and a release build is PROD, so the threat response fails closed (G2-08).
  final env = ThreatResponse.resolveEnv(const String.fromEnvironment('ENV'), releaseMode: kReleaseMode);
  await dotenv.load(
    fileName: env == 'prod' ? 'assets/env/.env.prod' : 'assets/env/.env.uat',
  );

  await LocalDbService.init();
  // Plan PD-06: clear v1.5/BRD-002 demo data once and seed the demo accounts.
  await DemoDataSeeder(LocalDbService()).ensureSeeded();

  // Detection is mandatory (ADR-0002). Response per plan PD-08: warn in UAT,
  // block in PROD. Threats are held until the entry screen has routed.
  final response = Get.put(
    ThreatResponse(
      env: env,
      warn: (reason) => CommonUtils.showToast(reason, isError: true),
      block: (_) => blockDevice(),
    ),
    permanent: true,
  );
  await SecurityService.start(onThreatDetected: response.onThreat);

  runApp(const App());
}
