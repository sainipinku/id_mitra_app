import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idmitra/api_mamanger/UserLocal.dart';
import 'package:idmitra/components/app_theme.dart';
import 'package:idmitra/models/schools/SchoolListModel.dart';
import 'package:idmitra/providers/student_form/student_form_cubit.dart';
import 'package:idmitra/screens/edit_profile/student_form.dart';
import 'package:idmitra/utils/MyStyles.dart';
import 'package:idmitra/utils/navigation_utils.dart';

class StaffSetting extends StatefulWidget {
  const StaffSetting({super.key});

  @override
  State<StaffSetting> createState() => _StaffSettingState();
}

class _StaffSettingState extends State<StaffSetting> {
  void _openStudentForm() async {
    final school = await UserLocal.getSchool();
    final schoolId = school['schoolId'] ?? '';
    final schoolName = school['schoolName'] ?? '';

    if (!mounted) return;

    navigateWithTransition(
      context: context,
      page: BlocProvider(
        create: (_) => StudentFormCubit()
          ..loadFromSchoolId(schoolId: schoolId, schoolName: schoolName),
        child: StudentForm(
          schoolDetailsModel: SchoolDetailsModel(
            name: schoolName,
            id: int.tryParse(schoolId),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: MyStyles.boldTxt(AppTheme.black_Color, 18)),
          const SizedBox(height: 16),
          _settingTile(
            icon: Icons.assignment,
            title: 'Student Form Fields',
            subtitle: 'Configure student registration form',
            onTap: _openStudentForm,
          ),
        ],
      ),
    );
  }

  Widget _settingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.btn10perOpacityColor,
              child: Icon(icon, color: AppTheme.btnColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: MyStyles.semiBoldTxt(AppTheme.black_Color, 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: MyStyles.regularTxt(AppTheme.graySubTitleColor, 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
