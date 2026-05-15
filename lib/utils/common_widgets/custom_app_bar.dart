

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';


AppBar customAppBar(BuildContext context, GlobalKey<ScaffoldState> key) {
  return AppBar(
    backgroundColor: AppTheme.black_Color,
    elevation: 0,
    automaticallyImplyLeading: false,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            key.currentState!.openDrawer();
          }, // Image tapped
          child: SvgPicture.asset('assets/icons/menu.svg',
              width: 20, height: 15, color: AppTheme.whiteColor),
        ),
        Image.asset('assets/images/logo.png',height: 50,),
        GestureDetector(
          onTap: () {

          }, // Image tapped
          child: Container(
            height: 27,
            width: 25,
            alignment: Alignment.center,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SvgPicture.asset(
                    'assets/icons/notification.svg',
                    height: 20,
                    width: 20,
                    allowDrawingOutsideViewBox: true,
                    color: AppTheme.whiteColor,
                  ),
                ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                        minHeight: 20,
                      ),
                      child: Center(
                        child: Text(
                          '9',
                          style: MyStyles.regularText(size: 12, color: AppTheme.readMessageColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ],
    ),
  );
}