import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Elder-first accessible theme for FeelView with a rich, premium modern aesthetic.
/// Combines high-contrast readability (64pt touch targets, 16sp+ text) with luxury styling.
class AppTheme {
  AppTheme._();

  // Premium Brand Palette
  static const Color _primary = Color(0xFF0F5C43);       // Rich Emerald Teal
  static const Color _onPrimary = Color(0xFFFFFFFF);
  static const Color _primaryContainer = Color(0xFFD1FAE5); // Mint Cream Accent
  static const Color _onPrimaryContainer = Color(0xFF064E3B);
  
  static const Color _surface = Color(0xFFFDFBF7);       // Warm Silk / Ivory
  static const Color _onSurface = Color(0xFF18181B);     // Near-black slate
  static const Color _surfaceContainer = Color(0xFFF4F1EA);// Soft cream card surface
  static const Color _outline = Color(0xFFE2DED6);
  
  // Dark Luxury Palette
  static const Color _primaryDark = Color(0xFF34D399);   // Vibrant Mint
  static const Color _surfaceDark = Color(0xFF0F172A);   // Executive Dark Slate
  static const Color _surfaceContainerDark = Color(0xFF1E293B);
  static const Color _onSurfaceDark = Color(0xFFF8FAFC);

  // Minimum touch target for elder users
  static const Size _minTouchTarget = Size(64, 64);

  static TextTheme _buildTextTheme({required bool dark}) {
    final baseColor = dark ? _onSurfaceDark : _onSurface;
    final bodyStyle = GoogleFonts.inter(color: baseColor);
    final headStyle = GoogleFonts.outfit(color: baseColor);
    
    return TextTheme(
      displayLarge: headStyle.copyWith(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displayMedium: headStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5),
      displaySmall: headStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineLarge: headStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w600),
      headlineMedium: headStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600),
      headlineSmall: headStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
      titleLarge: headStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w600),
      titleMedium: headStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w500),
      titleSmall: headStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      bodyLarge: bodyStyle.copyWith(fontSize: 20, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium: bodyStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall: bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: bodyStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.2),
      labelMedium: bodyStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      labelSmall: bodyStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
    );
  }

  static TextTheme get elderTextTheme => _buildTextTheme(dark: false);

  static TextTheme get posterTextTheme {
    final base = _buildTextTheme(dark: false);
    return base.copyWith(
      bodyLarge: base.bodyLarge!.copyWith(fontSize: 18),
      bodyMedium: base.bodyMedium!.copyWith(fontSize: 16),
      bodySmall: base.bodySmall!.copyWith(fontSize: 16),
    );
  }

  static ThemeData get lightTheme => _build(dark: false);
  static ThemeData get darkTheme => _build(dark: true);

  static ThemeData _build({required bool dark}) {
    final primary = dark ? _primaryDark : _primary;
    final surface = dark ? _surfaceDark : _surface;
    final onSurface = dark ? _onSurfaceDark : _onSurface;
    final surfaceContainer = dark ? _surfaceContainerDark : _surfaceContainer;
    
    final colorScheme = dark
        ? ColorScheme.dark(
            primary: primary,
            onPrimary: _surfaceDark,
            primaryContainer: const Color(0xFF064E3B),
            onPrimaryContainer: _primaryDark,
            surface: surface,
            onSurface: onSurface,
            surfaceContainerHigh: surfaceContainer,
            outline: const Color(0xFF334155),
          )
        : ColorScheme.light(
            primary: primary,
            onPrimary: _onPrimary,
            primaryContainer: _primaryContainer,
            onPrimaryContainer: _onPrimaryContainer,
            surface: surface,
            onSurface: onSurface,
            surfaceContainerHigh: surfaceContainer,
            outline: _outline,
          );

    final textTheme = _buildTextTheme(dark: dark);

    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: surface,
      
      // Luxurious Card Theme
      cardTheme: CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colorScheme.outline.withOpacity(0.5), width: 1),
        ),
      ),

      // Sleek AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        titleTextStyle: textTheme.headlineMedium!.copyWith(
          color: primary,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: primary, size: 28),
      ),

      // Accessible & Modern Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? _surfaceDark : _onPrimary,
          minimumSize: _minTouchTarget,
          elevation: 4,
          shadowColor: primary.withOpacity(0.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          textStyle: textTheme.labelLarge!.copyWith(fontWeight: FontWeight.w700),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: dark ? _surfaceDark : _onPrimary,
          minimumSize: _minTouchTarget,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Modern Pill Navigation Bar
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surfaceContainer,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.1),
        height: 88,
        indicatorColor: primary.withOpacity(dark ? 0.25 : 0.15),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelLarge!.copyWith(color: primary, fontWeight: FontWeight.w700);
          }
          return textTheme.labelMedium!.copyWith(color: onSurface.withOpacity(0.7));
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 32);
          }
          return IconThemeData(color: onSurface.withOpacity(0.7), size: 28);
        }),
      ),

      // Clean Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainer,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }
}
