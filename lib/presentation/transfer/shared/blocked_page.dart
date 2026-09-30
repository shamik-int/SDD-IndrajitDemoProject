import 'package:flutter/material.dart';

/// PROD response to a detected rooted/jailbroken/hooked device (PD-08).
class BlockedPage extends StatelessWidget {
  const BlockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'This device is not supported: a security risk was detected. The app cannot be used on it.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
