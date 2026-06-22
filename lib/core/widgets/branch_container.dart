import 'package:flutter/material.dart';

/// A state-preserving, cross-fading container for the shell's navigation
/// branches. Drop-in for go_router's `StatefulShellRoute.navigatorContainerBuilder`
/// (pass `navigationShell.currentIndex` and the branch `children`).
///
/// Every branch stays mounted so each tab keeps its scroll/route state; the
/// inactive ones are made inert (no hit-testing, tickers paused) and faded out,
/// so switching tabs cross-fades instead of hard-cutting.
class FadeThroughBranchContainer extends StatelessWidget {
  const FadeThroughBranchContainer({
    super.key,
    required this.currentIndex,
    required this.children,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (var i = 0; i < children.length; i++)
        _Branch(active: i == currentIndex, child: children[i]),
    ],
  );
}

/// One branch in [FadeThroughBranchContainer]: faded + made inert when inactive.
class _Branch extends StatelessWidget {
  const _Branch({required this.active, required this.child});

  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: active ? 1 : 0,
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    child: IgnorePointer(
      ignoring: !active,
      child: TickerMode(enabled: active, child: child),
    ),
  );
}
