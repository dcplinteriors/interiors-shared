import 'package:flutter/material.dart';

import '../utils/responsive.dart';
import '../../theme/brand_gradient.dart';

/// Shared easing for nav selection/hover state changes (pill, icon, label, edge).
const Duration _kNavAnim = Duration(milliseconds: 180);
const Curve _kNavCurve = Curves.easeOut;

/// One primary navigation destination in the "Molten" shell. Expressed once and
/// rendered as a rail item (desktop) or a floating bottom-bar item (mobile).
///
/// [section] groups consecutive items under a header in the rail (e.g. "Workspace"
/// then "Inbox"); the bottom bar ignores it. [badgeCount] (> 0) shows a count
/// badge — used on the admin's Requests tab.
@immutable
class DcplNavItem {
  const DcplNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.section,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String? section;
  final int badgeCount;
}

/// The DCPL "Molten" app shell. Adapts its primary navigation to the window size:
///
/// - **compact** (< 600): a minimal app bar ([appBarTitle] + [appBarActions]) over
///   the body, with a **floating bottom bar**.
/// - **medium / expanded** (>= 600): a 236px **labeled rail** (with [railHeader] at
///   the top and an optional pinned [railFooter], e.g. an account row) beside the body.
///
/// Holds only the chrome; [body] is the routed content. App-specific bits (brand
/// lock-up, account row / avatar) are passed in, so this stays app-agnostic.
class DcplNavScaffold extends StatelessWidget {
  const DcplNavScaffold({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    this.railHeader,
    this.railFooter,
    this.appBarTitle,
    this.appBarActions = const [],
  });

  final List<DcplNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;

  /// Brand lock-up shown at the top of the rail (desktop).
  final Widget? railHeader;

  /// Optional widget pinned at the bottom of the rail — typically an account row.
  final Widget? railFooter;

  /// Brand lock-up shown in the mobile app bar.
  final Widget? appBarTitle;

  /// Mobile app-bar actions (e.g. the admin account avatar).
  final List<Widget> appBarActions;

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return Scaffold(
        appBar: (appBarTitle != null || appBarActions.isNotEmpty)
            ? AppBar(
                titleSpacing: 18,
                title: appBarTitle,
                actions: appBarActions,
              )
            : null,
        body: body,
        bottomNavigationBar: DcplBottomBar(
          items: items,
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
        ),
      );
    }
    return Scaffold(
      body: Row(
        children: [
          DcplNavRail(
            items: items,
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            header: railHeader,
            footer: railFooter,
          ),
          VerticalDivider(
            width: 1,
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// The 236px labeled rail: brand header, section-grouped destinations with a
/// tinted-pill + molten gradient-edge selected state and neutral hover, and an
/// optional pinned footer (account row).
class DcplNavRail extends StatelessWidget {
  const DcplNavRail({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.header,
    this.footer,
  });

  final List<DcplNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
              child: header,
            ),
          const _RailDivider(),
          ..._destinations(),
          const Spacer(),
          if (footer != null) ...[
            const _RailDivider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }

  /// Interleaves a [_SectionHeader] before the first item of each new section
  /// with the [_RailItem] destinations themselves.
  List<Widget> _destinations() {
    final out = <Widget>[];
    String? lastSection;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.section != null && item.section != lastSection) {
        out.add(
          _SectionHeader(title: item.section!, first: lastSection == null),
        );
        lastSection = item.section;
      }
      out.add(
        _RailItem(
          item: item,
          selected: i == selectedIndex,
          onTap: () => onDestinationSelected(i),
        ),
      );
    }
    return out;
  }
}

/// A hairline rule separating the rail's header / destinations / footer.
class _RailDivider extends StatelessWidget {
  const _RailDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 1,
    margin: const EdgeInsets.fromLTRB(6, 16, 6, 16),
    color: Theme.of(context).colorScheme.outlineVariant,
  );
}

