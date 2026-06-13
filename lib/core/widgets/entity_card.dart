import 'package:flutter/material.dart';

/// One label/value line inside an [EntityCard]. Supply either [text] (rendered
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

/// The compact-layout counterpart to a `DataTable` row: a tappable card showing
/// a title, an optional trailing widget (usually a status chip), a column of
/// aligned label/value fields, and an optional footer (actions). Used on phones
/// where tables don't fit; tablet/desktop keep the table. Lives in the shared
/// package so every list screen in both apps renders cards the same way.
class EntityCard extends StatelessWidget {
  const EntityCard({
    super.key,
    required this.title,
    this.trailing,
    this.fields = const [],
    this.footer,
    this.onTap,
  });

  final String title;
  final Widget? trailing;
  final List<EntityField> fields;
  final Widget? footer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 8),
                    trailing!,
                  ],
                ],
              ),
              if (fields.isNotEmpty) const SizedBox(height: 12),
              for (final f in fields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 96,
                        child: Text(
                          f.label,
                          style: theme.textTheme.bodySmall?.copyWith(color: muted),
                        ),
                      ),
                      Expanded(
                        child: DefaultTextStyle.merge(
                          style: theme.textTheme.bodyMedium ?? const TextStyle(),
                          child: f.child ??
                              Text(
                                f.text!,
                                style: f.muted ? TextStyle(color: muted) : null,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (footer != null) ...[
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: footer!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
