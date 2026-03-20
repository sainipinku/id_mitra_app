import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:idmitra/api_mamanger/secure_storage.dart';

import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/auth/login.dart';
import 'package:idmitra/utils/navigation_utils.dart';


import 'package:page_transition/page_transition.dart';

import '../add_school/add_newschool.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward(); // Start animation

    Timer(const Duration(seconds: 3), () {
      navigationToScreen();
    });
  }

  void navigationToScreen() async {
    var token = await UserSecureStorage.fetchToken();
    print('token----------->$token');
    if (token != null && token.isNotEmpty) {
     /* navigateAndRemoveUntil(
        context: context,
        page: Dashboard(index: 0,),
        transition: PageTransitionType.rightToLeft,
      );*/
    } else {
      navigateAndRemoveUntil(
        context: context,
        page: LoginScreen(),
        transition: PageTransitionType.rightToLeft,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.whiteColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Image.asset(
            "assets/images/app_logo.png",
            width: 250.w,
          ),
        ),
      ),
    );
  }
}
