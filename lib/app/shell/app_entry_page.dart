import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../presentation/controllers/app_entry_controller.dart';

/// Replaces the earlier static placeholder shell (Blueprint's "app-shell
/// scaffolding, not feature implementation" note) now that a real status
/// screen exists — decides, once, whether the app opens to the status
/// screen (an active request exists) or the submission screen (it doesn't).
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
    Get.offNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
