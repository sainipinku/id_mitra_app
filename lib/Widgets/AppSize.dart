import 'package:flutter/material.dart';

class AppSize {
  static late double width;
  static late double height;

  static init(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
  }
}
