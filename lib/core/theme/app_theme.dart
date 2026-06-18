// FILE: lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary:   AppColors.primary,
    ),
    useMaterial3:            true,
    scaffoldBackgroundColor: AppColors.bg,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation:       0,
      centerTitle:     true,
      titleTextStyle:  TextStyle(
        fontSize:   17,
        fontWeight: FontWeight.w600,
        color:      Colors.white,
      ),
    ),

    // FIX LỖI 2: Flutter 3.x dùng CardThemeData thay vì CardTheme
    cardTheme: CardThemeData(
      color:     AppColors.surface,
      elevation: 0,
      shape:     RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side:         const BorderSide(color: Color(0xFFE5EAE7)),
      ),
      margin: EdgeInsets.zero,
    ),

    // ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation:       0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(
          fontSize:   15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side:            const BorderSide(color: AppColors.borderDefault),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        minimumSize: const Size(double.infinity, 52),
        textStyle: const TextStyle(
          fontSize:   15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(
          fontSize:   13,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // InputDecoration (TextFormField)
    inputDecorationTheme: InputDecorationTheme(
      filled:    true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:   const BorderSide(color: AppColors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(
        fontSize: 14,
        color:    AppColors.textHint,
      ),
    ),

    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior:    SnackBarBehavior.floating,
      shape:       RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentTextStyle: const TextStyle(
        fontSize:   13.5,
        fontWeight: FontWeight.w500,
        color:      Colors.white,
      ),
    ),

    // BottomNavigationBar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor:          AppColors.surface,
      selectedItemColor:        AppColors.primary,
      unselectedItemColor:      AppColors.textHint,
      selectedLabelStyle:       TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle:     TextStyle(fontSize: 11),
      type:                     BottomNavigationBarType.fixed,
      elevation:                8,
    ),

    // FloatingActionButton
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation:       2,
      shape:           CircleBorder(),
    ),

    // Divider
    dividerTheme: const DividerThemeData(
      color:     AppColors.borderDefault,
      thickness: 1,
      space:     1,
    ),
  );
}
