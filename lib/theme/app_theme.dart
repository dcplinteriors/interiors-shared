import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_palette.dart';
import 'status_colors.dart';

/// The DCPL design system — "Molten".
///
/// A hand-authored Material 3 light theme (no raw `fromSeed`): a disciplined
/// graphite-on-paper foundation (the "cold steel" — `primary` stays graphite so
/// dense tables read effortlessly) lit by the brand's **crimson** accent
/// (`tertiary`), the solid stand-in for the Molten gradient (see
/// `BrandGradient`). Brand anchors are pinned explicitly from [AppPalette] so
/// chips, surfaces and hairlines stay crisp rather than muddy generated tones.
/// Typography is **Sora** (display/titles) over **Inter** (body/data) via
/// `google_fonts`. The semantic [StatusColors] palette is attached as a theme
/// extension and is deliberately NOT a brand colour. Both apps consume
/// `AppTheme.light`; nothing app-specific lives here.
abstract final class AppTheme {
  /// Light Molten — graphite-on-paper.
  static ThemeData get light => _build(_lightScheme, StatusColors.standard);

  /// Dark Molten — the brand gradient and crimson accent pop against deep
  /// graphite. The apps wire both and currently lock to dark (see each app's
  /// `MaterialApp`); switching is a single `themeMode` flip away.
  static ThemeData get dark => _build(_darkScheme, StatusColors.dark);

  static ThemeData _build(ColorScheme scheme, StatusColors statusColors) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = _buildTextTheme(base.textTheme);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      extensions: [statusColors],
      textTheme: text,

      // Flat "drafting" app bar: surface-coloured, hairline under-scroll.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),

