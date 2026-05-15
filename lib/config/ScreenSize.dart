import 'package:flutter/material.dart';

class ScreenSize {

  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent / 100;
  }

  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent / 100;
  }
}