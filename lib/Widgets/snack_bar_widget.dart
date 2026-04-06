import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';


SnackBar snackBar(title, icon, color) {
  return SnackBar(
    duration: Duration(seconds: 1),
    content: Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        SizedBox(
          width: 10.w,
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.all(30.0.w),
    backgroundColor: color,
  );
}
createSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(seconds: 3),
    backgroundColor: AppTheme.mainColor,
    content: Text(
      message,
      style: MyStyles.regularText(size: 14, color: AppTheme.whiteColor),
    ),
  ));
}
