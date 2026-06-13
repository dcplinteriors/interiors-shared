import 'package:flutter/painting.dart' show Color;

/// Raw brand colours for DCPL — "Steel & Timber".
///
/// Mirrors the company's real identity (dcplmetal.in): a near-monochrome,
/// industrial-premium look — charcoal/graphite on off-white, with raw metal as
/// the only accent. Two ramps carry the brand: **steel** (the graphite/blue-grey
/// spine) and **brass** (the warm metal accent). The functional colours are
/// fixed semantic signals (success/danger/warning/neutral/info) that must read
/// the same in both apps regardless of the generated Material scheme.
///
/// Consumed by [AppTheme] (to build the [ColorScheme]) and by `StatusColors`.
/// Screens should NOT reach in here directly — they read
/// `Theme.of(context).colorScheme` / `context.statusColors`, so the brand stays
/// swappable from one place.
abstract final class AppPalette {
  // --- Steel ramp (primary spine: charcoal → blue-grey, the "raw steel") ----
  static const steel50 = Color(0xFFF5F7F8);
  static const steel100 = Color(0xFFE7ECEE);
  static const steel200 = Color(0xFFCFD8DC); // hairlines / outlineVariant
  static const steel300 = Color(0xFFB0BEC5);
  static const steel400 = Color(0xFF8A9AA3);
  static const steel500 = Color(0xFF607079);
  static const steel600 = Color(0xFF455A64); // interactive steel
  static const steel700 = Color(0xFF37474F);
  static const steel800 = Color(0xFF2E343B); // primary (graphite)
  static const steel900 = Color(0xFF21262B);
  static const steel950 = Color(0xFF14181B);

  // --- Brass ramp (accent: warm metal, hue ~38) -----------------------------
  static const brass50 = Color(0xFFFBF3E4);
  static const brass100 = Color(0xFFF6E6C8);
  static const brass200 = Color(0xFFECCF97);
  static const brass300 = Color(0xFFE0B566);
  static const brass400 = Color(0xFFD29E3F);
  static const brass500 = Color(0xFFC2872B); // brand accent (fill only)
  static const brass600 = Color(0xFFA06E1F);
  static const brass700 = Color(0xFF835A1A); // accent that carries white text
  static const brass800 = Color(0xFF5F4112);
  static const brass900 = Color(0xFF43300D);

  // --- Functional / semantic signals ----------------------------------------
  // Surfaces tuned for chip presence (~1.3:1 against a white card) while
  // keeping ink at WCAG AA (>=4.5:1).

  // Success (accepted / completed).
  static const green = Color(0xFF2E7D52);
  static const greenSurface = Color(0xFFCDEAD8);
  static const greenInk = Color(0xFF1B5E3A);

  // Danger (declined / destructive).
  static const red = Color(0xFFC0392B);
  static const redSurface = Color(0xFFF6D4CF);
  static const redInk = Color(0xFF8E2A20);

  // Warning / needs-attention (e.g. unassigned). A touch more orange than the
  // brass accent so "warning" never reads as "brand".
  static const amber = Color(0xFFB45309);
  static const amberSurface = Color(0xFFF6DFC4);
  static const amberInk = Color(0xFF7A3D0E);

  // Neutral / dormant (cancelled).
  static const grey = Color(0xFF76808C);
  static const greySurface = Color(0xFFDDE2E8);
  static const greyInk = Color(0xFF4A535D);

  // Info / in-progress (requested / active). A semantic blue — deliberately NOT
  // a brand colour; its job is to be a distinct, calm "pending" signal.
  static const infoSurface = Color(0xFFC9EBF1);
  static const infoInk = Color(0xFF0E5663);

  // Paper white surfaces.
  static const white = Color(0xFFFFFFFF);
}
