import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/time/local_date.dart';
import '../../widgets/demo_banner.dart';
import '../shared/sign_out_action.dart';
import '../shared/transfer_labels.dart';
import 'my_requests_controller.dart';

class MyRequestsPage extends GetView<MyRequestsController> {
  const MyRequestsPage({super.key});

  Future<void> _open(String route, {Object? arguments}) async {
    await Get.toNamed(route, arguments: arguments);
    await controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My transfer requests'),
        automaticallyImplyLeading: false,
        actions: const [SignOutAction()],
      ),
      body: Column(
        children: [
          const DemoBanner(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('new-request-button'),
                icon: const Icon(Icons.add),
                label: const Text('New transfer request'),
                onPressed: () => _open(AppRoutes.newRequest),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.error.value != null) return Center(child: Text(controller.error.value!));
              if (controller.requests.isEmpty) {
                return const Center(child: Text('You have no transfer requests yet.'));
              }
              final today = controller.clock.today();
              return ListView(
                key: const Key('request-list'),
                children: [
                  for (final r in controller.requests)
                    ListTile(
                      key: Key('request-tile-${r.requestId}'),
                      title: Text(TransferLabels.summaryStatus(r, today)),
                      subtitle: Text(
                        'Submitted ${LocalDate.format(r.submittedAt)} · effective ${LocalDate.format(r.effectiveDate)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(AppRoutes.requestDetail, arguments: {'requestId': r.requestId}),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
