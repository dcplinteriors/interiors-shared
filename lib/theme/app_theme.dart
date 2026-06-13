import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'status_colors.dart';

/// The DCPL design system — "Blueprint Slate".
///
/// A hand-authored Material 3 light theme (no raw `fromSeed`): the brand
/// anchors are pinned explicitly from [AppPalette] so chips, surfaces and
/// hairlines stay crisp and on-brand rather than muddy generated tones. The
/// semantic [StatusColors] palette is attached as a theme extension. Both apps
/// consume `AppTheme.light`; nothing app-specific lives here.
abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(useMaterial3: true, colorScheme: _scheme);
    final scheme = _scheme;

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      extensions: const [StatusColors.standard],
      textTheme: _refine(base.textTheme),

      // Flat "drafting" app bar: surface-coloured, hairline under-scroll.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: _refine(base.textTheme).titleLarge,
      ),

      // Outlined inputs — drafting-precise, 10px corners, accent focus ring.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: _inputBorder(scheme.outlineVariant),
        enabledBorder: _inputBorder(scheme.outlineVariant),
        focusedBorder: _inputBorder(scheme.primary, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: _refine(base.textTheme)
            .labelMedium
            ?.copyWith(fontWeight: FontWeight.w600),
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

      // Bottom bar (compact / phones) — same brass pill as the rail.
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
        headingRowColor:
            WidgetStatePropertyAll(scheme.surfaceContainerLow),
        headingTextStyle: _refine(base.textTheme).labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
              letterSpacing: 0.2,
            ),
        dataTextStyle: _refine(base.textTheme).bodyMedium,
        dividerThickness: 1,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // --- Hand-authored Material 3 light scheme (Steel & Timber) ---------------
  static const ColorScheme _scheme = ColorScheme(
    brightness: Brightness.light,

    primary: AppPalette.steel800, // graphite
    onPrimary: AppPalette.white,
    primaryContainer: Color(0xFFDBE0E4),
    onPrimaryContainer: Color(0xFF1B2024),

    secondary: AppPalette.steel600, // steel blue-grey
    onSecondary: AppPalette.white,
    secondaryContainer: Color(0xFFD6DEE2),
    onSecondaryContainer: Color(0xFF1A2429),

    tertiary: AppPalette.brass700, // brass that carries white text
    onTertiary: AppPalette.white,
    tertiaryContainer: AppPalette.brass100,
    onTertiaryContainer: Color(0xFF4A330C),

    error: AppPalette.red,
    onError: AppPalette.white,
    errorContainer: AppPalette.redSurface,
    onErrorContainer: Color(0xFF5A130C),

    surface: Color(0xFFF6F7F9),
    onSurface: Color(0xFF1E2227),
    onSurfaceVariant: Color(0xFF454F57),
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: Color(0xFFF1F3F5),
    surfaceContainer: Color(0xFFEBEEF1),
    surfaceContainerHigh: Color(0xFFE5E9EC),
    surfaceContainerHighest: Color(0xFFDFE3E7),

    outline: Color(0xFF717A80),
    outlineVariant: AppPalette.steel200,

    inverseSurface: AppPalette.steel800,
    onInverseSurface: Color(0xFFEEF1F3),
    inversePrimary: Color(0xFFB6C2C9),

    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: AppPalette.steel800,
  );

  // --- Typography: keep Material's defaults, add engineering crispness ------
  // (Headings a touch tighter and heavier; labels slightly tracked-out for the
  // technical feel. A custom typeface can drop in here later without touching
  // any screen.)
  static TextTheme _refine(TextTheme base) => base.copyWith(
        headlineSmall: base.headlineSmall
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
        titleLarge: base.titleLarge
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.1),
        titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: base.labelLarge
            ?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.1),
      );

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  static final RoundedRectangleBorder _buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

  static const TextStyle _buttonText =
      TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.1);
}
