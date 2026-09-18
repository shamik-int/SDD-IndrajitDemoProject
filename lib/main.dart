import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app.dart';
import 'core/local_db/local_db_service.dart';
import 'core/security/security_service.dart';
import 'core/utils/common_utils.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Environment selection — pass `--dart-define=ENV=prod` at build/run time
  // for the PROD flavor; defaults to UAT (ADR-0001 §3).
  const env = String.fromEnvironment('ENV', defaultValue: 'uat');
  await dotenv.load(
    fileName: env == 'prod' ? 'assets/env/.env.prod' : 'assets/env/.env.uat',
  );

  await LocalDbService.init();

  // Detection is mandatory (ADR-0002). The response below (a non-blocking
  // warn toast) is a scaffolding-time placeholder — block-vs-warn behaviour
  // for employee-internal-transfer is a Plan-stage decision, to be finalized
  // before this app is released.
  await SecurityService.start(
    onThreatDetected: (reason) => CommonUtils.showToast(reason, isError: true),
  );

  runApp(const App());
}
