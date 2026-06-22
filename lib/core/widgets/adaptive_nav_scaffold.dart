import 'package:flutter/material.dart';

import '../utils/responsive.dart';

/// One destination in the adaptive navigation, expressed once and rendered as
/// either a [NavigationRailDestination] (rail) or a [NavigationDestination]
/// (bottom bar) depending on form factor.
@immutable
class AdaptiveDestination {
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// App shell that adapts its primary navigation to the window size:
///
/// - **compact** (< 600): a bottom [NavigationBar].
/// - **medium** (600–839): a [NavigationRail] with selected-only labels.
/// - **expanded** (>= 840): a [NavigationRail] with all labels shown.
///
/// It owns only the chrome (app bar + nav); [body] is the routed content
/// (typically a `StatefulNavigationShell`). App-specific app-bar widgets — the
/// user/email menu, sign-out — are passed in via [title] and [actions], so this
/// stays app-agnostic and lives in the shared package.
class AdaptiveNavScaffold extends StatelessWidget {
  const AdaptiveNavScaffold({
    super.key,
    required this.title,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.actions = const [],
    this.leading,
  });

  final String title;
  final List<AdaptiveDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final List<Widget> actions;

  /// Optional app-bar leading — typically the DCPL [BrandMark]. Sized to the
  /// AppBar's default leading width.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;

    return Scaffold(
      appBar: AppBar(leading: leading, title: Text(title), actions: actions),
      body: compact
          ? body
          : Row(
              children: [
                _rail(context),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
      bottomNavigationBar: compact
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: [
                for (final d in destinations)
                  NavigationDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: d.label,
                  ),
              ],
            )
          : null,
    );
  }

  Widget _rail(BuildContext context) => NavigationRail(
    selectedIndex: selectedIndex,
    onDestinationSelected: onDestinationSelected,
    labelType: context.isExpanded
        ? NavigationRailLabelType.all
        : NavigationRailLabelType.selected,
    destinations: [
      for (final d in destinations)
        NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: Text(d.label),
        ),
    ],
  );
}
