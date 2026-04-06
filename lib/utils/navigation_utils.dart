import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

Future<T?> navigateWithTransition<T>({
  required BuildContext context,
  required Widget page,
  PageTransitionType transitionType = PageTransitionType.bottomToTop,
}) {
  return Navigator.push<T>(
    context,
    PageTransition(
      type: transitionType,
      child: page,
      ctx: context,
    ),
  );
}

Future<T?> navigateAndRemoveUntil<T>({
  required BuildContext context,
  required Widget page,
  PageTransitionType transition = PageTransitionType.rightToLeft,
}) {
  return Navigator.pushAndRemoveUntil<T>(
    context,
    PageTransition(
      type: transition,
      child: page,
      ctx: context,
    ),
        (route) => false,
  );
}

Future<T?> navigatePushReplacement<T>({
  required BuildContext context,
  required Widget page,
  PageTransitionType transition = PageTransitionType.rightToLeft,
}) {
  return Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );

}
