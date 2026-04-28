import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/utils/MyStyles.dart';

class StaffReports extends StatefulWidget {
  const StaffReports({super.key});

  @override
  State<StaffReports> createState() => _StaffReportsState();
}

class _StaffReportsState extends State<StaffReports> {
  @override
  Widget build(BuildContext context) {
    return Text("Message", style: MyStyles.regularTxt(AppTheme.black_Color, 14));
  }
}