/// An uppercase group label above the first destination of a section. [first]
/// tightens the top gap for the leading section.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.first});

  final String title;
  final bool first;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(28, first ? 2 : 20, 14, 8),
    child: Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.3,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );
}

class _RailItem extends StatefulWidget {
  const _RailItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DcplNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final selected = widget.selected;
    final iconColor = selected
        ? scheme.tertiary
        : (_hover ? scheme.onSurface : scheme.onSurfaceVariant);
    final labelColor = selected || _hover
        ? scheme.onSurface
        : scheme.onSurface.withValues(alpha: 0.80);
    final fill = selected
        ? scheme.tertiary.withValues(alpha: 0.14)
        : (_hover ? scheme.surfaceContainerHigh : Colors.transparent);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 47, // 44 item + 3 gap
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 3),
                child: AnimatedContainer(
                  duration: _kNavAnim,
                  curve: _kNavCurve,
                  // Fill the item box (47 slot − 3 gap) so the selected/hover
                  // pill matches the box height instead of shrink-wrapping the row.
                  height: 44,
                  decoration: BoxDecoration(
                    color: fill,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      TweenAnimationBuilder<Color?>(
                        duration: _kNavAnim,
                        curve: _kNavCurve,
                        tween: ColorTween(end: iconColor),
                        builder: (context, color, _) => Icon(
                          selected
                              ? widget.item.selectedIcon
                              : widget.item.icon,
                          size: 20,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: AnimatedDefaultTextStyle(
                          duration: _kNavAnim,
                          curve: _kNavCurve,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: labelColor,
                          ),
                          child: Text(
                            widget.item.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      if (widget.item.badgeCount > 0)
                        _CountBadge(count: widget.item.badgeCount),
                    ],
                  ),
                ),
              ),
              // Molten gradient edge bar at the rail's left edge — scales in
              // from the edge when selected, out when not.
              Positioned(
                left: 0,
                top: 7,
                bottom: 10,
                child: AnimatedScale(
                  duration: _kNavAnim,
                  curve: _kNavCurve,
                  scale: selected ? 1 : 0,
                  alignment: Alignment.centerLeft,
                  child: const _GradientEdge(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientEdge extends StatelessWidget {
  const _GradientEdge();

  @override
  Widget build(BuildContext context) => Container(
    width: 4,
    decoration: const BoxDecoration(
      gradient: BrandGradient.diagonal,
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(4),
        bottomRight: Radius.circular(4),
      ),
    ),
  );
}

/// The pill count badge used in the rail (right-aligned on the item).
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// The floating bottom bar (mobile): a rounded card with tinted-pill active items.
class DcplBottomBar extends StatelessWidget {
  const DcplBottomBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<DcplNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: scheme.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 34,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              Expanded(
                child: _BottomItem(
                  item: items[i],
                  selected: i == selectedIndex,
                  onTap: () => onDestinationSelected(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  const _BottomItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DcplNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconColor = selected ? scheme.tertiary : scheme.onSurfaceVariant;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _kNavAnim,
        curve: _kNavCurve,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        decoration: BoxDecoration(
          color: selected
              ? scheme.tertiary.withValues(alpha: 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<Color?>(
              duration: _kNavAnim,
              curve: _kNavCurve,
              tween: ColorTween(end: iconColor),
              builder: (context, color, _) => _IconWithBadge(
                icon: selected ? item.selectedIcon : item.icon,
                color: color ?? iconColor,
                count: item.badgeCount,
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: _kNavAnim,
              curve: _kNavCurve,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  const _IconWithBadge({
    required this.icon,
    required this.color,
    required this.count,
  });

  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final iconWidget = Icon(icon, size: 22, color: color);
    if (count <= 0) return iconWidget;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          top: -6,
          right: -10,
          child: Container(
            constraints: const BoxConstraints(minWidth: 17),
            height: 17,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.tertiary,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: scheme.surfaceContainerLowest,
                width: 2,
              ),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
