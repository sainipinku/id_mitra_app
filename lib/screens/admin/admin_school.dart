import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/utils/MyStyles.dart';

class AdminSchool extends StatefulWidget {
  const AdminSchool({super.key});

  @override
  State<AdminSchool> createState() => _AdminSchoolState();
}

class _AdminSchoolState extends State<AdminSchool> {
  @override
  Widget build(BuildContext context) {
    return Text("History", style: MyStyles.regularTxt(AppTheme.black_Color, 14));
  }
}
