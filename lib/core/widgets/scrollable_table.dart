import 'package:flutter/material.dart';

/// Wraps a wide/tall table (e.g. a [DataTable]) so it fills the available
/// [width]×[height] and scrolls in both directions. The horizontal scroll is the outer
/// one so it fills the full height and its always-visible scrollbar sits at the very
/// bottom; rows scroll vertically inside. On web/desktop a bare horizontal scroll view
/// has no scrollbar and the mouse wheel only scrolls vertically, so a wide table would
/// otherwise look clipped. [width] doubles as the minimum table width — the child fills
/// the viewport on wide screens and scrolls when space is tight.
///
/// Pair with a [LayoutBuilder] to supply the constraints:
/// ```dart
/// LayoutBuilder(
///   builder: (_, c) => ScrollableTable(width: c.maxWidth, height: c.maxHeight, child: table),
/// )
/// ```
class ScrollableTable extends StatefulWidget {
  const ScrollableTable({
    super.key,
    required this.child,
    required this.width,
    required this.height,
  });

  final Widget child;
  final double width;
  final double height;

  @override
  State<ScrollableTable> createState() => _ScrollableTableState();
}

class _ScrollableTableState extends State<ScrollableTable> {
  final _horizontal = ScrollController();
  final _vertical = ScrollController();

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.width,
        height: widget.height,
        child: Scrollbar(
          controller: _horizontal,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _horizontal,
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              controller: _vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: widget.width),
                child: widget.child,
              ),
            ),
          ),
        ),
      );
}
