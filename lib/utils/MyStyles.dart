import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyFontWeight {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
  static const FontWeight black = FontWeight.w900;
}

class MyStyles {

  ///------------------------------------new theme text format--------------------------///
  static TextStyle lightTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.light,height: 1.2);
  static TextStyle regularTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.regular,height: 1.1);
  static TextStyle mediumTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.medium,height: 1.2);
  static TextStyle semiBoldTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.semiBold,height: 1.2);
  static TextStyle boldTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.bold,height: 1.2);
  static TextStyle extraBoldTxt(Color color,double fontSize) => GoogleFonts.poppins(
      color: color, fontSize: fontSize, fontWeight: MyFontWeight.extraBold,height: 1.2);
}
