import 'package:flutter/material.dart';

/// Palet gaya komik yang lebih gelap: kertas kecokelatan, tinta hitam tebal, dan warna pop yang diredupkan.
class MarsColors {
  static const ink = Color(0xFF0E0C0A);
  static const bg = Color(0xFFC9B27E);
  static const card = Color(0xFFFFF3D0);
  static const border = ink;
  static const accent = Color(0xFFB71C2B);
  static const yellow = Color(0xFFE0A800);
  static const blue = Color(0xFF173A93);
  static const sand = ink;
  static const muted = Color(0xFF4A4438);
}

/// Gaya judul komik. Memakai font khusus Display (dibundel di aplikasi, tanpa internet).
TextStyle comicStyle({double? fontSize, Color? color, double? letterSpacing}) {
  return TextStyle(
    fontFamily: 'Display',
    fontSize: fontSize ?? 20,
    color: color ?? MarsColors.ink,
    letterSpacing: letterSpacing ?? 1.5,
    height: 1.1,
  );
}

/// Panel komik: garis tinta tebal dan bayangan keras tanpa blur.
BoxDecoration comicBox({Color color = MarsColors.card, double shadow = 5}) {
  return BoxDecoration(
    color: color,
    border: Border.all(color: MarsColors.ink, width: 3),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: MarsColors.ink,
        offset: Offset(shadow, shadow),
        blurRadius: 0,
      ),
    ],
  );
}

ThemeData marsTheme() {
  final base = ThemeData.light(useMaterial3: true);
  final ink = MarsColors.ink;

  return base.copyWith(
    fontFamily: 'Body',
    scaffoldBackgroundColor: MarsColors.bg,
    colorScheme: const ColorScheme.light(
      primary: MarsColors.accent,
      onPrimary: Colors.white,
      secondary: MarsColors.yellow,
      surface: MarsColors.card,
      onSurface: MarsColors.ink,
    ),
    textTheme: base.textTheme
        .copyWith(
          headlineMedium: comicStyle(fontSize: 32),
          titleLarge: comicStyle(fontSize: 24),
        )
        .apply(fontFamily: 'Body', bodyColor: ink, displayColor: ink),
    appBarTheme: AppBarTheme(
      backgroundColor: MarsColors.yellow,
      foregroundColor: ink,
      elevation: 0,
      titleTextStyle: comicStyle(fontSize: 24),
      shape: Border(bottom: BorderSide(color: ink, width: 3)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MarsColors.card,
      labelStyle: const TextStyle(color: MarsColors.ink, fontWeight: FontWeight.w700),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: ink, width: 3),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: ink, width: 3),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: MarsColors.blue, width: 3),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: MarsColors.card,
      indicatorColor: MarsColors.yellow,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontFamily: 'Display', color: ink),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MarsColors.accent,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: ink, width: 3),
        ),
        textStyle: comicStyle(fontSize: 18),
      ),
    ),
  );
}
