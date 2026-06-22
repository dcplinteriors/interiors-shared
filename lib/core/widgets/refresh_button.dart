import 'package:flutter/material.dart';

/// A Gmail-style in-place refresh control for list headers: tap to re-fetch the
/// current data without a full page reload. While [isRefreshing] is true the
/// icon is replaced by a small spinner and the button is disabled, so repeated
/// taps can't stack requests.
///
/// App-agnostic: the [tooltip] is passed in (localized by the caller), so this
/// stays in the shared package.
class RefreshButton extends StatelessWidget {
  const RefreshButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    this.isRefreshing = false,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: tooltip,
    onPressed: isRefreshing ? null : onPressed,
    icon: isRefreshing
        ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.refresh),
  );
}
