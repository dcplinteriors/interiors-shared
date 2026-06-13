import 'package:flutter/widgets.dart';

/// Material 3 window-size classes, the single source of truth for adaptive
/// layout across both apps.
///
/// - [compact]  : phones / very narrow windows (< 600). One column; bottom nav;
///                tables collapse to cards.
/// - [medium]   : large phones landscape / small tablets (600–839). Navigation
///                rail; tables fit.
/// - [expanded] : tablets / desktop / web (>= 840). Rail with labels; roomy.
enum FormFactor { compact, medium, expanded }

/// Breakpoint edges (logical pixels). Kept here so a tweak is one-line and
/// global.
abstract final class Breakpoints {
  static const double medium = 600;
  static const double expanded = 840;

  static FormFactor of(double width) {
    if (width < medium) return FormFactor.compact;
    if (width < expanded) return FormFactor.medium;
    return FormFactor.expanded;
  }
}

/// Ergonomic form-factor access off the build context. Reads the current
/// window width via [MediaQuery] (rebuilds on resize / rotation).
extension ResponsiveX on BuildContext {
  FormFactor get formFactor =>
      Breakpoints.of(MediaQuery.sizeOf(this).width);

  /// Phone-sized: use cards, bottom nav, tighter spacing.
  bool get isCompact => formFactor == FormFactor.compact;

  /// Tablet-and-up: rail + tables are fine.
  bool get isMedium => formFactor == FormFactor.medium;

  /// Desktop/web: roomy rail with labels.
  bool get isExpanded => formFactor == FormFactor.expanded;

  /// Standard page padding that scales with the form factor.
  EdgeInsets get pagePadding => switch (formFactor) {
        FormFactor.compact => const EdgeInsets.all(16),
        FormFactor.medium => const EdgeInsets.all(20),
        FormFactor.expanded => const EdgeInsets.all(24),
      };
}
