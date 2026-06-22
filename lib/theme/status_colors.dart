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

  static StatusColor lerp(StatusColor a, StatusColor b, double t) =>
      StatusColor(
        Color.lerp(a.surface, b.surface, t) ?? a.surface,
        Color.lerp(a.ink, b.ink, t) ?? a.ink,
      );
}

/// Semantic status palette, attached to [ThemeData] as a [ThemeExtension].
///
/// This is the single source of truth for the colours of workflow states —
/// material-request statuses, work-order / project statuses, assignment state.
/// Both apps read it via [BuildContext.statusColors] so a chip means the same
/// thing everywhere. It deliberately holds **colours only**: which icon and
/// which localized label go with a status is an app/l10n concern and stays in
/// each app's chip widget.
///
/// The 8 material-request statuses each get a named slot (so their colours can
/// be tuned independently), even where the initial colour is shared with a
/// sibling — `accepted`/`closed` are positive (green), `declined`/`returned`
/// are negative (red), `cancelled`/`superseded` are dormant (grey).
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.requested,
    required this.processing,
    required this.accepted,
    required this.closed,
    required this.returned,
    required this.declined,
    required this.cancelled,
    required this.superseded,
    required this.active,
    required this.completed,
    required this.warning,
    required this.neutral,
  });

  // Material-request statuses.
  final StatusColor requested;
  final StatusColor processing;
  final StatusColor accepted;
  final StatusColor closed;
  final StatusColor returned;
  final StatusColor declined;
  final StatusColor cancelled;
  final StatusColor superseded;

  // Work-order / project statuses + generic signals.
  final StatusColor active;
  final StatusColor completed;
  final StatusColor warning;
  final StatusColor neutral;

  /// The light-theme defaults, derived from [AppPalette].
  static const standard = StatusColors(
    requested: StatusColor(AppPalette.infoSurface, AppPalette.infoInk),
    processing: StatusColor(AppPalette.amberSurface, AppPalette.amberInk),
    accepted: StatusColor(AppPalette.greenSurface, AppPalette.greenInk),
    closed: StatusColor(AppPalette.greenSurface, AppPalette.greenInk),
    returned: StatusColor(AppPalette.redSurface, AppPalette.redInk),
    declined: StatusColor(AppPalette.redSurface, AppPalette.redInk),
    cancelled: StatusColor(AppPalette.greySurface, AppPalette.greyInk),
    superseded: StatusColor(AppPalette.greySurface, AppPalette.greyInk),
    active: StatusColor(AppPalette.infoSurface, AppPalette.infoInk),
    completed: StatusColor(AppPalette.greenSurface, AppPalette.greenInk),
    warning: StatusColor(AppPalette.amberSurface, AppPalette.amberInk),
    neutral: StatusColor(AppPalette.greySurface, AppPalette.greyInk),
  );

  /// Dark-theme variant: deep hue-tinted fills with bright ink, so chips read on
  /// dark surfaces and the status rail (which paints with `ink`) stays vivid.
  static const dark = StatusColors(
    requested: StatusColor(Color(0xFF0E353D), Color(0xFF7FDDEC)),
    processing: StatusColor(Color(0xFF45330F), Color(0xFFF2C277)),
    accepted: StatusColor(Color(0xFF143A28), Color(0xFF7FE0A6)),
    closed: StatusColor(Color(0xFF143A28), Color(0xFF7FE0A6)),
    returned: StatusColor(Color(0xFF4A1A15), Color(0xFFF4A79E)),
    declined: StatusColor(Color(0xFF4A1A15), Color(0xFFF4A79E)),
    cancelled: StatusColor(Color(0xFF2A3037), Color(0xFFB4BDC6)),
    superseded: StatusColor(Color(0xFF2A3037), Color(0xFFB4BDC6)),
    active: StatusColor(Color(0xFF0E353D), Color(0xFF7FDDEC)),
    completed: StatusColor(Color(0xFF143A28), Color(0xFF7FE0A6)),
    warning: StatusColor(Color(0xFF45330F), Color(0xFFF2C277)),
    neutral: StatusColor(Color(0xFF2A3037), Color(0xFFB4BDC6)),
  );

  /// Resolve a material-request status string (its wire value) to its colours.
  /// Unknown values fall back to [neutral]. Pure colour logic — no l10n.
  StatusColor forRequest(String status) => switch (status) {
    'requested' => requested,
    'processing' => processing,
    'accepted' => accepted,
    'closed' => closed,
    'returned' => returned,
    'declined' => declined,
    'cancelled' => cancelled,
    'superseded' => superseded,
    _ => neutral,
  };

  /// Resolve a work-order status string to its colours (pending reads as "needs a supervisor").
  StatusColor forWorkOrder(String status) => switch (status) {
    'pending' => warning,
    'active' => active,
    'completed' => completed,
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
    StatusColor? processing,
    StatusColor? accepted,
    StatusColor? closed,
    StatusColor? returned,
    StatusColor? declined,
    StatusColor? cancelled,
    StatusColor? superseded,
    StatusColor? active,
    StatusColor? completed,
    StatusColor? warning,
    StatusColor? neutral,
  }) => StatusColors(
    requested: requested ?? this.requested,
    processing: processing ?? this.processing,
    accepted: accepted ?? this.accepted,
    closed: closed ?? this.closed,
    returned: returned ?? this.returned,
    declined: declined ?? this.declined,
    cancelled: cancelled ?? this.cancelled,
    superseded: superseded ?? this.superseded,
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
      processing: StatusColor.lerp(processing, other.processing, t),
      accepted: StatusColor.lerp(accepted, other.accepted, t),
      closed: StatusColor.lerp(closed, other.closed, t),
      returned: StatusColor.lerp(returned, other.returned, t),
      declined: StatusColor.lerp(declined, other.declined, t),
      cancelled: StatusColor.lerp(cancelled, other.cancelled, t),
      superseded: StatusColor.lerp(superseded, other.superseded, t),
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
