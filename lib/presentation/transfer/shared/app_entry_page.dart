import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator()));
}
