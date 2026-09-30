import 'package:flutter/material.dart';

import '../../core/constants/transfer_messages.dart';
import '../../core/theme/app_colors.dart';

/// "Demo — test data only" indicator (AC28, SD-12). Shown on the transfer
/// form, the request screens and the simulation screen so no one mistakes
/// V1 for a production system holding real employee records.
class DemoBanner extends StatelessWidget {
  const DemoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      key: const Key('demo-banner'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? AppColors.secondaryTintYellowDark : AppColors.secondaryTintYellowLight,
      child: Row(
        children: [
          const Icon(Icons.science_outlined, size: 16),
          const SizedBox(width: 8),
          Text(TransferMessages.demoIndicator, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
