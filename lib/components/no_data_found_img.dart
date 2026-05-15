import 'package:flutter/material.dart';


class NoDataFoundImg extends StatelessWidget {
  const NoDataFoundImg({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      "assets/images/no_data_found.png",
      fit: BoxFit.cover,
      width: double.infinity,
    );
  }
}
