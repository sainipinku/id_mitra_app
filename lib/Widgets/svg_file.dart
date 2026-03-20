import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';


Widget svgIcon({required String icon,double? height,double? width,required Color clr}) {
  return SvgPicture.asset(
    icon, // Path to your SVG file
    height: height,
    width: width,
    colorFilter: ColorFilter.mode(
      clr, // Main color for the icon
      BlendMode.srcIn,
    ),
  );
}
Widget svgIconWithOutBgColor({required String icon,double? height,double? width}) {
  return SvgPicture.asset(
    icon, // Path to your SVG file
  );
}
Widget svgImage({required String image,double? height,double? width}) {
  return SvgPicture.asset(
    image,height: height,width: width,
  );
}