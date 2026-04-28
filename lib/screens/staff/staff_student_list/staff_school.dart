import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/utils/MyStyles.dart';

class StaffSchool extends StatefulWidget {
  const StaffSchool({super.key});

  @override
  State<StaffSchool> createState() => _StaffSchoolState();
}

class _StaffSchoolState extends State<StaffSchool> {
  @override
  Widget build(BuildContext context) {
    return Text("History", style: MyStyles.regularTxt(AppTheme.black_Color, 14));
  }
}
