import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/components/my_font_weight.dart';

class EmployeeReportScreen extends StatefulWidget {
  const EmployeeReportScreen({super.key});

  @override
  State<EmployeeReportScreen> createState() => _EmployeeReportScreenState();
}

class _EmployeeReportScreenState extends State<EmployeeReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Reports',
        style: MyStyles.regularText(size: 14, color: AppTheme.black_Color),
      ),
    );
  }
}
