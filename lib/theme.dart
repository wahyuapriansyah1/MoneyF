import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central color & style palette matching the peach/cream fintech design.
class AppColors {
  static const Color bgTop = Color(0xFFF7ECE3);
  static const Color bgCard = Color(0xFFF3E7DC);
  static const Color inputFill = Color(0xFFEFE2D6);
  static const Color peachStart = Color(0xFFF7C9A8);
  static const Color peachEnd = Color(0xFFF0A98A);
  static const Color black = Color(0xFF1B1B1B);
  static const Color textPrimary = Color(0xFF1E1E1E);
  static const Color textSecondary = Color(0xFF8B8378);
  static const Color positive = Color(0xFF2E7D32);
  static const Color chipYellow = Color(0xFFF6D77A);
  static const Color chipPurple = Color(0xFFD9C6F0);
  static const Color chipBlue = Color(0xFFC9DCF0);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: AppColors.black,
      secondary: AppColors.peachEnd,
    ),
    scaffoldBackgroundColor: AppColors.bgTop,
  );
  final textTheme = GoogleFonts.plusJakartaSansTextTheme(base.textTheme);
  return base.copyWith(
    textTheme: textTheme,
  );
}

BoxDecoration screenBackground() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.bgTop, Color(0xFFF9F2EC)],
    ),
  );
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
          backgroundColor: AppColors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
