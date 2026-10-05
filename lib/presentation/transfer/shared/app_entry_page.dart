import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/security/threat_response.dart';

import 'app_entry_controller.dart';

/// Decides, once, where the app opens (PD-07), then clears the stack.
class AppEntryPage extends StatefulWidget {
  const AppEntryPage({super.key});

  @override
  State<AppEntryPage> createState() => _AppEntryPageState();
}

class _AppEntryPageState extends State<AppEntryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    final route = await Get.find<AppEntryController>().resolveInitialRoute();
    Get.offAllNamed(route);
    // Only now can a threat response navigate without being overridden by
    // this routing decision (G2-08). Absent in tests that do not set one up.
    if (Get.isRegistered<ThreatResponse>()) Get.find<ThreatResponse>().markReady();
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
