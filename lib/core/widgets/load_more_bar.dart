import 'package:dcpl_shared/core/controllers/paginated_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The "Load more" footer for a paginated list: hidden when there's nothing more, a
/// spinner while the next page loads, otherwise an outlined button. Reads its state
/// reactively from any [PaginatedController].
class LoadMoreBar extends StatelessWidget {
  const LoadMoreBar({super.key, required this.controller, required this.label});

  final PaginatedController controller;

  /// Localized "Load more" label (l10n lives in the apps).
  final String label;

  @override
  Widget build(BuildContext context) => Obx(() {
    if (!controller.hasMore) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: controller.isLoadingMore.value
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : OutlinedButton.icon(
                onPressed: controller.loadMore,
                icon: const Icon(Icons.expand_more),
                label: Text(label),
              ),
      ),
    );
  });
}
