import 'package:flutter/material.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/screens/dashboard/StatCard.dart';
import 'package:idmitra/utils/MyStyles.dart';
import 'package:idmitra/utils/navigation_utils.dart';

import '../add_student/add_student.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children:  [
              Expanded(child: StatCard(title: "Total Students", value: "1240", icon: Icons.school, color: Colors.orange,  button: (){

              },)),
              SizedBox(width: 12),
              Expanded(child: StatCard(title: "Total Staff", value: "85", icon: Icons.group, color: Colors.blue,  button: (){

              },)),
              SizedBox(width: 12),
              Expanded(child: StatCard(title: "Total Orders", value: "1240", icon: Icons.receipt_long, color: Colors.indigo,  button: (){

              },)),
            ],
          ),

          const SizedBox(height: 20),

          Text("Management Modules", style: MyStyles.boldTxt(AppTheme.black_Color, 16)),

          const SizedBox(height: 12),

          Row(
            children: [

              Expanded(
                child: GestureDetector(
                  onTap: () => navigateWithTransition(context: context, page: const AddNewStudent()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.person_add, color: Colors.white, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text("Add Student", style: MyStyles.regularTxt(AppTheme.black_Color, 14)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppTheme.btnColor,
                          child: const Icon(Icons.group_add, color: Colors.white, size: 26),
                        ),
                        const SizedBox(height: 12),
                        Text("Add Staff", style: MyStyles.regularTxt(AppTheme.black_Color, 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Recent Activity", style: MyStyles.boldTxt(AppTheme.black_Color, 16)),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text("View All", style: MyStyles.regularTxt(AppTheme.btnColor, 14)),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppTheme.btnColor),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.green.withOpacity(0.15),
                  child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("New ID Generated", style: MyStyles.semiBoldTxt(AppTheme.black_Color, 14)),
                      const SizedBox(height: 2),
                      Text("Student: Sarah Jenkins (Gr. 10)", style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12)),
                    ],
                  ),
                ),
                Text("2m ago", style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12)),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.btnColor.withOpacity(0.15),
                  child: const Icon(Icons.pie_chart, color: AppTheme.btnColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Staff Record Updated", style: MyStyles.semiBoldTxt(AppTheme.black_Color, 14)),
                      const SizedBox(height: 2),
                      Text("Mr. Robert Wilson (Physics)", style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12)),
                    ],
                  ),
                ),
                Text("22m ago", style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
