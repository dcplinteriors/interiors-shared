import 'package:flutter/material.dart';

/// One label/value field inside an [EntityCard]. Supply either [text] (rendered
/// as muted-or-plain body text) or a custom [child] (a chip, button, etc.).
@immutable
class EntityField {
  const EntityField(this.label, {this.text, this.child, this.muted = false})
    : assert(text != null || child != null, 'EntityField needs text or child');

  final String label;
  final String? text;
  final Widget? child;
  final bool muted;
}

/// The compact-layout counterpart to a [DcplTable] row: a tappable card with the
/// same DNA — a left **status rail** (when [railColor] is given), an optional
/// [eyebrow], a Sora title + trailing chip, a two-column stacked field grid, and
/// an optional footer action. Used on phones where tables don't fit; wide
/// layouts use the table. Lives in the shared package so every list screen in
/// both apps renders cards identically.
class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.title,
    this.eyebrow,
    this.railColor,
    this.trailing,
    this.fields = const [],
    this.footer,
    this.onTap,
  });

  final String title;
  final String? eyebrow;
  final Color? railColor;
  final Widget? trailing;
  final List<EntityField> fields;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final muted = cs.onSurfaceVariant;

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null) ...[
                      Text(
                        eyebrow!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(title, style: theme.textTheme.titleMedium),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
          if (fields.isNotEmpty) ...[
            const SizedBox(height: 16),
            _FieldGrid(fields: fields, muted: muted, theme: theme),
          ],
          if (footer != null) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            footer!,
          ],
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: railColor == null
            ? content
            : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 3, color: railColor),
                    Expanded(child: content),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Lays the fields as stacked label-over-value blocks in a two-column grid (a
/// single full-width column when there's only one field). Each block: a tracked
/// uppercase label above its value.
class _FieldGrid extends StatelessWidget {
  const _FieldGrid({
    required this.fields,
    required this.muted,
    required this.theme,
  });

  final List<EntityField> fields;
  final Color muted;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < fields.length; i += 2) {
      final hasRight = i + 1 < fields.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(top: i == 0 ? 0 : 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _block(fields[i])),
              const SizedBox(width: 18),
              Expanded(
                child: hasRight ? _block(fields[i + 1]) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  Widget _block(EntityField f) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        f.label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: muted,
        ),
      ),
      const SizedBox(height: 3),
      DefaultTextStyle.merge(
        style: theme.textTheme.bodyMedium ?? const TextStyle(),
        child:
            f.child ??
            Text(f.text!, style: f.muted ? TextStyle(color: muted) : null),
      ),
    ],
  );
}
