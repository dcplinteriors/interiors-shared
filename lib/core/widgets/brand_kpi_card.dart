import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../theme/brand_gradient.dart';

/// A dashboard stat tile.
///
/// The [featured] variant is a screen's single "molten moment": a graphite
/// surface with a gradient glow — reserve it for the one headline metric (open
/// requests, on-time %). Every other tile is a calm outlined card so the
/// featured one draws the eye. Keep at most one featured tile per dashboard.
class BrandKpiCard extends StatelessWidget {
  const BrandKpiCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.featured = false,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData? icon;
  final bool featured;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final radius = BorderRadius.circular(14);

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: featured ? Colors.white : cs.tertiary),
            const SizedBox(height: 10),
          ],
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: featured ? Colors.white : cs.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: featured ? Colors.white70 : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Material(
      // Featured tiles always sit on graphite (steel 800) so the molten glow
      // reads in BOTH light and dark; plain tiles on the lowest surface + hairline.
      color: featured ? AppPalette.steel.shade800 : cs.surfaceContainerLowest,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      shape: featured
          ? RoundedRectangleBorder(borderRadius: radius)
          : RoundedRectangleBorder(
              borderRadius: radius,
              side: BorderSide(color: cs.outlineVariant),
            ),
      child: InkWell(
        onTap: onTap,
        child: featured
            ? Stack(
                children: [
                  // The molten glow — a gradient orb bleeding from the corner.
                  Positioned(
                    right: -30,
                    top: -30,
                    child: Container(
                      width: 116,
                      height: 116,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: BrandGradient.diagonal,
                      ),
                    ),
                  ),
                  content,
                ],
              )
            : content,
      ),
    );
  }
}
