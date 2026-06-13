import 'package:flutter/material.dart';

/// Centered error placeholder with a Retry action. Shared by the feature list screens;
/// each passes its own [title] (e.g. "Couldn't load projects") and the API [message].
/// [retryLabel] defaults to "Retry"; apps can pass a localized label.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  final String title;
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: scheme.error),
          const SizedBox(height: 16),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: scheme.onSurfaceVariant)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
