import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'app/routes/app_routes.dart';
import 'core/local_db/local_db_service.dart';
import 'core/security/security_service.dart';
import 'core/security/threat_response.dart';
import 'core/utils/common_utils.dart';
import 'data/transfer/portal/demo_data_seeder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment selection — pass `--dart-define=ENV=prod` at build/run time
  // for the PROD flavor; defaults to UAT (ADR-0001 §3).
  const env = String.fromEnvironment('ENV', defaultValue: 'uat');
  await dotenv.load(
    fileName: env == 'prod' ? 'assets/env/.env.prod' : 'assets/env/.env.uat',
  );

  await LocalDbService.init();
  // Plan PD-06: clear v1.5/BRD-002 demo data once and seed the demo accounts.
  await DemoDataSeeder(LocalDbService()).ensureSeeded();

  // Detection is mandatory (ADR-0002). Response per plan PD-08: warn in UAT,
  // block in PROD.
  final response = ThreatResponse(
    env: env,
    warn: (reason) => CommonUtils.showToast(reason, isError: true),
    block: (_) => Get.offAllNamed(AppRoutes.blocked),
  );
  await SecurityService.start(onThreatDetected: response.onThreat);

  runApp(const App());
}
