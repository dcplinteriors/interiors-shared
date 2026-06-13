import 'package:flutter/material.dart';

import 'app_palette.dart';

/// A background/foreground pair for a soft "status" surface (chip, badge, pill).
///
/// [surface] is the muted fill; [ink] is the text/icon colour chosen to sit on
/// that fill with accessible contrast. Kept tiny and immutable so it can live in
/// a `const` [StatusColors] and lerp smoothly during theme transitions.
@immutable
class StatusColor {
  const StatusColor(this.surface, this.ink);

  final Color surface;
  final Color ink;

  static StatusColor lerp(StatusColor a, StatusColor b, double t) => StatusColor(
        Color.lerp(a.surface, b.surface, t) ?? a.surface,
        Color.lerp(a.ink, b.ink, t) ?? a.ink,
      );
}

/// Semantic status palette, attached to [ThemeData] as a [ThemeExtension].
///
/// This is the single source of truth for the colours of workflow states —
/// material-request statuses, project statuses, assignment state. Both apps
/// read it via [BuildContext.statusColors] so a chip means the same thing
/// everywhere. It deliberately holds **colours only**: which icon and which
/// localized label go with a status is an app/l10n concern and stays in each
/// app's chip widget.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.requested,
    required this.accepted,
    required this.declined,
    required this.cancelled,
    required this.active,
    required this.completed,
    required this.warning,
    required this.neutral,
  });

  final StatusColor requested;
  final StatusColor accepted;
  final StatusColor declined;
  final StatusColor cancelled;
  final StatusColor active;
  final StatusColor completed;
  final StatusColor warning;
  final StatusColor neutral;

  /// The light-theme defaults, derived from [AppPalette].
  static const standard = StatusColors(
    requested: StatusColor(AppPalette.infoSurface, AppPalette.infoInk),
    accepted: StatusColor(AppPalette.greenSurface, AppPalette.greenInk),
    declined: StatusColor(AppPalette.redSurface, AppPalette.redInk),
    cancelled: StatusColor(AppPalette.greySurface, AppPalette.greyInk),
    active: StatusColor(AppPalette.infoSurface, AppPalette.infoInk),
    completed: StatusColor(AppPalette.greenSurface, AppPalette.greenInk),
    warning: StatusColor(AppPalette.amberSurface, AppPalette.amberInk),
    neutral: StatusColor(AppPalette.greySurface, AppPalette.greyInk),
  );

  /// Resolve a material-request status string to its colours.
  /// Unknown values fall back to [neutral]. Pure colour logic — no l10n.
  StatusColor forRequest(String status) => switch (status) {
        'requested' => requested,
        'accepted' => accepted,
        'declined' => declined,
        'cancelled' => cancelled,
        _ => neutral,
      };

  /// Resolve a project status string to its colours.
  StatusColor forProject(String status) => switch (status) {
        'active' => active,
        'completed' => completed,
        _ => neutral,
      };

  @override
  StatusColors copyWith({
    StatusColor? requested,
    StatusColor? accepted,
    StatusColor? declined,
    StatusColor? cancelled,
    StatusColor? active,
    StatusColor? completed,
    StatusColor? warning,
    StatusColor? neutral,
  }) =>
      StatusColors(
        requested: requested ?? this.requested,
        accepted: accepted ?? this.accepted,
        declined: declined ?? this.declined,
        cancelled: cancelled ?? this.cancelled,
        active: active ?? this.active,
        completed: completed ?? this.completed,
        warning: warning ?? this.warning,
        neutral: neutral ?? this.neutral,
      );

  @override
  StatusColors lerp(covariant ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      requested: StatusColor.lerp(requested, other.requested, t),
      accepted: StatusColor.lerp(accepted, other.accepted, t),
      declined: StatusColor.lerp(declined, other.declined, t),
      cancelled: StatusColor.lerp(cancelled, other.cancelled, t),
      active: StatusColor.lerp(active, other.active, t),
      completed: StatusColor.lerp(completed, other.completed, t),
      warning: StatusColor.lerp(warning, other.warning, t),
      neutral: StatusColor.lerp(neutral, other.neutral, t),
    );
  }
}

/// Ergonomic access to the semantic status palette: `context.statusColors`.
extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.standard;
}
