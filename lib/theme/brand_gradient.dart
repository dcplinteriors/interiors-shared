import 'package:flutter/widgets.dart';

import 'app_palette.dart';

/// The DCPL **Molten** brand gradient — lifted straight from the new logo.
///
/// One continuous "heat curve": saffron → ember → crimson → magenta, the colours
/// metal glows through as it's worked. This is the brand's *signature*, used
/// sparingly (one molten moment per screen): the primary action, the logo, one
/// hero KPI, the splash. For flat fills that a gradient can't serve (icons, 1px
/// strokes, small chips) use the solid stand-in [AppPalette.crimson].
///
/// Screens should prefer the helpers here (or the brand widgets that consume
/// them) over re-declaring stops, so the heat stays identical everywhere.
abstract final class BrandGradient {
  /// Canonical stops, in order. Mirrors the logo wordmark left→right.
  static const List<Color> stops = [
    AppPalette.saffron, // 0.00
    AppPalette.ember, //   0.30
    AppPalette.crimson, // 0.62  (swatch value == 500, the brand solid)
    AppPalette.magenta, // 1.00
  ];

  static const List<double> _stops = [0.0, 0.30, 0.62, 1.0];

  /// The default ~100° sweep (logo-like: mostly horizontal, a touch downward).
  /// Use for bars, buttons, splash washes.
  static const LinearGradient horizontal = LinearGradient(
    begin: Alignment(-1.0, -0.2),
    end: Alignment(1.0, 0.2),
    colors: stops,
    stops: _stops,
  );

  /// A diagonal variant for large hero surfaces (login, splash cards).
  static const LinearGradient diagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: stops,
    stops: _stops,
  );

  /// Build a sweep at an arbitrary alignment pair when a one-off is needed.
  static LinearGradient custom({
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) => LinearGradient(begin: begin, end: end, colors: stops, stops: _stops);

  /// A faint molten wash for soft brand surfaces (selected nav tint, soft
  /// banners). Built from the ramp's lightest tints so ink stays legible on it.
  static const LinearGradient soft = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFFF1E2), Color(0xFFFFE6E9), Color(0xFFFBE2EF)],
  );
}
