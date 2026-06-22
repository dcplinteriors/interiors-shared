import 'package:flutter/material.dart';

/// The two-line primary cell for a [DcplTable] (or the title of an [EntityCard]):
/// a Sora title with an optional muted context subline beneath. Lets a row carry
/// more meaning (material, item count, id) without widening the table.
class PrimaryCell extends StatelessWidget {
  const PrimaryCell(this.title, {super.key, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
    );
  }
}

/// An assignee shown as a calm graphite initials pellet + name. When [name] is
/// null/blank it renders the unassigned state — an outlined pellet with a person
/// glyph and the muted [fallback] label. Deliberately neutral (no gradient): the
/// brand heat stays reserved for primary actions.
class AssigneePellet extends StatelessWidget {
  const AssigneePellet({super.key, this.name, this.fallback = 'Unassigned'});

  final String? name;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final assigned = name != null && name!.trim().isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: assigned ? cs.surfaceContainerHigh : Colors.transparent,
            border: Border.all(
              color: cs.outlineVariant,
              width: assigned ? 1 : 1.4,
            ),
          ),
          child: assigned
              ? Text(
                  _initials(name!),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0,
                  ),
                )
              : Icon(Icons.person_outline, size: 14, color: cs.outline),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            assigned ? name! : fallback,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: assigned ? null : TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  static String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.take(2).toString().toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }
}
