
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';


class AppTextStyles {

  /// Biggest Bold Title
  static final titleLarge =
  baseTextStyle(size: 16, weight: MyFontWeight.bold, color: AppTheme.black_Color);

  /// Medium Title
  static TextStyle titleMedium = const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  /// Small Title
  static TextStyle titleSmall = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  /// Body Text
  static TextStyle body = const TextStyle(
    fontSize: 16,
    color: Colors.black87,
  );

  /// Small Text
  static TextStyle bodySmall = const TextStyle(
    fontSize: 14,
    color: Colors.grey,
  );

  /// Caption / Hint text
  static TextStyle caption = const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );



}
/// BASE TEXT STYLE (GLOBAL)
TextStyle baseTextStyle({
  required double size,
  required FontWeight weight,
  required Color color,
  double letterSpacing = 0,
}) {
  return GoogleFonts.poppins(
    textStyle: TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    ),
  );
}

Widget RequiredLabel(String text) {
  return Text.rich(
    TextSpan(
      text: text,
      style: MyStyles.boldText(
        size: 14,
        color: AppTheme.black_Color,
      ),
      children: [
        TextSpan(
          text: ' *',
          style: MyStyles.boldText(
            size: 14,
            color: Colors.red,
          ),
        ),
      ],
    ),
  );
}

Widget TextLabel(String text) {
  return Text(
    text,
    style: MyStyles.boldText(
      size: 14,
      color: AppTheme.black_Color,
    ),
  );
}