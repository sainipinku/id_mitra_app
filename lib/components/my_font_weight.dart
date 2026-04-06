
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idmitra/components/app_theme.dart';



/// FONT WEIGHTS
class MyFontWeight {
  static const light = FontWeight.w300;
  static const regular = FontWeight.w400;
  static const medium = FontWeight.w500;
  static const semiBold = FontWeight.w600;
  static const bold = FontWeight.w700;
  static const extraBold = FontWeight.w800;
}

/// BASE TEXT STYLE (GLOBAL)
TextStyle baseTextStyle({
  required double size,
  required FontWeight weight,
  required Color color,
  double letterSpacing = 0,
}) {
  return GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
    ),
  );
}

/// GLOBAL TEXT STYLES
class MyStyles {
  // BLACK COLOR TEXTS
  static final black12Light =
  baseTextStyle(size: 12, weight: MyFontWeight.light, color: AppTheme.black_Color);

  static final black14Light =
  baseTextStyle(size: 14, weight: MyFontWeight.light, color: AppTheme.black_Color);

  static final black16Light =
  baseTextStyle(size: 16, weight: MyFontWeight.light, color: AppTheme.black_Color);

  static final black16Medium =
  baseTextStyle(size: 16, weight: MyFontWeight.medium, color: AppTheme.black_Color);

  static final black20Medium =
  baseTextStyle(size: 20, weight: MyFontWeight.medium, color: AppTheme.black_Color);

  static final black22Bold =
  baseTextStyle(size: 22, weight: MyFontWeight.bold, color: AppTheme.black_Color);

  static final black25Medium =
  baseTextStyle(size: 25, weight: MyFontWeight.medium, color: AppTheme.black_Color);

  static TextStyle extraBoldText({
    required double size,
    required Color color,
  }) {
    return baseTextStyle(
      size: size,
      weight: MyFontWeight.extraBold,
      color: color,
    );
  }
  static TextStyle mediumText({
    required double size,
    required Color color,
  }) {
    return baseTextStyle(
      size: size,
      weight: MyFontWeight.medium,
      color: color,
    );
  }
  static TextStyle boldText({
    required double size,
    required Color color,
  }) {
    return baseTextStyle(
      size: size,
      weight: MyFontWeight.bold,
      color: color,
    );
  }
  static TextStyle regularText({
    required double size,
    required Color color,
  }) {
    return baseTextStyle(
      size: size,
      weight: MyFontWeight.regular,
      color: color,
    );
  }
  static final black24ExtraBold = baseTextStyle(
    size: 24,
    weight: MyFontWeight.extraBold,
    color: AppTheme.black_Color,
    letterSpacing: 2,
  );

  // BLUE TEXT
  static final blue14Bold =
  baseTextStyle(size: 14, weight: MyFontWeight.bold, color: Colors.blue);

  // WHITE TEXT
  static final white22ExtraBold =
  baseTextStyle(size: 22, weight: MyFontWeight.extraBold, color: AppTheme.whiteColor);

  // GREY TEXT
  static final grey20Light =
  baseTextStyle(size: 20, weight: MyFontWeight.light, color: Colors.grey);
}
