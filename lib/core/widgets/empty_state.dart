import 'package:flutter/material.dart';

/// Centered placeholder for an empty list — icon + title + body, with an optional
/// call-to-action below. Shared by the feature list screens.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Optional CTA (e.g. a "New ..." button). Omitted on read-only screens.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(body, style: TextStyle(color: scheme.onSurfaceVariant)),
          if (action != null) ...[
            const SizedBox(height: 16),
            action!,
          ],
        ],
      ),
    );
  }
}