      // Outlined inputs — drafting-precise, 10px corners, brand (crimson) focus
      // ring: the one place the Molten accent touches a form field.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.tertiary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        // Min height 48 WITHOUT forcing width — `Size.fromHeight` sets width to
        // infinity, which crashes a button placed in a Row (unbounded width).
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: _buttonShape,
          textStyle: _buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: _buttonShape,
          side: BorderSide(color: scheme.outline),
          textStyle: _buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(textStyle: _buttonText),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),

      chipTheme: ChipThemeData(
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        // Brass pill behind the selected destination — the one warm signature
        // accent, placed where the eye lives.
        indicatorColor: scheme.tertiaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onTertiaryContainer),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),

      // Bottom bar (compact / phones) — same soft-crimson pill as the rail.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.tertiaryContainer,
        elevation: 2,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? scheme.onSurface
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.onTertiaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),

      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStatePropertyAll(scheme.surfaceContainerLow),
        headingTextStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurfaceVariant,
          letterSpacing: 0.2,
        ),
        dataTextStyle: text.bodyMedium,
        dividerThickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- Hand-authored Material 3 light scheme (Molten) -----------------------
  // Graphite foundation (primary = steel) + crimson brand accent (tertiary).
  // `final`, not `const`: MaterialColor shade access (`.shade800`) is a runtime
  // getter, so the scheme is built once at first use rather than at compile time.
  static final ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,

    primary: AppPalette.steel.shade800, // graphite
    onPrimary: AppPalette.white,
    primaryContainer: const Color(0xFFDBE0E4),
    onPrimaryContainer: const Color(0xFF1B2024),

    secondary: AppPalette.steel.shade600, // steel blue-grey
    onSecondary: AppPalette.white,
    secondaryContainer: const Color(0xFFD6DEE2),
    onSecondaryContainer: const Color(0xFF1A2429),

    tertiary: AppPalette.crimson.shade700, // crimson that carries white text
    onTertiary: AppPalette.white,
    tertiaryContainer: AppPalette.crimson.shade50, // soft molten nav pill
    onTertiaryContainer: AppPalette.crimson.shade900,

    error: AppPalette.red,
    onError: AppPalette.white,
    errorContainer: AppPalette.redSurface,
    onErrorContainer: const Color(0xFF5A130C),

    surface: const Color(0xFFF6F7F9),
    onSurface: const Color(0xFF1E2227),
    onSurfaceVariant: const Color(0xFF454F57),
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: const Color(0xFFF1F3F5),
    surfaceContainer: const Color(0xFFEBEEF1),
    surfaceContainerHigh: const Color(0xFFE5E9EC),
    surfaceContainerHighest: const Color(0xFFDFE3E7),

    outline: const Color(0xFF717A80),
    outlineVariant: AppPalette.steel.shade200,

    inverseSurface: AppPalette.steel.shade800,
    onInverseSurface: const Color(0xFFEEF1F3),
    inversePrimary: const Color(0xFFB6C2C9),

    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    surfaceTint: AppPalette.steel.shade800,
  );

  // --- Hand-authored Material 3 dark scheme (Molten) ------------------------
  // Deep-graphite surfaces (scaffold darkest, cards/containers step lighter to
  // pop) with a LIGHT neutral `primary` (default filled buttons) and a BRIGHT
  // crimson `tertiary` — the brand glows against the dark. Status semantics live
  // in `StatusColors.dark`.
  static final ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,

    primary:
        AppPalette.steel.shade100, // light neutral (default filled buttons)
    onPrimary: const Color(0xFF0F1217),
    primaryContainer: AppPalette.steel.shade700,
    onPrimaryContainer: const Color(0xFFDCE3E8),

    secondary: AppPalette.steel.shade300,
    onSecondary: const Color(0xFF0F1217),
    secondaryContainer: AppPalette.steel.shade800,
    onSecondaryContainer: const Color(0xFFD6DEE2),

    tertiary: AppPalette.crimson.shade400, // bright crimson — pops on dark
    onTertiary: const Color(0xFF40000E),
    tertiaryContainer: const Color(0xFF3C1019), // deep-crimson nav pill
    onTertiaryContainer: AppPalette.crimson.shade200,

    error: const Color(0xFFF2655B),
    onError: const Color(0xFF470A05),
    errorContainer: const Color(0xFF5C1A12),
    onErrorContainer: const Color(0xFFF8D7D0),

    surface: const Color(
      0xFF0F1217,
    ), // deep near-black so the molten accent glows
    onSurface: const Color(0xFFECEFF2),
    onSurfaceVariant: const Color(0xFF939DA7), // cool muted grey
    surfaceContainerLowest: const Color(
      0xFF181C22,
    ), // cards float above scaffold
    surfaceContainerLow: const Color(0xFF1C2027),
    surfaceContainer: const Color(0xFF21262D),
    surfaceContainerHigh: const Color(0xFF272D35), // table header band
    surfaceContainerHighest: const Color(0xFF2F3640),

    outline: const Color(0xFF5B646E),
    outlineVariant: const Color(0xFF282E36), // thin, low-contrast hairline

    inverseSurface: const Color(0xFFE6EAED),
    onInverseSurface: const Color(0xFF0F1217),
    inversePrimary: AppPalette.steel.shade700,

    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    surfaceTint: AppPalette.steel.shade300, // subtle light tint on elevation
  );

  // --- Typography: Sora (display/titles) over Inter (body/data) -------------
  // Inter carries everything legibility-critical (body, labels, numerics); Sora
  // gives display & title sizes the engineered, geometric voice of the logo.
  // Both ship via `google_fonts`, so no font assets to bundle.
  static TextTheme _buildTextTheme(TextTheme base) {
    final inter = GoogleFonts.interTextTheme(base);

    // Sora slot: preserve the themed colour from [s], override the metrics.
    TextStyle sora(
      TextStyle? s, {
      required double size,
      required FontWeight weight,
      double tracking = 0,
      double height = 1.12,
    }) => GoogleFonts.sora(
      textStyle: s,
      fontSize: size,
      fontWeight: weight,
      letterSpacing: tracking,
      height: height,
    );

    return inter.copyWith(
      // Display & headline — Sora, the engineered voice of the logo. Page titles
      // land on displaySmall; section titles on headlineSmall.
      displayLarge: sora(
        inter.displayLarge,
        size: 40,
        weight: FontWeight.w800,
        tracking: -0.6,
        height: 1.02,
      ),
      displayMedium: sora(
        inter.displayMedium,
        size: 34,
        weight: FontWeight.w800,
        tracking: -0.5,
        height: 1.04,
      ),
      displaySmall: sora(
        inter.displaySmall,
        size: 30,
        weight: FontWeight.w800,
        tracking: -0.5,
        height: 1.06,
      ),
      headlineLarge: sora(
        inter.headlineLarge,
        size: 26,
        weight: FontWeight.w700,
        tracking: -0.4,
        height: 1.1,
      ),
      headlineMedium: sora(
        inter.headlineMedium,
        size: 22,
        weight: FontWeight.w700,
        tracking: -0.3,
        height: 1.15,
      ),
      headlineSmall: sora(
        inter.headlineSmall,
        size: 19,
        weight: FontWeight.w700,
        tracking: -0.2,
        height: 1.2,
      ),
      // Titles — Sora for app-bar and card headings.
      titleLarge: sora(
        inter.titleLarge,
        size: 18,
        weight: FontWeight.w700,
        tracking: -0.1,
        height: 1.25,
      ),
      titleMedium: sora(
        inter.titleMedium,
        size: 16,
        weight: FontWeight.w700,
        tracking: -0.05,
        height: 1.3,
      ),
      // Body & data — Inter, tuned for comfortable reading line-heights.
      bodyLarge: inter.bodyLarge?.copyWith(fontSize: 15.5, height: 1.5),
      bodyMedium: inter.bodyMedium?.copyWith(fontSize: 14.5, height: 1.5),
      bodySmall: inter.bodySmall?.copyWith(fontSize: 13, height: 1.45),
      // Labels — buttons, chips, field labels (the eyebrow is tracked at usage).
      labelLarge: inter.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelMedium: inter.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      labelSmall: inter.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  static final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static const TextStyle _buttonText = TextStyle(
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );
}
