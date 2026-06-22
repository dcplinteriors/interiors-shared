import 'package:flutter/material.dart';

const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

/// A column in a [DcplTable]. [flex] sizes proportional columns; [fixedWidth]
/// pins a column (use for short/numeric columns); [numeric] right-aligns the
/// header and cells and renders figures with tabular spacing.
@immutable
class DcplColumn {
  const DcplColumn(
    this.label, {
    this.flex = 1,
    this.numeric = false,
    this.fixedWidth,
  });

  final String label;
  final int flex;
  final bool numeric;
  final double? fixedWidth;
}

/// One row. [cells] has exactly one widget per [DcplColumn] (in order).
/// [railColor] paints the left status rail; [actions] are revealed on hover in
/// the trailing column; [onTap] makes the whole row tappable (a chevron shows).
@immutable
class DcplRow {
  const DcplRow({
    required this.cells,
    this.railColor,
    this.onTap,
    this.actions = const [],
    this.selected = false,
  });

  final List<Widget> cells;
  final Color? railColor;
  final VoidCallback? onTap;
  final List<Widget> actions;
  final bool selected;
}

/// The DCPL "Ledger" table — a calm, scannable list with a left status rail,
/// a tracked sticky header, hover-revealed row actions and an optional compact
/// density. Used on wide layouts (phones use `EntityCard`). Place inside a
/// height-bounded parent (e.g. `Expanded`): the header is fixed and rows scroll
/// beneath it. When [trailing] is true a fixed trailing column holds the
/// hover actions + a chevron for tappable rows.
class DcplTable extends StatelessWidget {
  const DcplTable({
    super.key,
    required this.columns,
    required this.rows,
    this.trailing = false,
    this.dense = false,
    this.footer,
  });

  final List<DcplColumn> columns;
  final List<DcplRow> rows;
  final bool trailing;
  final bool dense;
  final Widget? footer;

  static const double _gap = 16;
  static const double _trailingW = 100;
  static const double _hPad = 20;
  // Below this total, the table scrolls horizontally rather than crushing
  // columns. Each flex column is guaranteed at least this much.
  static const double _minFlexWidth = 128;

  double get _minWidth {
    var w = _hPad + (trailing ? 12 : _hPad) + (trailing ? _trailingW : 0);
    for (var i = 0; i < columns.length; i++) {
      if (i > 0) w += _gap;
      w += columns[i].fixedWidth ?? _minFlexWidth;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final header = Container(
      padding: EdgeInsets.fromLTRB(_hPad, 13, trailing ? 12 : _hPad, 13),
      decoration: BoxDecoration(
        // A distinctly darker band than the white table body and the page
        // surface, so the header reads as a header.
        color: cs.surfaceContainerHigh,
        border: Border(
          bottom: BorderSide(color: cs.outlineVariant, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: _gap),
            _sized(
              columns[i],
              Text(
                columns[i].label.toUpperCase(),
                textAlign: columns[i].numeric
                    ? TextAlign.right
                    : TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (trailing) const SizedBox(width: _trailingW),
        ],
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        // A tight, contained shadow (negative spread so it doesn't bleed wide
        // under a large table) — the hairline border carries most of the edge.
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F141B20),
            blurRadius: 12,
            offset: Offset(0, 3),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Fill the available width when it's enough; otherwise grow to the
            // minimum and let the table scroll horizontally (columns stay
            // readable instead of crushing).
            final width = constraints.maxWidth >= _minWidth
                ? constraints.maxWidth
                : _minWidth;

            final table = SizedBox(
              width: width,
              child: Column(
                children: [
                  header,
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: rows.length,
                      itemBuilder: (_, i) => _TableRow(
                        row: rows[i],
                        columns: columns,
                        trailing: trailing,
                        dense: dense,
                        isLast: i == rows.length - 1,
                      ),
                    ),
                  ),
                  if (footer != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                      child: footer,
                    ),
                ],
              ),
            );

            if (width <= constraints.maxWidth) return table;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: table,
            );
          },
        ),
      ),
    );
  }

  // Wrap a header/body child in either a fixed-width box or a flex Expanded so
  // header and body columns line up exactly.
  static Widget _sized(DcplColumn c, Widget child) => c.fixedWidth != null
      ? SizedBox(width: c.fixedWidth, child: child)
      : Expanded(flex: c.flex, child: child);
}

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.row,
    required this.columns,
    required this.trailing,
    required this.dense,
    required this.isLast,
  });

  final DcplRow row;
  final List<DcplColumn> columns;
  final bool trailing;
  final bool dense;
  final bool isLast;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final r = widget.row;
    final vpad = widget.dense ? 9.0 : 14.0;

    final bg = r.selected
        ? cs.tertiaryContainer.withValues(alpha: 0.55)
        : _hover
        ? cs.surfaceContainerLow
        : Colors.transparent;
    final rail = r.selected ? cs.tertiary : (r.railColor ?? Colors.transparent);

    Widget cell(int i) {
      final c = widget.columns[i];
      return DcplTable._sized(
        c,
        DefaultTextStyle.merge(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: c.numeric ? TextAlign.right : TextAlign.left,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontFeatures: c.numeric ? _tabular : null,
          ),
          child: Align(
            alignment: c.numeric ? Alignment.centerRight : Alignment.centerLeft,
            child: r.cells[i],
          ),
        ),
      );
    }

    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        DcplTable._hPad,
        vpad,
        widget.trailing ? 12 : DcplTable._hPad,
        vpad,
      ),
      child: Row(
        children: [
          for (var i = 0; i < widget.columns.length; i++) ...[
            if (i > 0) const SizedBox(width: DcplTable._gap),
            cell(i),
          ],
          if (widget.trailing)
            SizedBox(
              width: DcplTable._trailingW,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (r.actions.isNotEmpty)
                    AnimatedOpacity(
                      opacity: _hover ? 1 : 0,
                      duration: const Duration(milliseconds: 120),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: r.actions,
                      ),
                    ),
                  if (r.onTap != null)
                    Icon(
                      Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),
            ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Material(
        color: bg,
        child: InkWell(
          onTap: r.onTap,
          child: Stack(
            children: [
              content,
              Positioned(
                left: 0,
                top: 7,
                bottom: 7,
                child: Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: rail,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              if (!widget.isLast)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A shimmering skeleton placeholder for table/list loading — a row of muted
/// bars. Drop several in a column inside a `DcplTable`-styled card while data
/// loads, instead of a bare spinner.
class SkeletonRow extends StatefulWidget {
  const SkeletonRow({super.key, this.widthFraction = 0.6});

  final double widthFraction;

  @override
  State<SkeletonRow> createState() => _SkeletonRowState();
}

class _SkeletonRowState extends State<SkeletonRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final base = cs.surfaceContainerHigh;
          final hi = cs.surfaceContainerLow;
          final shimmer = Color.lerp(base, hi, _c.value) ?? base;
          Widget bar(double w, double h) => Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              color: shimmer,
              borderRadius: BorderRadius.circular(6),
            ),
          );
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    bar(
                      MediaQuery.sizeOf(context).width *
                              0.18 *
                              widget.widthFraction +
                          80,
                      12,
                    ),
                    const SizedBox(height: 8),
                    bar(90, 9),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: bar(double.infinity, 12)),
              const SizedBox(width: 16),
              SizedBox(width: 70, child: bar(60, 12)),
            ],
          );
        },
      ),
    );
  }
}
