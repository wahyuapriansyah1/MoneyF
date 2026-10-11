import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Warna utama Moneyf — tema Biru Modern
class AppColors {
  // Primary Blues
  static const Color primary = Color(0xFF1565C0);      // biru utama
  static const Color primaryDark = Color(0xFF0D47A1);  // biru gelap
  static const Color primaryLight = Color(0xFF42A5F5); // biru muda
  static const Color primarySurface = Color(0xFFE3F2FD); // bg biru tipis

  // Background
  static const Color bgScreen = Color(0xFFF0F4FF);
  static const Color bgCard = Colors.white;

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textWhite = Colors.white;

  // Semantic
  static const Color positive = Color(0xFF2E7D32);   // hijau income
  static const Color negative = Color(0xFFD32F2F);   // merah expense
  static const Color warning = Color(0xFFE65100);    // oranye utang

  // Status badge
  static const Color badgePaidBg = Color(0xFFE8F5E9);
  static const Color badgePaidText = Color(0xFF2E7D32);
  static const Color badgeUnpaidBg = Color(0xFFFFEBEE);
  static const Color badgeUnpaidText = Color(0xFFD32F2F);

  // Input
  static const Color inputFill = Color(0xFFF0F4FF);
  static const Color inputBorder = Color(0xFFD0DAFF);

  // ─── legacy aliases (jaga kompatibilitas) ───
  static const Color black = Color(0xFF1A1A2E);
  static const Color bgTop = bgScreen;
  static const Color peachStart = Color(0xFF42A5F5);
  static const Color peachEnd = Color(0xFF1565C0);
  static const Color chipYellow = Color(0xFFFFCC80);
  static const Color chipPurple = Color(0xFFCE93D8);
  static const Color chipBlue = Color(0xFF90CAF9);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primaryLight,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.bgScreen,
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 6,
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return null;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.primary;
        return AppColors.primarySurface;
      }),
      todayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return AppColors.primary;
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
  return base.copyWith(textTheme: textTheme);
}

/// Gradient biru untuk header/background atas
BoxDecoration blueGradientHeader() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.primaryDark, AppColors.primary, Color(0xFF1976D2)],
    ),
  );
}

BoxDecoration screenBackground() {
  return const BoxDecoration(color: AppColors.bgScreen);
}

class BlackButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const BlackButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
