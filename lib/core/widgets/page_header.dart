import 'package:flutter/material.dart';

import '../../theme/brand_gradient.dart';

/// A small tracked uppercase context label — "WORKSPACE", "PROJECT". Gives a
/// screen a sense of place above its title. Built into [PageHeader]; also usable
/// standalone (e.g. on cards).
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: 1.6,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

/// The standard list-screen header: an [eyebrow] → a large Sora [title] (with an
/// optional inline [count]) → a short molten gradient rule, plus optional
/// trailing [actions] (e.g. a `GradientButton`) and an optional [stats] strip
/// beneath. Actions wrap below on narrow widths.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.eyebrow,
    this.count,
    this.actions = const [],
    this.stats,
  });

  final String title;
  final String? eyebrow;
  final String? count;
  final List<Widget> actions;
  final Widget? stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (eyebrow != null) ...[Eyebrow(eyebrow!), const SizedBox(height: 8)],
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(
              child: Text(
                title,
                style: theme.textTheme.displaySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 12),
              Text(
                count!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: 64,
          height: 3,
          decoration: const BoxDecoration(
            gradient: BrandGradient.horizontal,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: titleBlock),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: 16),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(spacing: 8, runSpacing: 8, children: actions),
              ),
            ],
          ],
        ),
        if (stats != null) ...[const SizedBox(height: 22), stats!],
      ],
    );
  }
}

/// A compact outlined stat for a header/dashboard strip: a big tabular value
/// over a muted label. For the one featured metric per screen, use
/// `BrandKpiCard(featured: true)` instead.
class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
